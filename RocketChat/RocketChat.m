BeginPackage["RocketChat`"];

RocketChat::usage = "";
$RocketChatBaseUrl::usage = "";
info::usage = "";
login::usage = "";
logout::usage = "";
me::usage = "";
users::usage = "";
im::usage = "";
chat::usage = "";

Begin["`Private`"];

authToken = ""; (* these are cached privately after login *)
userId = "";

$RocketChatBaseUrl = "http://demo.rocketchat.com/api/v1";

(* Implementation of the REST API located here: https://rocket.chat/docs/developer-guides/rest-api *)

Options[RocketChat] = {
  "Command" -> "info",
  "Method" -> "GET",
  "Headers" -> {},
  "Query" -> {},
  "Body" -> "",
  "ReturnType" -> "RawJSON"
};

RocketChat[ OptionsPattern[] ] := Module[{request, response, result},
  request = HTTPRequest[
    URLBuild[{$RocketChatBaseUrl, OptionValue["Command"] }], <|
      Method -> OptionValue["Method"],
      "Headers" -> OptionValue["Headers"],
      "Query" -> OptionValue["Query"],
      "Body" -> OptionValue["Body"]
    |>
    ];
  response = URLRead[request];
  result = ImportString[response["Body"], OptionValue["ReturnType"]];
  result
  ]

info[] := RocketChat[];

login[username_String,password_String] := Module[{result},
  result = RocketChat[ "Command"->"login", "Method"->"POST", "Headers"-> { "Content-type" -> "application/json" }, "Body" -> ExportString[ <| "username" -> username, "password" -> password |>, "JSON"] ];
  authToken = result["data","authToken"];
  userId = result["data","userId"];
  SetOptions[RocketChat,  "Headers" -> { "X-Auth-Token" -> authToken, "X-User-Id" -> userId } ];
  result
  ]

logout[] := Module[{},
  RocketChat[ "Command"->"logout" ];
  SetOptions[RocketChat,  "Headers" -> {} ];
  ]

me[] := RocketChat[ "Command"->"me"];

(* users *)

users["list"] := RocketChat[ "Command"->"users.list"]
users["info", query_List] := RocketChat[ "Command"->"users.info", "Query"->query]
users["getPresence"] := RocketChat[ "Command"->"users.getPresence"]
users["getPresence", query_List] := RockerChat[ "Command"->"users.getPresence", "Query" ->query]
users["getAvatar", query_List] := RocketChat[ "Command" -> "users.getAvatar", "Query" -> query, "ReturnType" -> Automatic]
users["resetAvatar", query_List] := RocketChat[ "Command" -> "users.resetAvatar", "Query" -> query]

users["setAvatar", "image"->image_Image] := Module[{file},
  file = CreateTemporary[];
  Export[file,image,"PNG"];
  RocketChat[ "Command" -> "users.setAvatar", "Method"->"POST", "Body"->{"image"->File[file]}]
  ]

(* im *)
im["list"] := RocketChat[ "Command"->"im.list" ]

(* chat *)

chat["postMessage", body_List] := RocketChat[
  "Command" -> "chat.postMessage",
  "Method" -> "POST",
  "Headers" -> Join[ OptionValue[ RocketChat, "Headers"], {  "Content-type" -> "application/json" } ],
  "Body" -> ExportString[ body, "JSON"]
  ];


End[]

EndPackage[]
