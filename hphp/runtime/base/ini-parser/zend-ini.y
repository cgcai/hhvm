%{
/*
   +----------------------------------------------------------------------+
   | HipHop for PHP                                                       |
   +----------------------------------------------------------------------+
   | Copyright (c) 2010 Facebook, Inc. (http://www.facebook.com)          |
   | Copyright (c) 1998-2010 Zend Technologies Ltd. (http://www.zend.com) |
   +----------------------------------------------------------------------+
   | This source file is subject to version 2.00 of the Zend license,     |
   | that is bundled with this package in the file LICENSE, and is        |
   | available through the world-wide-web at the following url:           |
   | http://www.zend.com/license/2_00.txt.                                |
   | If you did not receive a copy of the Zend license and are unable to  |
   | obtain it through the world-wide-web, please send a note to          |
   | license@zend.com so we can mail you a copy immediately.              |
   +----------------------------------------------------------------------+
*/

#define YYERROR_VERBOSE
#define YYSTYPE std::string

#include "hphp/runtime/base/complex-types.h"
#include "hphp/runtime/base/ini-setting.h"
#include "hphp/runtime/base/externals.h"
#include "hphp/runtime/base/ini-parser/zend-ini.h"
#include "hphp/runtime/ext/ext_misc.h"
using namespace HPHP;

///////////////////////////////////////////////////////////////////////////////
// helpers

static void zend_ini_do_op(char type, std::string &result,
                           const std::string& op1, const std::string& op2 = std::string()) {
  int i_op1 = strtoll(op1.c_str(), nullptr, 10);
  int i_op2 = strtoll(op2.c_str(), nullptr, 10);

  int i_result = 0;
  switch (type) {
    case '|': i_result = i_op1 | i_op2; break;
    case '&': i_result = i_op1 & i_op2; break;
    case '^': i_result = i_op1 ^ i_op2; break;
    case '~': i_result = ~i_op1;        break;
    case '!': i_result = !i_op1;        break;
  }

  result = std::to_string((int64_t)i_result);
}

static void zend_ini_get_constant(std::string &result, const std::string& name) {
  if (f_defined(name)) {
    result = f_constant(name).toString().toCppString();
  } else {
    result = name;
  }
}

static void zend_ini_get_var(std::string &result, const std::string& name) {
  std::string curval;
  if (IniSetting::Get(name, curval)) {
    result = curval;
    return;
  }

  char *value = getenv(name.data());
  if (value) {
    result = std::string(value);
    return;
  }

  result.clear();
}

%}

///////////////////////////////////////////////////////////////////////////////

%expect 0
%pure_parser

%token TC_SECTION
%token TC_RAW
%token TC_CONSTANT
%token TC_NUMBER
%token TC_STRING
%token TC_WHITESPACE
%token TC_LABEL
%token TC_OFFSET
%token TC_DOLLAR_CURLY
%token TC_VARNAME
%token TC_QUOTED_STRING
%token BOOL_TRUE
%token BOOL_FALSE
%token END_OF_LINE
%token JUNK
%token '=' ':' ',' '.' '"' '\'' '^' '+' '-' '/' '*' '%' '$' '~' '<' '>' '?' '@' '{' '}'
%left '|' '&' '^'
%right '~' '!'

%%

///////////////////////////////////////////////////////////////////////////////

statement_list:
    statement_list statement
  |  /* empty */
;

statement:
    TC_SECTION section_string_or_value ']' {
      zend_ini_callback(&$2, NULL, NULL, IniSetting::ParserSection);
    }
  |  TC_LABEL '=' string_or_value {
      zend_ini_callback(&$1, &$3, NULL, IniSetting::ParserEntry);
    }
  |  TC_OFFSET option_offset ']' '=' string_or_value {
      zend_ini_callback(&$1, &$5, &$2, IniSetting::ParserPopEntry);
    }
  |  TC_LABEL  {
      zend_ini_callback(&$1, NULL, NULL, IniSetting::ParserEntry);
    }
  |  END_OF_LINE
;

section_string_or_value:
     var_string_list                        { $$ = $1;}
  |  /* empty */                            { $$ = "";}
;

string_or_value:
     expr                                   { $$ = $1;}
  |  BOOL_TRUE                              { $$ = $1;}
  |  BOOL_FALSE                             { $$ = $1;}
  |  END_OF_LINE                            { $$ = "";}
;

option_offset:
    var_string_list                         { $$ = $1;}
  |  /* empty */                            { $$.clear();}
;

encapsed_list:
     encapsed_list cfg_var_ref              { $$ = $1 + $2;}
  |  encapsed_list TC_QUOTED_STRING         { $$ = $1 + $2;}
  |  /* empty */                            { $$ = "";}
;

var_string_list:
     cfg_var_ref                             { $$ = $1;}
  |  constant_string                         { $$ = $1;}
  |  '"' encapsed_list '"'                   { $$ = $2;}
  |  var_string_list cfg_var_ref             { $$ = $1 + $2;}
  |  var_string_list constant_string         { $$ = $1 + $2;}
  |  var_string_list '"' encapsed_list '"'   { $$ = $1 + $3;}
;

expr:
     var_string_list                        { $$ = $1;}
  |  expr '|' expr                          { zend_ini_do_op('|', $$, $1, $3);}
  |  expr '&' expr                          { zend_ini_do_op('&', $$, $1, $3);}
  |  expr '^' expr                          { zend_ini_do_op('^', $$, $1, $3);}
  |  '~' expr                               { zend_ini_do_op('~', $$, $2    );}
  |  '!' expr                               { zend_ini_do_op('!', $$, $2    );}
  |  '(' expr ')'                           { $$ = $2;}
;

cfg_var_ref:
     TC_DOLLAR_CURLY TC_VARNAME '}'         { zend_ini_get_var($$, $2);}
;

constant_string:
     TC_CONSTANT                            { zend_ini_get_constant($$, $1);}
  |  TC_RAW                                 { $$ = $1;}
  |  TC_NUMBER                              { $$ = $1;}
  |  TC_STRING                              { $$ = $1;}
  |  TC_WHITESPACE                          { $$ = $1;}
;

%%

///////////////////////////////////////////////////////////////////////////////
// exposed to runtime/base/ini-setting.cpp

bool zend_parse_ini_string(const std::string& str, const std::string& filename,
                           int scanner_mode,
                           IniSetting::PFN_PARSER_CALLBACK callback,
                           void *arg) {
  zend_ini_scan(str, scanner_mode, filename, callback, arg);
  bool ret = (ini_parse() == 0);
  zend_ini_scan_cleanup();
  return ret;
}
