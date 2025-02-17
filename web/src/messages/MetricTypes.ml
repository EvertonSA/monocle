[@@@ocaml.warning "-27-30-39"]


type metric_info = {
  name : string;
  description : string;
  long_description : string;
  metric : string;
}

type list_request = {
  void : string;
}

type list_response = {
  metrics : metric_info list;
}

type trend = {
  interval : string;
}

type get_request_options =
  | Trend of trend

and get_request = {
  index : string;
  username : string;
  query : string;
  metric : string;
  options : get_request_options;
}

type histo_int = {
  date : string;
  count : int32;
}

type histo_float = {
  date : string;
  count : float;
}

type histo_int_stat = {
  histo : histo_int list;
}

type histo_float_stat = {
  histo : histo_float list;
}

type get_response =
  | Error of string
  | Float_value of float
  | Int_value of int32
  | Histo_int_value of histo_int_stat
  | Histo_float_value of histo_float_stat

let rec default_metric_info 
  ?name:((name:string) = "")
  ?description:((description:string) = "")
  ?long_description:((long_description:string) = "")
  ?metric:((metric:string) = "")
  () : metric_info  = {
  name;
  description;
  long_description;
  metric;
}

let rec default_list_request 
  ?void:((void:string) = "")
  () : list_request  = {
  void;
}

let rec default_list_response 
  ?metrics:((metrics:metric_info list) = [])
  () : list_response  = {
  metrics;
}

let rec default_trend 
  ?interval:((interval:string) = "")
  () : trend  = {
  interval;
}

let rec default_get_request_options () : get_request_options = Trend (default_trend ())

and default_get_request 
  ?index:((index:string) = "")
  ?username:((username:string) = "")
  ?query:((query:string) = "")
  ?metric:((metric:string) = "")
  ?options:((options:get_request_options) = Trend (default_trend ()))
  () : get_request  = {
  index;
  username;
  query;
  metric;
  options;
}

let rec default_histo_int 
  ?date:((date:string) = "")
  ?count:((count:int32) = 0l)
  () : histo_int  = {
  date;
  count;
}

let rec default_histo_float 
  ?date:((date:string) = "")
  ?count:((count:float) = 0.)
  () : histo_float  = {
  date;
  count;
}

let rec default_histo_int_stat 
  ?histo:((histo:histo_int list) = [])
  () : histo_int_stat  = {
  histo;
}

let rec default_histo_float_stat 
  ?histo:((histo:histo_float list) = [])
  () : histo_float_stat  = {
  histo;
}

let rec default_get_response () : get_response = Error ("")
