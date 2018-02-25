(* [translate_msg msg pref_lang] is the translated version of [msg] to
 * [pref_lang] using Google Translate. Since it costs money to actually use
 * their API, we run a simple javascript process that generates tokens for us
 * based on some Node.js package to be able to use it.*)
val translate_msg : string -> string -> string Lwt.t
