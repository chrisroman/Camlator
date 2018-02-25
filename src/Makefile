.PHONY: all

default: all

server:
	ocamlbuild chat_server.ml -pkg lwt -pkg lwt.unix -pkg str chat_server.byte
chatbox:
	ocamlbuild -use-ocamlfind -pkgs 'lablgtk2.auto-init lwt lwt_glib cohttp cohttp-lwt-unix str yojson' 'chatbox.byte'
	npm install --save google-translate-token

all: server chatbox

clean:
	ocamlbuild -clean
	rm -rf chatbox.byte chat_server.byte node_modules
