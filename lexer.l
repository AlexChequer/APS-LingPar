%option noyywrap
%option yylineno

%{
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "parser.tab.h"
%}

%%
[ \t\r\n]+                       { }

"if"                              { return IF; }
"else"                            { return ELSE; }
"while"                           { return WHILE; }

"accelerar"                       { return ACCELERAR; }
"frear"                           { return FREAR; }
"virar"                           { return VIRAR; }
"parar"                           { return PARAR; }

"ler"                             { return LER; }

"esquerda"                        { return ESQUERDA; }
"direita"                         { return DIREITA; }

"velocidade"                      { return VELOCIDADE; }
"combustivel"                     { return COMBUSTIVEL; }
"posicao"                         { return POSICAO; }

"=="                              { return EQ; }
"!="                              { return NEQ; }
">="                              { return GE; }
"<="                              { return LE; }
">"                               { return GT; }
"<"                               { return LT; }

"->"                              { return ARROW; }

[0-9]+                            { yylval.num = atoi(yytext); return NUMBER; }

[a-zA-Z][a-zA-Z0-9_]*             { yylval.str = strdup(yytext); return ID; }

";"                               { return ';'; }
"("                               { return '('; }
")"                               { return ')'; }
"{"                               { return '{'; }
"}"                               { return '}'; }
"="                               { return '='; }
"+"                               { return '+'; }
"-"                               { return '-'; }
"*"                               { return '*'; }
"/"                               { return '/'; }

.                                 { fprintf(stderr, "Linha %d: caractere desconhecido: '%s'\n", yylineno, yytext); }
%%