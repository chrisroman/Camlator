open Lwt
open Cohttp
open Cohttp_lwt_unix

(* [run cmd] starts a new process using the shell command [cmd]. Then returns
 * the last line of output from this [cmd], or "" if nothing. *)
let run cmd =
  let inp = Unix.open_process_in cmd in
  let rec handle_cmd prev_output =
    begin match input_line inp with
    | exception End_of_file -> prev_output
    | res -> handle_cmd res
    end
  in
  let res = handle_cmd "" in
  ignore(Unix.close_process_in inp);
  res

(* [translate_msg msg pref_lang] is the translated version of [msg] to
 * [pref_lang] using Google Translate. Since it costs money to actually use
 * their API, we run a simple javascript process that generates tokens for us
 * based on some Node.js package to be able to use it.*)
let translate_msg msg pref_lang =
  let ret_output = run ("node ./generate_token.js" ^ " " ^ msg) in
  let tokens = Str.split (Str.regexp_string " ") ret_output in
  let url =
    "http://translate.google.com/translate_a/single?client=t&sl=auto&tl=" ^
    pref_lang ^ "&hl=" ^ pref_lang ^
    "&dt=at&dt=bd&dt=ex&dt=ld&dt=md&dt=qca&dt=rw&dt=rm&dt=ss&dt=t&ie=UTF-8&oe="^
    "UTF-8&otf=1&ssel=0&tsel=0&kc=7&q=" ^
    msg ^ "&" ^ (List.nth tokens 0) ^ "=" ^ (List.nth tokens 1)
  in
  Printf.printf "URL: %s\n" url;
  (* Adapted from Cohttp github examples *)
  Client.get (Uri.of_string url) >>= fun (resp, body) ->
  let code = resp |> Response.status |> Code.code_of_status in
  Printf.printf "Response code: %d\n" code;
  Printf.printf "Headers: %s\n" (resp |> Response.headers |> Header.to_string);
  body |> Cohttp_lwt.Body.to_string >|= fun body ->
  Printf.printf "Body of length: %d\n" (String.length body);
  Printf.printf "Body: %s\n" (body);
  try
    let open Yojson.Basic.Util in
    let lst1 = Yojson.Basic.from_string body |> to_list in
    let lst2 = List.nth lst1 0 |> to_list in
    let lst3 = List.nth lst2 0 |> to_list in
    List.nth lst3 0 |> to_string
  with
    | Yojson.Json_error e ->
        Printf.printf "Got an error: %s" e;
        msg
    | _ -> msg
