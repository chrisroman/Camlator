# Camlator
Final project repo for CS 3110 

OCaml External Dependencies: (can get these using `opam install`)
lablgtk
lwt
lwt_glib
cohttp
cohttp-lwt-unix
str
yojson

Completely External Dependencies (outside of OCaml):
Node.js


How to Run Camlator: 
Note that all the clients and servers may need to be connected to the same wifi.

To start Camlator you must first configure the IP address you will be using in
the source code by going to line 90 of `src/chat_server.ml` and changing the
variable ip_addr to your IP address. Similarly, you have to do the same in the 
`src/chatclient.ml` in line 42. You can put in `127.0.0.1` to run it locally.

After configuring the IP address in `src/chat_server.ml` and
`src/chatclient.ml`, then you are all set to run Camlator. In the `src`
directory, and `make`.

To run Camlator, the server MUST be running first. So first, go to the `src`
directory and run `./chat_server.byte`. Only one person may run the server.
If there is an error running this because of a bind issue, wait for a minute or
so. If this doesn't work, change the port on lines 92 of `src/chat_server.ml`
and line 44 of `src/chat_client.ml`.

In a different terminal (or the same one if you ran `./chat_server.byte` in the
background), you can now run `./chatbox.byte` to start up the GUI for a client.
You can run this in as many terminals as you want to spawn clients on your
machine.

You can clean up everything by running `make clean`.
