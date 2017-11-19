BeginPackage["RocketChat`"];

RocketChat::usage = "";
$RocketChatBaseUrl::usage = "";
info::usage = "";
login::usage = "";
logout::usage = "";
me::usage = "";
users::usage = "";
im::usage = "";

Begin["`Private`"];

authToken = ""; (* these are cached privately after login *)
userId = "";

$RocketChatBaseUrl = "http://demo.rocketchat.com/api/v1";

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

users["getAvatar", "userId"->userId_String] := RocketChat[ "Command" -> "users.getAvatar", "Query" -> {"userId" -> userId}, "ReturnType" -> Automatic]

users["getAvatar", "username"->username_String] := RocketChat[ "Command" -> "users.getAvatar", "Query" -> {"username" -> username}, "ReturnType" -> Automatic]

users["setAvatar", "image"->image_Image] := Module[{file},
  file = CreateTemporary[];
  Export[file,image,"PNG"];
  RocketChat[ "Command" -> "users.setAvatar", "Method"->"POST", "Body"->{"image"->File[file]}]
  ]

(* im *)

in["list"] := RocketChat[ "Command"->"im.list" ]

(*)
im["list"] := Module[{request, response},
  request = HTTPRequest[
    URLBuild[{$RocketChatBaseUrl, "im.list"}], <|
      Method -> "GET",
      "Headers" -> { "X-Auth-Token" -> authToken, "X-User-Id" -> userId }
    |>
  ];
  response = URLRead[request];
  ImportString[response["Body"], "RawJSON"]
  ]
*)
End[]

EndPackage[]



(*

api = <|

 "info" -> "info", "auth" -> False, "method" -> "GET",
 "login" -> "login", "auth" -> False, "method" -> "POST", "data" ->
 "logout" -> "logout",
 "me" -> "me",
 "users.create" -> "users.create",
 "users.delete" -> "users.delete",
 "users.getPresence" -> "users.getPresence",
 "users.info" -> "users.info",
 "users.list" -> "users.list",
 "users.setAvatar" -> "users.setAvatar",
 "users.update" -> "users.update",
 "channels.addAll" -> "channels.addAll",
 "channels.archive" -> "channels.archive",
 "channels.cleanHistory" -> "channels.cleanHistory",
 "channels.close" -> "channels.close",
 "channels.create" -> "channels.create",
 "channels.getIntegrations" -> "channels.getIntegrations",
 "channels.history" -> "channels.history",
 "channels.info" -> "channels.info",
 "channels.invite" -> "channels.invite",
 "channels.kick" -> "channels.kick",
 "channels.leave" -> "channels.leave",
 "channels.list" -> "channels.list",
 "channels.list.joined" -> "channels.list.joined",
 "channels.open" -> "channels.open",
 "channels.rename" -> "channels.rename",
 "channels.setDescription" -> "channels.setDescription",
 "channels.setJoinCode" -> "channels.setJoinCode",
 "channels.setPurpose" -> "channels.setPurpose",
 "channels.setReadOnly" -> "channels.setReadOnly",
 "channels.setTopic" -> "channels.setTopic",
 "channels.setType" -> "channels.setType",
 "channels.unarchive" -> "channels.unarchive",
 "groups.archive" -> "groups.archive",
 "groups.close" -> "groups.close",
 "groups.create" -> "groups.create",
 "groups.history" -> "groups.history",
 "groups.info" -> "groups.info",
 "groups.invite" -> "groups.invite",
 "groups.kick" -> "groups.kick",
 "groups.leave" -> "groups.leave",
 "groups.list" -> "groups.list",
 "groups.open" -> "groups.open",
 "groups.rename" -> "groups.rename",
 "groups.setDescription" -> "groups.setDescription",
 "groups.setPurpose" -> "groups.setPurpose",
 "groups.setReadOnly" -> "groups.setReadOnly",
 "groups.setTopic" -> "groups.setTopic",
 "groups.setType" -> "groups.setType",
 "groups.unarchive" -> "groups.unarchive",
 "chat.delete" -> "chat.delete",
 "chat.postMessage" -> "chat.postMessage",
 "chat.update" -> "chat.update",
 "im.close" -> "im.close",
 "im.history" -> "im.history",
 "im.messages.others" -> "im.messages.others",
 "im.list" -> "im.list",
 "im.list.everyone" -> "im.list.everyone",
 "im.open" -> "im.open",
 "im.setTopic" -> "im.setTopic",
 "settings/:_id" -> "settings/:_id"

|>;

*)
