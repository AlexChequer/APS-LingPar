%{
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

/* Protótipos gerados pelo Flex reentrante */
int yylex(YYSTYPE *yylval_param, void *yyscanner);
void yyerror(void *scanner, const char *s);

/* Para imprimir coluna vinda do lexer */
int carlang_column(void);
%}

/* Habilitar parser reentrante */
%define api.pure full
%define api.value.type {union}
%define parse.error verbose

%code requires {
    /* Tipos do yylval */
    typedef union {
        int ival;
        char* sval;
    } YYSTYPE;
}

/* Tokens */
%token IF ELSE WHILE
%token ACELERAR FREAR VIRAR PARAR LER
%token DIREITA ESQUERDA
%token VELOCIDADE COMBUSTIVEL POSICAO
%token ARROW
%token EQ NEQ GE LE GT LT
%token ASSIGN SEMI LBRACE RBRACE LPAREN RPAREN
%token PLUS MINUS MUL DIV
%token IDENT NUMBER
%token INVALID

/* Precedência dos operadores aritméticos e relacionais */
%left PLUS MINUS
%left MUL DIV
%left EQ NEQ GT LT GE LE

/* Tipos (não precisamos de AST agora; só validar) */
%type <ival> Expression Term
%type <ival> Condition
%type <sval> Identifier

%%

Program
    : /* vazio -> permite arquivo vazio */ 
    | Program Statement
    ;

Statement
    : Assignment
    | IfStmt
    | WhileStmt
    | Command
    ;

Assignment
    : Identifier ASSIGN Expression SEMI
        { free($1); /* nada semântico nesta etapa */ }
    ;

IfStmt
    : IF LPAREN Condition RPAREN LBRACE StmtList RBRACE
    | IF LPAREN Condition RPAREN LBRACE StmtList RBRACE ELSE LBRACE StmtList RBRACE
    ;

WhileStmt
    : WHILE LPAREN Condition RPAREN LBRACE StmtList RBRACE
    ;

StmtList
    : /* vazio */
    | StmtList Statement
    ;

Command
    : ACELERAR LPAREN Expression RPAREN SEMI
    | FREAR    LPAREN Expression RPAREN SEMI
    | VIRAR    LPAREN Direction  RPAREN SEMI
    | PARAR    SEMI
    | LER      LPAREN Sensor     RPAREN ARROW Identifier SEMI
        { free($6); }
    ;

Direction
    : DIREITA
    | ESQUERDA
    ;

Sensor
    : VELOCIDADE
    | COMBUSTIVEL
    | POSICAO
    ;

Condition
    : Expression RelOp Expression
        { $$ = 0; }
    ;

RelOp
    : EQ | NEQ | GT | LT | GE | LE
    ;

Expression
    : Expression PLUS  Term  { $$ = 0; }
    | Expression MINUS Term  { $$ = 0; }
    | Term                   { $$ = 0; }
    ;

Term
    : Term MUL Term          { $$ = 0; }
    | Term DIV Term          { $$ = 0; }
    | LPAREN Expression RPAREN { $$ = 0; }
    | NUMBER                 { $$ = $1; }
    | Identifier             { free($1); $$ = 0; }
    ;

Identifier
    : IDENT
    ;

%%

void yyerror(void *scanner, const char *s) {
    /* yylineno é global do Flex; coluna vem de função exposta no .l */
    extern int yylineno;
    fprintf(stderr, "[Parser] %s na linha %d, coluna %d\n", s, yylineno, carlang_column());
}
