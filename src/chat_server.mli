(* [parse_msg msg] takes a [msg] and broadcasts to everyone
 * based on a custom protocol. The main messages that will be sent are of the
 * form "chat <id> <msg>", where <id> is the id of the sender and <msg> is
 * whatever message they're trying to send *)
val parse_msg : string -> int -> unit

(* [process_requests ic oc] is the thread for handling messages coming in from
 * [ic] - some input channel - and returning some data through [oc] - some
 * output channel. *)
val process_requests : Lwt_io.input_channel -> 'a -> int -> unit
  -> unit Lwt.t

(* [handle_new_conn conn] starts a [process_requests] thread for [conn],
 * which gets passed whenever a connection has been accepted on the server's
 * socket *)
val handle_new_conn : Lwt_unix.file_descr * 'a -> unit Lwt.t

(* [accept_connections sock] is a thread that accepts connections indefinitely
 * from [sock] *)
val accept_connections : Lwt_unix.file_descr -> unit -> 'a Lwt.t
