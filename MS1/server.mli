open Batteries

module type Server = sig
  (* [t] is a Server used to process inputs from various users. Functionality
   * includes -- but is not limited to -- translating and transferring text 
   * from one user to another. *)
  type t

  (* [new_server port] creates a new server that will listen on port [port] *)
  val new_server : int -> t

  (* [run server] launches [server] which starts listening for potential
   * requests from clients *)
  val run : t -> unit

  (* [history_of_id user_id] is the message history of User [u] with id 
   * [user_id], which is in the preferred language of [u] *)
  val history_of_id : int -> UTF8.t list

  (* [send_to_all msg] sends [msg] to all clients. Returns true if successfully
   * sent to everyone, and false otherwise *)
  val send_to_all : UTF8.t -> bool

  (* [translate msg lang] is a translated version of the input text into the
   * specified language *)
  val translate : UTF8.t -> string -> UTF8.t
end
