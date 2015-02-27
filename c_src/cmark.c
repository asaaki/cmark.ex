#include <stdlib.h>
#include <assert.h>
#include <stdio.h>
#include "node.h"
#include "houdini.h"
#include "cmark.h"
#include "buffer.h"

const int cmark_version = CMARK_VERSION;
const char cmark_version_string[] = CMARK_VERSION_STRING;

char *cmark_markdown_to_html(const char *text, int len)
{
	cmark_node *doc;
	char *result;

	doc = cmark_parse_document(text, len, CMARK_OPT_DEFAULT);

	result = cmark_render_html(doc, CMARK_OPT_DEFAULT);
	cmark_node_free(doc);

	return result;
}

