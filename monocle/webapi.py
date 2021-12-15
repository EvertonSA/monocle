# Copyright (C) 2021 Monocle authors
# SPDX-License-Identifier: AGPL-3.0-or-later

# Generated by monocle-codegen. DO NOT EDIT!
# flake8: noqa

import requests
from google.protobuf import json_format as pbjson

headers = {"Content-Type": "application/json"}


# Login methods:
from monocle.login_pb2 import LoginValidationRequest
from monocle.login_pb2 import LoginValidationResponse


def login_login_validation(
    url: str, request: LoginValidationRequest
) -> LoginValidationResponse:
    body = pbjson.MessageToJson(request, preserving_proto_field_name=True)
    resp = requests.post(
        url + "/api/2/login/username/validate", data=body, headers=headers
    )
    resp.raise_for_status()
    return pbjson.Parse(resp.content, LoginValidationResponse())


# Config methods:
from monocle.config_pb2 import GetWorkspacesRequest
from monocle.config_pb2 import GetWorkspacesResponse
from monocle.config_pb2 import GetProjectsRequest
from monocle.config_pb2 import GetProjectsResponse
from monocle.config_pb2 import GetAboutRequest
from monocle.config_pb2 import GetAboutResponse


def config_get_workspaces(
    url: str, request: GetWorkspacesRequest
) -> GetWorkspacesResponse:
    body = pbjson.MessageToJson(request, preserving_proto_field_name=True)
    resp = requests.post(url + "/api/2/get_workspaces", data=body, headers=headers)
    resp.raise_for_status()
    return pbjson.Parse(resp.content, GetWorkspacesResponse())


def config_get_projects(url: str, request: GetProjectsRequest) -> GetProjectsResponse:
    body = pbjson.MessageToJson(request, preserving_proto_field_name=True)
    resp = requests.post(url + "/api/2/get_projects", data=body, headers=headers)
    resp.raise_for_status()
    return pbjson.Parse(resp.content, GetProjectsResponse())


def config_get_about(url: str, request: GetAboutRequest) -> GetAboutResponse:
    body = pbjson.MessageToJson(request, preserving_proto_field_name=True)
    resp = requests.post(url + "/api/2/about", data=body, headers=headers)
    resp.raise_for_status()
    return pbjson.Parse(resp.content, GetAboutResponse())


# Search methods:
from monocle.search_pb2 import SuggestionsRequest
from monocle.search_pb2 import SuggestionsResponse
from monocle.search_pb2 import FieldsRequest
from monocle.search_pb2 import FieldsResponse
from monocle.search_pb2 import CheckRequest
from monocle.search_pb2 import CheckResponse
from monocle.search_pb2 import QueryRequest
from monocle.search_pb2 import QueryResponse


def search_suggestions(url: str, request: SuggestionsRequest) -> SuggestionsResponse:
    body = pbjson.MessageToJson(request, preserving_proto_field_name=True)
    resp = requests.post(url + "/api/2/suggestions", data=body, headers=headers)
    resp.raise_for_status()
    return pbjson.Parse(resp.content, SuggestionsResponse())


def search_fields(url: str, request: FieldsRequest) -> FieldsResponse:
    body = pbjson.MessageToJson(request, preserving_proto_field_name=True)
    resp = requests.post(url + "/api/2/search/fields", data=body, headers=headers)
    resp.raise_for_status()
    return pbjson.Parse(resp.content, FieldsResponse())


def search_check(url: str, request: CheckRequest) -> CheckResponse:
    body = pbjson.MessageToJson(request, preserving_proto_field_name=True)
    resp = requests.post(url + "/api/2/search/check", data=body, headers=headers)
    resp.raise_for_status()
    return pbjson.Parse(resp.content, CheckResponse())


def search_query(url: str, request: QueryRequest) -> QueryResponse:
    body = pbjson.MessageToJson(request, preserving_proto_field_name=True)
    resp = requests.post(url + "/api/2/search/query", data=body, headers=headers)
    resp.raise_for_status()
    return pbjson.Parse(resp.content, QueryResponse())


# Metric methods:
from monocle.metric_pb2 import ListRequest
from monocle.metric_pb2 import ListResponse


def metric_list(url: str, request: ListRequest) -> ListResponse:
    body = pbjson.MessageToJson(request, preserving_proto_field_name=True)
    resp = requests.post(url + "/api/2/metric/list", data=body, headers=headers)
    resp.raise_for_status()
    return pbjson.Parse(resp.content, ListResponse())


# UserGroup methods:
from monocle.user_group_pb2 import ListRequest
from monocle.user_group_pb2 import ListResponse
from monocle.user_group_pb2 import GetRequest
from monocle.user_group_pb2 import GetResponse


def user_group_list(url: str, request: ListRequest) -> ListResponse:
    body = pbjson.MessageToJson(request, preserving_proto_field_name=True)
    resp = requests.post(url + "/api/2/user_group/list", data=body, headers=headers)
    resp.raise_for_status()
    return pbjson.Parse(resp.content, ListResponse())


def user_group_get(url: str, request: GetRequest) -> GetResponse:
    body = pbjson.MessageToJson(request, preserving_proto_field_name=True)
    resp = requests.post(url + "/api/2/user_group/get", data=body, headers=headers)
    resp.raise_for_status()
    return pbjson.Parse(resp.content, GetResponse())


# Crawler methods:
from monocle.crawler_pb2 import AddDocRequest
from monocle.crawler_pb2 import AddDocResponse
from monocle.crawler_pb2 import CommitRequest
from monocle.crawler_pb2 import CommitResponse
from monocle.crawler_pb2 import CommitInfoRequest
from monocle.crawler_pb2 import CommitInfoResponse


def crawler_add_doc(url: str, request: AddDocRequest) -> AddDocResponse:
    body = pbjson.MessageToJson(request, preserving_proto_field_name=True)
    resp = requests.post(url + "/api/2/crawler/add", data=body, headers=headers)
    resp.raise_for_status()
    return pbjson.Parse(resp.content, AddDocResponse())


def crawler_commit(url: str, request: CommitRequest) -> CommitResponse:
    body = pbjson.MessageToJson(request, preserving_proto_field_name=True)
    resp = requests.post(url + "/api/2/crawler/commit", data=body, headers=headers)
    resp.raise_for_status()
    return pbjson.Parse(resp.content, CommitResponse())


def crawler_commit_info(url: str, request: CommitInfoRequest) -> CommitInfoResponse:
    body = pbjson.MessageToJson(request, preserving_proto_field_name=True)
    resp = requests.post(
        url + "/api/2/crawler/get_commit_info", data=body, headers=headers
    )
    resp.raise_for_status()
    return pbjson.Parse(resp.content, CommitInfoResponse())
