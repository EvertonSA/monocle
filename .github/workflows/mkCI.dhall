-- Re-usable github action for cachix
let GithubActions =
      https://raw.githubusercontent.com/regadas/github-actions-dhall/afa8b8dad361f795ddd24e6d5c54b23e57bca623/package.dhall
        sha256:98ee16e6add21cc8ea7804cce55793b8793b14479f248d8f0bda0209d3600e18

let checkout-step =
      GithubActions.Step::{
      , uses = Some "actions/checkout@v2.4.0"
      , `with` = Some (toMap { submodules = "true" })
      }

let init-docker-steps =
      [ GithubActions.Step::{
        , name = Some "Stop provided Docker"
        , run = Some "sudo systemctl stop docker containerd"
        }
      , GithubActions.Step::{
        , name = Some "Remove provided Docker"
        , run = Some
            "sudo apt-get remove --autoremove -y moby-engine moby-cli moby-buildx moby-containerd moby-runc"
        }
      , GithubActions.Step::{
        , name = Some "Install patched seccomp Docker repository"
        , run = Some "sudo add-apt-repository -y ppa:pascallj/docker.io-clone3"
        }
      , GithubActions.Step::{
        , name = Some "Install patched seccomp Docker"
        , run = Some "sudo apt-get install -y docker.io"
        }
      ]

let el-sysctl-step =
      GithubActions.Step::{
      , name = Some "Configure sysctl limits"
      , run = Some
          ''
          sudo swapoff -a
          sudo sysctl -w vm.swappiness=1
          sudo sysctl -w fs.file-max=262144
          sudo sysctl -w vm.max_map_count=262144
          ''
      }

in  { GithubActions
    , elastic-steps =
      [ el-sysctl-step
      , GithubActions.Step::{
        , name = Some "Runs Elasticsearch"
        , uses = Some "elastic/elastic-github-actions/elasticsearch@master"
        , `with` = Some (toMap { stack-version = "7.10.1" })
        }
      , GithubActions.Step::{
        , name = Some "Display indexes"
        , run = Some "curl -s -I -X GET http://localhost:9200/_cat/indices"
        }
      ]
    , validate-compose-steps =
      [ GithubActions.Step::{
        , name = Some "Set write permission for data directory"
        , run = Some "chmod o+w data"
        }
      , GithubActions.Step::{
        , name = Some "Create a config.yaml file"
        , run = Some
            ''
            cat > etc/config.yaml << EOF
            ---
            workspaces:
              - name: monocle
                crawlers:
                  - name: github-tekton
                    update_since: "2020-01-01"
                    provider:
                      github_organization: tekton
            EOF
            ''
        }
      , GithubActions.Step::{
        , name = Some "Create a secret.yaml file"
        , run = Some
            ''
            cat > .secrets << EOF
            CRAWLERS_API_KEY=secret
            GITHUB_TOKEN=123
            EOF
            ''
        }
      , GithubActions.Step::{
        , name = Some "Build docker image"
        , run = Some
            ''
            export MONOCLE_COMMIT=$(git show HEAD --format="format:%h" -q)
            docker build -t quay.io/change-metrics/monocle:latest .
            ''
        }
      , GithubActions.Step::{
        , name = Some "Start Monocle compose"
        , run = Some "docker-compose up -d"
        }
      , GithubActions.Step::{
        , name = Some "Wait for services to start"
        , run = Some "sleep 45"
        }
      , GithubActions.Step::{
        , name = Some "Display docker-compose ps"
        , run = Some "docker-compose ps"
        }
      , GithubActions.Step::{
        , name = Some "Display docker-compose logs"
        , run = Some "docker-compose logs"
        }
      , GithubActions.Step::{
        , name = Some "Check services are running"
        , run = Some "test -z \"\$(sudo docker-compose ps -a | grep Exit)\""
        }
      , GithubActions.Step::{
        , name = Some "Check api service through nginx"
        , run = Some
            "curl -s --fail -H 'Content-type: application/json' http://localhost:8080/api/2/get_workspaces -d '{}' | grep 'workspaces'"
        }
      , GithubActions.Step::{
        , name = Some "Check web service to fetch web app"
        , run = Some
            "curl -s http://localhost:8080/index.html | grep 'window.document.title'"
        }
      ]
    , makeNix =
        \(cache-name : Text) ->
        \(steps : List GithubActions.Step.Type) ->
          let boot =
                \(name : Text) ->
                  [ checkout-step
                  , GithubActions.Step::{
                    , uses = Some "cachix/install-nix-action@v15"
                    , `with` = Some
                        (toMap { nix_path = "nixpkgs=channel:nixos-unstable" })
                    }
                  , GithubActions.Step::{
                    , uses = Some "cachix/cachix-action@v10"
                    , `with` = Some
                        ( toMap
                            { name
                            , authToken = "\${{ secrets.CACHIX_AUTH_TOKEN }}"
                            }
                        )
                    }
                  ]

          in  GithubActions.Workflow::{
              , name = "Nix"
              , on = GithubActions.On::{
                , pull_request = Some GithubActions.PullRequest::{=}
                }
              , jobs = toMap
                  { api-tests = GithubActions.Job::{
                    , name = Some "api-tests"
                    , runs-on = GithubActions.RunsOn.Type.ubuntu-latest
                    , steps = boot cache-name # steps
                    }
                  }
              }
    , makeNPM =
        \(steps : List GithubActions.Step.Type) ->
          let init =
                [ checkout-step
                , GithubActions.Step::{
                  , uses = Some "actions/setup-node@v2"
                  , `with` = Some (toMap { node-version = "16" })
                  }
                ]

          in  GithubActions.Workflow::{
              , name = "Web"
              , on = GithubActions.On::{
                , pull_request = Some GithubActions.PullRequest::{=}
                }
              , jobs = toMap
                  { web-tests = GithubActions.Job::{
                    , name = Some "web-tests"
                    , runs-on = GithubActions.RunsOn.Type.ubuntu-latest
                    , steps = init # steps
                    }
                  }
              }
    , makeCompose =
        \(steps : List GithubActions.Step.Type) ->
          GithubActions.Workflow::{
          , name = "Docker"
          , on = GithubActions.On::{
            , pull_request = Some GithubActions.PullRequest::{=}
            }
          , jobs = toMap
              { compose = GithubActions.Job::{
                , name = Some "compose-tests"
                , runs-on = GithubActions.RunsOn.Type.ubuntu-latest
                , steps =
                      [ checkout-step ]
                    # init-docker-steps
                    # [ el-sysctl-step ]
                    # steps
                }
              }
          }
    , makePublishMaster =
        \(steps : List GithubActions.Step.Type) ->
          GithubActions.Workflow::{
          , name = "Publish Master Container"
          , on = GithubActions.On::{
            , push = Some GithubActions.Push::{ branches = Some [ "master" ] }
            }
          , jobs = toMap
              { publish-master-container = GithubActions.Job::{
                , name = Some "publish-master-container"
                , `if` = Some "github.repository_owner == 'change-metrics'"
                , runs-on = GithubActions.RunsOn.Type.ubuntu-latest
                , steps =
                      [ checkout-step ]
                    # init-docker-steps
                    # [ el-sysctl-step ]
                    # steps
                }
              }
          }
    , makePublishTag =
        \(steps : List GithubActions.Step.Type) ->
          GithubActions.Workflow::{
          , name = "Publish Tag Container"
          , on = GithubActions.On::{
            , push = Some GithubActions.Push::{ tags = Some [ "*" ] }
            }
          , jobs = toMap
              { publish-master-container = GithubActions.Job::{
                , name = Some "publish-tag-container"
                , `if` = Some "github.repository_owner == 'change-metrics'"
                , runs-on = GithubActions.RunsOn.Type.ubuntu-latest
                , steps =
                      [ checkout-step ]
                    # init-docker-steps
                    # [ el-sysctl-step ]
                    # steps
                }
              }
          }
    , makePublishBuilder =
        \(steps : List GithubActions.Step.Type) ->
          GithubActions.Workflow::{
          , name = "Publish Builder Container"
          , on = GithubActions.On::{
            , workflow_dispatch = Some GithubActions.WorkflowDispatch::{=}
            }
          , jobs = toMap
              { publish-master-container = GithubActions.Job::{
                , name = Some "publish-builder-container"
                , `if` = Some "github.repository_owner == 'change-metrics'"
                , runs-on = GithubActions.RunsOn.Type.ubuntu-latest
                , steps = [ checkout-step ] # init-docker-steps # steps
                }
              }
          }
    }
