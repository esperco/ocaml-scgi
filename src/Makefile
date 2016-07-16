NAME = scgi
ML = \
  compatibility.ml \
  http_header.ml \
  http_status.ml \
  netstring.ml \
  response.ml \
  headers.ml \
  http_method.ml \
  request.ml \
  server.ml \
  client.ml

MLI = \
  http_header.mli \
  http_status.mli \
  netstring.mli \
  response.mli \
  headers.mli \
  http_method.mli \
  request.mli \
  server.mli \
  client.mli

CMAS = $(NAME).cma
CMXS = $(NAME).cmx
CMXAS = $(NAME).cmxa
LIBS = $(CMAS) $(CMXS) $(CMXAS)
BUILD = \
  $(addprefix _build/,$(LIBS)) \
  $(addprefix _build/,$(MLI)) \
  _build/$(NAME).cmi \
  _build/$(NAME).a

.PHONY: all install uninstall clean

all:
	ocamlbuild -tag debug $(LIBS)

install:
	ocamlfind install $(NAME) $(BUILD) META

uninstall:
	ocamlfind remove $(NAME)

clean:
	ocamlbuild -clean
