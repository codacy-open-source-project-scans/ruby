#include "ruby.h"
#include "ruby/util.h"
#include "rubyspec.h"

#ifdef __cplusplus
extern "C" {
#endif

VALUE util_spec_rb_scan_args(VALUE self, VALUE argv, VALUE fmt, VALUE expected, VALUE acc) {
  int result, argc;
  VALUE a1, a2, a3, a4, a5, a6;

  argc = (int) RARRAY_LEN(argv);
  VALUE* args = RARRAY_PTR(argv);
  /* the line above can be replaced with this for Ruby implementations which do not support RARRAY_PTR() yet
    VALUE args[6];
    for(int i = 0; i < argc; i++) {
      args[i] = rb_ary_entry(argv, i);
    } */

  a1 = a2 = a3 = a4 = a5 = a6 = INT2FIX(-1);

#ifdef RB_SCAN_ARGS_KEYWORDS
  if (*RSTRING_PTR(fmt) == 'k') {
    result = rb_scan_args_kw(RB_SCAN_ARGS_KEYWORDS, argc, args, RSTRING_PTR(fmt)+1, &a1, &a2, &a3, &a4, &a5, &a6);
  } else {
#endif
    result = rb_scan_args(argc, args, RSTRING_PTR(fmt), &a1, &a2, &a3, &a4, &a5, &a6);
#ifdef RB_SCAN_ARGS_KEYWORDS
  }
#endif

  switch(NUM2INT(expected)) {
  case 6:
    rb_ary_unshift(acc, a6);
    /* FALLTHROUGH */
  case 5:
    rb_ary_unshift(acc, a5);
    /* FALLTHROUGH */
  case 4:
    rb_ary_unshift(acc, a4);
    /* FALLTHROUGH */
  case 3:
    rb_ary_unshift(acc, a3);
    /* FALLTHROUGH */
  case 2:
    rb_ary_unshift(acc, a2);
    /* FALLTHROUGH */
  case 1:
    rb_ary_unshift(acc, a1);
    break;
  default:
    rb_raise(rb_eException, "unexpected number of arguments returned by rb_scan_args");
  }

  return INT2NUM(result);
}

static VALUE util_spec_rb_get_kwargs(VALUE self, VALUE keyword_hash, VALUE keys, VALUE required, VALUE optional) {
  int req = FIX2INT(required);
  int opt = FIX2INT(optional);
  int len = RARRAY_LENINT(keys);

  int values_len = req + (opt < 0 ? -1 - opt : opt);

  ID *ids = (ID *)alloca(sizeof(VALUE) * len);
  VALUE *results = (VALUE *)alloca(sizeof(VALUE) * values_len);

  for (int i = 0; i < len; i++) {
    ids[i] = SYM2ID(rb_ary_entry(keys, i));
  }

  int extracted = rb_get_kwargs(keyword_hash, ids, req, opt, results);

  return rb_ary_new_from_values(extracted, results);
}

static VALUE util_spec_rb_long2int(VALUE self, VALUE n) {
  return INT2NUM(rb_long2int(NUM2LONG(n)));
}

static VALUE util_spec_rb_iter_break(VALUE self) {
  rb_iter_break();
  return Qnil;
}

static VALUE util_spec_rb_sourcefile(VALUE self) {
  return rb_str_new2(rb_sourcefile());
}

static VALUE util_spec_rb_sourceline(VALUE self) {
  return INT2NUM(rb_sourceline());
}

static VALUE util_spec_strtod(VALUE self, VALUE string) {
  char *endptr = NULL;
  double value = strtod(RSTRING_PTR(string), &endptr);
  return rb_ary_new_from_args(2, rb_float_new(value), endptr ? rb_str_new2(endptr) : Qnil);
}

static VALUE util_spec_ruby_strtod(VALUE self, VALUE string) {
  char *endptr = NULL;
  double value = ruby_strtod(RSTRING_PTR(string), &endptr);
  return rb_ary_new_from_args(2, rb_float_new(value), endptr ? rb_str_new2(endptr) : Qnil);
}

void Init_util_spec(void) {
  VALUE cls = rb_define_class("CApiUtilSpecs", rb_cObject);
  rb_define_method(cls, "rb_scan_args", util_spec_rb_scan_args, 4);
  rb_define_method(cls, "rb_get_kwargs", util_spec_rb_get_kwargs, 4);
  rb_define_method(cls, "rb_long2int", util_spec_rb_long2int, 1);
  rb_define_method(cls, "rb_iter_break", util_spec_rb_iter_break, 0);
  rb_define_method(cls, "rb_sourcefile", util_spec_rb_sourcefile, 0);
  rb_define_method(cls, "rb_sourceline", util_spec_rb_sourceline, 0);
  rb_define_method(cls, "strtod", util_spec_strtod, 1);
  rb_define_method(cls, "ruby_strtod", util_spec_ruby_strtod, 1);
}

#ifdef __cplusplus
}
#endif
