%option noyywrap nodefault yylineno
%option reentrant noline

%{
#include <stdio.h>
#include <string.h>
#include <stdlib.h>
#include "carlang.tab.h"

// rastreamento de coluna
static int col = 1;
#define YY_USER_ACTION do { col += yyleng; } while(0)

// helper para strings de identificadores
static char* carlang_strdup(const char* s) {
    size_t n = strlen(s) + 1;
    char* out = (char*)malloc(n);
    if (!out) { fprintf(stderr, "OOM\n"); exit(1); }
    memcpy(out, s, n);
    return out;
}
%}

/* Classes */
LETTER      [A-Za-z_]
DIGIT       [0-9]
ID          {LETTER}({LETTER}|{DIGIT})*
WS          [ \t\r]+
NEWLINE     \n
COMMENT     \/\/[^\n]*

%%

{WS}                    ;               /* ignora espaços/tabs */
{COMMENT}               ;               /* ignora // ... até fim da linha */

{NEWLINE}               { col = 1; /* yylineno já avança automaticamente */ }

/* Palavras-chave (português, ASCII) */
"if"                    { return IF; }
"else"                  { return ELSE; }
"while"                 { return WHILE; }

"acelerar"              { return ACELERAR; }
"frear"                 { return FREAR; }
"virar"                 { return VIRAR; }
"parar"                 { return PARAR; }
"ler"                   { return LER; }

"direita"               { return DIREITA; }
"esquerda"              { return ESQUERDA; }

"velocidade"            { return VELOCIDADE; }
"combustivel"           { return COMBUSTIVEL; }
"posicao"               { return POSICAO; }

/* Símbolos e operadores */
"->"                    { return ARROW; }
"=="                    { return EQ; }
"!="                    { return NEQ; }
">="                    { return GE; }
"<="                    { return LE; }
">"                     { return GT; }
"<"                     { return LT; }

"="                     { return ASSIGN; }
";"                     { return SEMI; }
"{"                     { return LBRACE; }
"}"                     { return RBRACE; }
"("                     { return LPAREN; }
")"                     { return RPAREN; }
"+"                     { return PLUS; }
"-"                     { return MINUS; }
"*"                     { return MUL; }
"/"                     { return DIV; }

/* Tokens com valor */
{ID}                    { yylval.sval = carlang_strdup(yytext); return IDENT; }
{DIGIT}+                { yylval.ival = atoi(yytext); return NUMBER; }

/* Qualquer outro caractere é erro léxico */
.                       {
                            fprintf(stderr, "[Lexer] Caractere inválido: '%s' na linha %d, coluna %d\n",
                                    yytext, yylineno, col);
                            return INVALID;
                        }

%%

/* Expor coluna ao parser para mensagens de erro */
int carlang_column(void) { return col; }
