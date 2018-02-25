open Batteries

module type Client = sig
  (* [t] represents a client of the chat application. It is responsible for
   * updating the local webpage whenever new messages are received, and for
   * sending messages to other clients (via the server). *)
  type t

  (* [info] contains information about a particular client. Examples include
  * name, id, language preference, country. *)
  type info

  (* [new_client] sets up all things necessary to communicate to the server *)
  val new_client : unit -> t

  (* [change_name client new_lang] changes the [client]'s preferred language.
   * Does so asynchronously *)
  val change_language : t -> string -> unit
end
