#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <limits.h>
#include <time.h>
#include <ctype.h>

#include "erl_nif.h"
#include "cmark.h"

static ERL_NIF_TERM to_html_nif(ErlNifEnv* env, int argc, const ERL_NIF_TERM argv[]) {

  ErlNifBinary  markdown_binary;
  ErlNifBinary  output_binary;
  node_block *document = NULL;
  strbuf html = GH_BUF_INIT;

  if (argc != 1) {
    return enif_make_badarg(env);
  }

  if(!enif_inspect_binary(env, argv[0], &markdown_binary)){
    return enif_make_badarg(env);
  }

  if (markdown_binary.size <= 0){
    const char *empty_string = "";
    const int   empty_len    = strlen(empty_string);
    enif_alloc_binary(empty_len, &output_binary);
    strncpy((char*)output_binary.data, empty_string, empty_len);
    return enif_make_binary(env, &output_binary);
  }

  document = cmark_parse_document((unsigned char*)markdown_binary.data, markdown_binary.size);
  cmark_render_html(&html, document);
  enif_alloc_binary(strbuf_len(&html), &output_binary);
  strncpy((char*)output_binary.data, strbuf_cstr(&html), strbuf_len(&html));

  strbuf_free(&html);
  cmark_free_nodes(document);
  enif_release_binary(&markdown_binary);

  return enif_make_binary(env, &output_binary);
}

static ErlNifFunc nif_funcs[] = {
  { "to_html", 1, to_html_nif }
};

ERL_NIF_INIT(Elixir.Cmark.Nif, nif_funcs, NULL, NULL, NULL, NULL);
