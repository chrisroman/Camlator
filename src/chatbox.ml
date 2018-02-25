open Printf
open GMain
open GdkKeysyms
let (>>=) = Lwt.bind
let messages = ref "Welcome to the CS3110 chatroom!"
let pref_lang = ref "en"
let user_name = ref "Camlator User"
(* Get threads to communicate *)
let start_recv, start_send = Chatclient.create_channels ()

(* Changes the preferred language once an option is clicked in the 
 * language combo box *)
let changed_and_get_active (combo : #GEdit.combo_box) column cb =
  combo#connect#changed
    (fun () ->
      match combo#active_iter with
      | None -> ()
      | Some row ->  
    let data = combo#model#get ~row ~column in

    let lang = Stringliterals.lang_to_identifier data in
    pref_lang := lang;

    cb !pref_lang)

(* Setups the combobox for the Language selection drop down *)
let setup_combobox_text packing =  
  let tmp = GBin.frame ~label:"Language" ~packing () in
  let box = GPack.vbox ~border_width:8 ~packing:tmp#add () in
  let (combo, (_, column)) = 
    GEdit.combo_box_text ~packing:box#pack 
      ~strings: Stringliterals.languages () in
  combo#set_active 0;
  ignore (changed_and_get_active combo column prerr_endline);
  ()

(* Sends message to textbox after enter is pressed in the entry box *)
let send_message entry text =
  let entry_text = entry#text in
  printf "Entry contents: %s\n" entry_text;
  entry#set_text "";
  let str_utf8 = Glib.Convert.locale_to_utf8 entry_text in
  messages := !messages ^ "\n\n" ^ !user_name ^ ": " ^ str_utf8;
  let n_buff = GText.buffer ~text:(!messages) () in
  text#set_buffer n_buff;
  flush stdout;
  start_send ("chat 1 " ^ !user_name ^ ": " ^str_utf8) () |> ignore;
  ()

(* Changes the person's username in the messenger app *) 
let change_name entry text =
  let entry_text = entry#text in
  printf "Name changed to: %s\n" entry_text;
  entry#set_text entry#text;
  let name_change = entry#text in 
  let str_utf8 = Glib.Convert.locale_to_utf8 (name_change) in 
  messages := !messages ^ "\n\n" ^ !user_name ^ " changed their name to: " ^ str_utf8;
  user_name := str_utf8;
  let n_buff = GText.buffer ~text:(!messages) () in
  text#set_buffer n_buff;
  flush stdout;
  start_send ("chat 1 " ^ !user_name ^ " changed their name to: " ^ str_utf8) () |> ignore;
  ()

let setup_threads () =
  (* Initializes GTK. *)
  ignore (GMain.init ());

  (* Install Lwt<->Glib integration. *)
  Lwt_glib.install ();

  (* Thread which is wakeup when the main window is closed. *)
  let waiter, wakener = Lwt.wait () in

  let window=GWindow.window ~title: "Camalator Messenger" ~width: 680 ~height: 500 
            ~allow_grow:true ~allow_shrink:true () in
  window#connect#destroy ~callback:Main.quit |> ignore;

  let vbox = GPack.vbox ~packing: window#add () in

  (* Menu bar *)
  let menubar = GMenu.menu_bar ~packing:vbox#pack () in
  let factory = new GMenu.factory menubar in
  let accel_group = factory#accel_group in 
  let file_menu = factory#add_submenu "Menu" in
  ignore(accel_group); 
  ignore(file_menu); 

  (* Text box for messages *)
  let scrollwin = GBin.scrolled_window ~width: 400 ~height: 400  ~packing:vbox#add () in
  let text = GText.view ~packing: scrollwin#add () in 
  text#buffer#insert "Welcome to the CS3110 chatroom!"; 

  (* text#misc#set_size_chars ~width:20 ~height:5 (); *)
  let entry = GEdit.entry ~max_length: 5000 ~packing: vbox#add () in
  entry#connect#activate ~callback:(fun () -> send_message entry text)
   |> ignore;
  entry#set_text "Send";
  entry#append_text " Message Here!";
  entry#select_region ~start:0 ~stop:entry#text_length;

  let hbox = GPack.hbox ~packing: vbox#add () in

  (* Handles the printing of the emojis to the entry box *)
  let changed_and_get_active_emojis (combo : #GEdit.combo_box) column cb entry =
    combo#connect#changed
      (fun () -> match combo#active_iter with
        | None -> ()
        | Some row ->  
            let emoji = combo#model#get ~row ~column in
            let curr_text = entry#text in 
            entry#set_text curr_text;
            entry#append_text " ";
            entry#append_text emoji;
            cb emoji)
  in

  (* The setup for the combobox for emojis *)
  let setup_combobox_emojis packing =  
    let tmp = GBin.frame ~label:"Emojis" ~packing () in
    let box = GPack.vbox ~border_width:8 ~packing:tmp#add () in
    let (combo, (_, column)) = 
      GEdit.combo_box_text ~packing:box#pack 
        ~strings: Stringliterals.emojis_list ()
    in
    combo#set_active 0 ;
    changed_and_get_active_emojis combo column prerr_endline entry;
  in 

  setup_combobox_text hbox#pack; 

  (* Make the User name's frames and text box *)
  let namebox = GPack.vbox ~packing: (hbox#pack ~padding: 30) () in
  let tmp = GBin.frame ~label:"Name" ~packing: namebox#add () in
  let box = GPack.vbox ~border_width:8 ~packing:tmp#add () in
  let name = GEdit.entry ~max_length: 50 ~packing:(box#pack )() in
  name#connect#activate ~callback:(fun () -> change_name name text)
   |> ignore;
  name#set_text "Camlator User";
  entry#select_region ~start:0 ~stop:entry#text_length;

  ignore (setup_combobox_emojis hbox#pack);
  let button = GButton.button ~label: "Close" ~packing:(hbox#pack ~padding:15) () in
  button#connect#clicked ~callback:window#destroy |> ignore;
  button#grab_default ();

  (* Quit when the window is closed. *)
  ignore (window#connect#destroy (Lwt.wakeup wakener));

  window#show ();

  (* Wait for it to be closed. *)
  (waiter, start_recv messages text pref_lang)

(* Start the GUI *)
let () =
  let start_gui, handle_incoming_msg = setup_threads () in
  let threads = Lwt.join [
    start_gui;
    handle_incoming_msg ();
  ] in
  Lwt_main.run threads
