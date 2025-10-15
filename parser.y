%{
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

extern int yylex();
extern int yylineno;
extern FILE *yyin;
void yyerror(const char *s);

int parse_errors = 0;
%}

%union {
    int num;
    char *str;
}

%token <num> NUMBER
%token <str> ID

%token IF ELSE WHILE

%token ACCELERAR FREAR VIRAR PARAR
%token LER
%token ESQUERDA DIREITA
%token VELOCIDADE COMBUSTIVEL POSICAO
%token EQ NEQ GT LT GE LE
%token ARROW

%left '+' '-'
%left '*' '/'

%%

Program:
      /* vazio */
    | Program Statement
    ;

Statement:
      Assignment
    | IfStmt
    | WhileStmt
    | Command
    ;

Assignment:
      ID '=' Expression ';'
    ;

IfStmt:
      IF '(' Condition ')' '{' Program '}' opt_else
    ;

opt_else:
      /* vazio */
    | ELSE '{' Program '}'
    ;

WhileStmt:
      WHILE '(' Condition ')' '{' Program '}'
    ;

Command:
      DriveCmd ';'
    | SensorCmd ';'
    ;

DriveCmd:
      ACCELERAR '(' Expression ')'
    | FREAR '(' Expression ')'
    | VIRAR '(' Direction ')'
    | PARAR
    ;

SensorCmd:
      LER '(' Sensor ')' ARROW ID
    ;

Expression:
      Expression '+' Expression
    | Expression '-' Expression
    | Expression '*' Expression
    | Expression '/' Expression
    | Term
    ;

Term:
      NUMBER
    | ID
    | '(' Expression ')'
    ;

Condition:
      Expression RelOp Expression
    ;

RelOp:
      EQ
    | NEQ
    | GT
    | LT
    | GE
    | LE
    ;

Direction:
      ESQUERDA
    | DIREITA
    ;

Sensor:
      VELOCIDADE
    | COMBUSTIVEL
    | POSICAO
    ;

%%

void yyerror(const char *s) {
    fprintf(stderr, "Erro sintático na linha %d: %s\n", yylineno, s);
    parse_errors = 1;
}

int main(int argc, char **argv) {
    if (argc > 1) {
        FILE *f = fopen(argv[1], "r");
        if (!f) { perror("fopen"); return 1; }
        yyin = f;
    }
    parse_errors = 0;
    yyparse();
    if (parse_errors == 0) {
        printf("Programa valido (analise lexica + sintatica OK).\n");
        return 0;
    } else {
        printf("Programa invalido (erros sintaticos encontrados).\n");
        return 2;
    }
}
