open Lwt

(* UID of each client *)
let next_uid = ref 0

(* Message log *)
let message_log = ref ""

(* Wrapper around [int] that is an OrderedType *)
module Int = struct
  type t = int
  let compare a b =
    if a < b then -1
    else if a > b then 1
    else 0
end

(* Currently maps some UID to an output channel, but ideally it would map a UID
 * to a Client_Data, which stores all the information about the client (from
 * internal data like their output channel to application data like their name
 * or preferred language) *)
module ChannelMap = Map.Make(Int)
let out_channels = ref ChannelMap.empty

(* [parse_msg msg] takes a [msg] and broadcasts to everyone
 * based on a custom protocol. The main messages that will be sent are of the
 * form "chat <id> <msg>", where <id> is the id of the sender and <msg> is
 * whatever message they're trying to send *)
let parse_msg msg uid =
  begin match Str.bounded_split (Str.regexp_string " ") msg 3 with
    | ["chat"; cid; msg] -> 
        message_log := !message_log ^ "\n" ^ msg;
        ChannelMap.iter
          (fun key oc -> if key <> uid then Lwt_io.write_line oc msg |> ignore;)
          !out_channels;
        Lwt_log.info "Message sent." |> ignore;
    | _ ->
        Lwt_log.info "Unknown command" |> ignore;
  end

(* [process_requests ic oc] is the thread for handling messages coming in from
 * [ic] - some input channel - and returning some data through [oc] - some
 * output channel. *)
let rec process_requests ic oc uid () =
  Lwt_io.read_line_opt ic >>= fun msg ->
  match msg with
  | Some msg -> 
      Lwt_log.info ("Got message: " ^ msg) >>= fun () ->
      parse_msg msg uid;
      process_requests ic oc uid ()
  | None -> 
      out_channels := ChannelMap.remove uid !out_channels;
      Lwt_log.info "Connection closed" >>= return

(* [handle_new_conn conn] starts a [process_requests] thread for [conn],
 * which gets passed whenever a connection has been accepted on the server's
 * socket *)
let handle_new_conn conn =
  let fd = fst conn in
  let ic = Lwt_io.of_fd Lwt_io.Input fd in
  let oc = Lwt_io.of_fd Lwt_io.Output fd in
  let uid = !next_uid in
  out_channels := ChannelMap.add uid oc !out_channels;
  if !message_log <> "" then
    Lwt_io.write_line oc !message_log |> ignore;
  next_uid := !next_uid + 1;
  Lwt.on_failure
    (process_requests ic oc uid ()) 
    (fun e -> Lwt_log.ign_error (Printexc.to_string e));
  Lwt_log.info "New connection" >>= return

(* [accept_connections sock] is a thread that accepts connections indefinitely
 * from [sock] *)
let rec accept_connections sock () =
  Lwt_unix.accept sock >>= handle_new_conn >>= accept_connections sock

(**************** Enable Logging to Terminal ****************)
let () =
  Lwt_log_core.default :=
    Lwt_log.channel
      ~template:"$(date).$(milliseconds) [$(level)] $(message)"
      ~close_mode:`Keep
      ~channel:Lwt_io.stdout
      ();
  Lwt_log_core.add_rule "*" Lwt_log_core.Info;
  Lwt_main.run (Lwt_log_core.info "Started server...")

(******************* Start up the Server *********************)
let () =
  let ip_addr = "127.0.0.1" in (* PLACE YOUR IP ADDRESS HERE*)
  let host_addr = Unix.inet_addr_of_string ip_addr in
  let port = 9000 in
  let backlog = 100 in
  let sock = Lwt_unix.socket Lwt_unix.PF_INET Lwt_unix.SOCK_STREAM 0 in
  Lwt_unix.bind sock (Lwt_unix.ADDR_INET(host_addr, port)) |> ignore;
  Lwt_unix.listen sock backlog;
  Lwt_main.run (accept_connections sock ())

