#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <limits.h>
#include <time.h>
#include <ctype.h>

#include "erl_nif.h"
#include "cmark.h"

#define FORMAT_HTML 1
#define FORMAT_XML 2
#define FORMAT_MAN 3
#define FORMAT_COMMONMARK 4
#define FORMAT_LATEX 5

/*
 * Expose cmark parsers to Elixir via NIF
 *
 * Requires 3 arguments:
 *
 * 1. markdown document (string)
 * 2. formatting options (int)
 * 3. writer to use (int)
 *
 */
static ERL_NIF_TERM render(ErlNifEnv* env, int argc, const ERL_NIF_TERM argv[]) {
  ErlNifBinary  markdown_binary;
  ErlNifBinary  output_binary;
  cmark_node   *doc;
  char         *output;
  size_t        output_len;
  int           options = 0;
  int           format = 1;

  if (argc != 3) {
    return enif_make_badarg(env);
  }

  if(!enif_inspect_binary(env, argv[0], &markdown_binary)){
    return enif_make_badarg(env);
  }

  enif_get_int(env, argv[1], &options);
  enif_get_int(env, argv[2], &format);

  // Ensure we are not outside of the expected range of formats
  if(format < 1 || format > 5){
    return enif_make_badarg(env);
  }

  doc = cmark_parse_document(
    (const char *)markdown_binary.data,
    markdown_binary.size,
    options
  );

  switch (format) {
    case FORMAT_HTML:
      output = cmark_render_html(doc, options);
      break;
    case FORMAT_XML:
      output = cmark_render_xml(doc, options);
      break;
    case FORMAT_MAN:
      output = cmark_render_man(doc, options, 0);
      break;
    case FORMAT_COMMONMARK:
      output = cmark_render_commonmark(doc, options, 0);
      break;
    case FORMAT_LATEX:
      output = cmark_render_latex(doc, options, 0);
      break;
    default: // fallback to something that works
      fprintf(stderr, "cmark_nif: unknown format %d\n", format);
      output = cmark_render_commonmark(doc, options, 0);
  }

  output_len = strlen(output);
  enif_release_binary(&markdown_binary);

  enif_alloc_binary(output_len, &output_binary);
  memcpy(output_binary.data, output, output_len);

  free(output);
  cmark_node_free(doc);

  return enif_make_binary(env, &output_binary);
};

int reload(ErlNifEnv* _env, void** _priv_data, ERL_NIF_TERM _load_info) {
  return 0;
};

int upgrade(ErlNifEnv* _env, void** _priv_data, void** _old_priv_data, ERL_NIF_TERM _load_info) {
  return 0;
};

static ErlNifFunc nif_funcs[] = {
  { "render", 3, render, ERL_NIF_DIRTY_JOB_CPU_BOUND }
};

ERL_NIF_INIT(Elixir.Cmark.Nif, nif_funcs, NULL, reload, upgrade, NULL)
