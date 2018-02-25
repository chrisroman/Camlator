(* List of emojis *)
val emojis_list : string list

(* List of supported languages *)
val languages : string list

(* [lang_to_identifier lang_str] transforms [lang_str] from English-readable
 * representation to a shortened identifier usable by Google Translate API *)
val lang_to_identifier : string -> string
