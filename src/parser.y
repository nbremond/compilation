%{
#include <stdio.h>
#include "types.h"
#include <string.h>

  extern int yylineno;
  int yylex ();
  int yyerror ();
  int np;

  enum primitif base;

  int level;
%}

%token <str> IDENTIFIER
%token <n> ICONSTANT
%token <f> FCONSTANT
%type <t> declarator
%type <pl> parameter_list
%type <pdcl> parameter_declaration
%token INC_OP DEC_OP LE_OP GE_OP EQ_OP NE_OP
%token INT FLOAT VOID
%token IF ELSE WHILE RETURN FOR DO
%union {
  char *str;
  int n;
  float f;
  struct type_t t;
  enum primitif pl[100];
  struct type_t pdcl;
};
%start program
%%

primary_expression
: IDENTIFIER
| ICONSTANT { printf("%d\n", yylval.n); }
| FCONSTANT { printf("%f\n", $1); }
| '(' expression ')'
| IDENTIFIER '(' ')'
| IDENTIFIER '(' argument_expression_list ')'
| IDENTIFIER INC_OP
| IDENTIFIER DEC_OP
| IDENTIFIER '[' expression ']'
;

argument_expression_list
: expression
| argument_expression_list ',' expression
;

unary_expression
: primary_expression
| '-' unary_expression
| '!' unary_expression
;

multiplicative_expression
: unary_expression
| multiplicative_expression '*' unary_expression
;

additive_expression
: multiplicative_expression
| additive_expression '+' multiplicative_expression
| additive_expression '-' multiplicative_expression
;

comparison_expression
: additive_expression
| additive_expression '<' additive_expression
| additive_expression '>' additive_expression
| additive_expression LE_OP additive_expression
| additive_expression GE_OP additive_expression
| additive_expression EQ_OP additive_expression
| additive_expression NE_OP additive_expression
;

expression
: IDENTIFIER '=' comparison_expression
| IDENTIFIER '[' expression ']' '=' comparison_expression
| comparison_expression
;

declaration
: type_name declarator_list ';'
;

declarator_list
: declarator
| declarator_list ',' declarator
;

type_name
: VOID  { base = VOID_T;  }
| INT   { base = INT_T;   }
| FLOAT { base = FLOAT_T; }
;

declarator
: IDENTIFIER { $$.kind = base; $$.taille = 0; $$.isFunction = 0;}
| '*' IDENTIFIER  { $$.kind = base+2; $$.taille = 0; $$.isFunction = 0;}
| IDENTIFIER '[' ICONSTANT ']' { $$.kind = base; $$.taille = $3; $$.isFunction = 0; }
| declarator '(' parameter_list ')' { $$ = $1; $$.taille = 0; $$.isFunction = 1; $$.nbParam = np; memcpy($$.params, $3, sizeof(enum primitif)*np)}
| declarator '(' ')' { $$ = $1; $$.taille = 0; $$.isFunction = 1; $$.nbParam = 0; }
;

parameter_list
: parameter_declaration { np = 1; $$[np] = base;}   
| parameter_list ',' parameter_declaration { memcpy($$, $1, sizeof(enum primitif)*np); $$[np++] = base; }
;

parameter_declaration
: type_name declarator { $$ = $2; }
;

statement
: compound_statement      { level++; }
| expression_statement 
| selection_statement
| iteration_statement
| jump_statement
;

compound_statement
: '{' '}'                                    { level--; }
| '{' statement_list '}'                     { level--; }
| '{' declaration_list statement_list '}'    { level--; }
;

declaration_list
: declaration
| declaration_list declaration
;

statement_list
: statement
| statement_list statement
;

expression_statement
: ';'
| expression ';'
;

selection_statement
: IF '(' expression ')' statement
| IF '(' expression ')' statement ELSE statement
;

iteration_statement
: WHILE '(' expression ')' statement
| FOR '(' expression_statement expression_statement expression ')' statement
| DO statement WHILE '(' expression ')'
;

jump_statement
: RETURN ';'
| RETURN expression ';'
;

program
: external_declaration
| program external_declaration
;

external_declaration
: function_definition
| declaration
;

function_definition
: type_name declarator compound_statement
;

%%
#include <stdio.h>
#include <string.h>
#include "types.h"


extern char yytext[];
extern int column;
extern int yylineno;
extern FILE *yyin;

char *file_name = NULL;

int yyerror (char *s) {
    fflush (stdout);
    fprintf (stderr, "%s:%d:%d: %s\n", file_name, yylineno, column, s);
    return 0;
}


int main (int argc, char *argv[]) {
    FILE *input = NULL;
    if (argc==2) {
	input = fopen (argv[1], "r");
	file_name = strdup (argv[1]);
	if (input) {
	    yyin = input;
	    yyparse();
	}
	else {
	  fprintf (stderr, "%s: Could not open %s\n", *argv, argv[1]);
	    return 1;
	}
	free(file_name);
    }
    else {
	fprintf (stderr, "%s: error: no input file\n", *argv);
	return 1;
    }
    return 0;
}
