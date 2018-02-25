(* [process_outgoing_msg oc msg] simply sends [msg] through the out_channel
 * [oc] to whatever client is tied to [oc] *)
val process_outgoing_msg : Lwt_io.output_channel -> string -> unit -> unit Lwt.t

(* [process_incoming_msg ic messages textbox pref_lang] takes any incoming
 * messages from [ic], does translation, and makes the text appear on the GUI
 * [textbox] *)
val process_incoming_msg : Lwt_io.input_channel -> string ref ->
  < set_buffer : GText.buffer -> 'a; .. > ->
  string ref -> unit -> unit Lwt.t

(* [create_channels ()] returns a pair of threads, one for processing incoming
 * messages based on a socket, and one for processesing outgoing messages 
 * based on that same socket. *)
val create_channels : unit ->
  (string ref -> < set_buffer : GText.buffer -> 'a; .. > -> string ref ->
    unit -> unit Lwt.t) *
  (string -> unit -> unit Lwt.t)
