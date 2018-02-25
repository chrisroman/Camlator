open Lwt

(**************** Enable Logging to Terminal ****************)
let () =
  Lwt_log_core.default :=
    Lwt_log.channel
      ~template:"$(date).$(milliseconds) [$(level)] $(message)"
      ~close_mode:`Keep
      ~channel:Lwt_io.stdout
      ();
  Lwt_log_core.add_rule "*" Lwt_log_core.Info;
  Lwt_main.run (Lwt_log_core.info "Started client...")

(* [process_outgoing_msg oc msg] simply sends [msg] through the out_channel
 * [oc] to whatever client is tied to [oc] *)
let rec process_outgoing_msg oc msg () =
  Lwt_io.write_line oc msg >>= return

(* [process_incoming_msg ic messages textbox pref_lang] takes any incoming
 * messages from [ic], does translation, and makes the text appear on the GUI
 * [textbox] *)
let rec process_incoming_msg ic messages textbox pref_lang () =
  Lwt_log_core.info "Listening for incoming messages..." >>= fun () ->
  Lwt_io.read_line_opt ic >>= fun msg_opt ->
  match msg_opt with
  | None     -> Lwt_log.info "Connection closed" >>= return
  | Some msg -> 
      Httpclient.translate_msg msg !pref_lang >>= fun tr_msg ->
      let str_utf8 = Glib.Convert.locale_to_utf8 tr_msg in
      messages := !messages ^ "\n\n" ^ str_utf8;
      let n_buff = GText.buffer ~text:(!messages) () in
      textbox#set_buffer n_buff;
      Lwt_log.info ("Got message: " ^ msg) >>=
      process_incoming_msg ic messages textbox pref_lang

(* [create_channels ()] returns a pair of threads, one for processing incoming
 * messages based on a socket, and one for processesing outgoing messages 
 * based on that same socket. *)
let create_channels () =
  let open Lwt_unix in
  let sockfd = Lwt_unix.socket PF_INET SOCK_STREAM 0 in
  let ip_addr = "127.0.0.1" in (* PLACE YOUR IP ADDRESS HERE*)
  let host_addr = Unix.inet_addr_of_string ip_addr in
  let port = 9000 in
  let _ = Lwt_unix.connect sockfd @@ ADDR_INET(host_addr, port) in
  let ic = Lwt_io.of_fd Lwt_io.Input sockfd in
  let oc = Lwt_io.of_fd Lwt_io.Output sockfd in
  (process_incoming_msg ic), (process_outgoing_msg oc)

