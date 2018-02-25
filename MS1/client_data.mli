open Batteries

module type ClientData = sig
  (* [t] is the data abstraction for a Client. This is used by the Server to
   * store information about the Client *)
  type t

  (* [id] is a unique identifier for [t] *)
  type id = int

  (* [info] contains information about a particular client. Examples include
  * name, id, language preference, country. *)
  type info

  (* [new_client_data info] is the client data for the information [info] *)
  val new_client_data : info -> t 

  (* [change_language cdata new_lang] updates [cdata]'s preferred language and
  * sets it to be [new_lang] *)
  val change_language : t -> string -> t

  (* [change_name cdata name] updates [cdata]'s name to be [name] *)
  val change_name : t -> UTF8.t -> t
end
