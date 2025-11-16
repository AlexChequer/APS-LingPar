%{
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <stdarg.h>

extern int yylex();
extern int yylineno;
extern FILE *yyin;
void yyerror(const char *s);

int parse_errors = 0;

/* ---------- Saída de código ---------- */
FILE *out = NULL;

/* Mapeamento de variáveis → registradores (TIME / POWER) */
char *var1 = NULL;  /* TIME */
char *var2 = NULL;  /* POWER */

/* Retorna 0 para TIME, 1 para POWER */
int reg_of(const char *name) {
    if (!var1) {
        var1 = strdup(name);
        return 0; /* TIME */
    }
    if (strcmp(var1, name) == 0) return 0;

    if (!var2) {
        var2 = strdup(name);
        return 1; /* POWER */
    }
    if (strcmp(var2, name) == 0) return 1;

    fprintf(stderr, "Erro: mais de duas variaveis usadas (%s). A MicrowaveVM so tem dois registradores.\n", name);
    exit(1);
}

/* Emissor de código */
void emit(const char *fmt, ...) {
    va_list ap;
    va_start(ap, fmt);
    vfprintf(out, fmt, ap);
    fprintf(out, "\n");
    va_end(ap);
}

/* Gerador de labels únicos */
int label_count = 0;
int new_label() {
    return label_count++;
}
%}

%union {
    int num;
    char *str;
}

/* tokens com tipos */
%token <num> NUMBER
%token <str> ID

%token IF ELSE WHILE

%token ACCELERAR FREAR VIRAR PARAR
%token LER
%token ESQUERDA DIREITA
%token VELOCIDADE COMBUSTIVEL POSICAO
%token EQ NEQ GT LT GE LE
%token ARROW

/* não-terminais com tipo string */
%type <str> Direction Sensor

%%

/* Programa é uma lista de statements */
Program:
      StmtList
      {
          /* Ao final do programa, garante HALT */
          emit("HALT");
      }
    ;

StmtList:
      /* vazio */
    | StmtList Statement
    ;

Statement:
      Assignment
    | IfStmt
    | WhileStmt
    | Command
    ;

/* Para simplificar o codegen, só tratamos atribuicoes do tipo:
   ID = NUMBER;
*/
Assignment:
      ID '=' NUMBER ';'
      {
          int r = reg_of($1); /* 0 = TIME, 1 = POWER */
          emit("; %s = %d", $1, $3);
          emit("SET %s %d", r ? "POWER" : "TIME", $3);
      }
    ;

/* if (x > N) { ... }  sem else, por simplicidade */
IfStmt:
      IF '(' ID GT NUMBER ')' '{' Program '}'
      {
          int r = reg_of($3);
          int Lend = new_label();

          emit("; if (%s > %d)", $3, $5);
          /* Teste destrutivo simples:
             se registrador == 0, pula bloco;
             senão, executa bloco uma vez (não restauramos valor).
          */
          emit("DECJZ %s L%d", r ? "POWER" : "TIME", Lend);
          /* bloco 'then' já foi emitido por Program */
          emit("L%d:", Lend);
      }
    ;

/* while (x > N) { ... }
   Supondo que x está mapeado para TIME ou POWER.
   A condição é destrutiva: cada iteração consome 1 da variável.
*/
WhileStmt:
      WHILE '(' ID GT NUMBER ')' '{' Program '}'
      {
          int r = reg_of($3);
          int Lstart = new_label();
          int Lend   = new_label();

          emit("; while (%s > %d)", $3, $5);
          emit("L%d:", Lstart);
          emit("DECJZ %s L%d", r ? "POWER" : "TIME", Lend);
          /* corpo do while já foi emitido pelo Program interno */
          emit("GOTO L%d", Lstart);
          emit("L%d:", Lend);
      }
    ;

Command:
      DriveCmd ';'
    | SensorCmd ';'
    ;

/* Comandos de direção/controle.
   Aqui fazemos uma tradução simples para instruções da MicrowaveVM.
*/
DriveCmd:
      ACCELERAR '(' NUMBER ')'
      {
          int n = $3;
          int Lstart = new_label();
          int Lend   = new_label();

          emit("; acelerar(%d)", n);
          emit("SET TIME %d", n);      /* contador em TIME */
          emit("L%d:", Lstart);
          emit("DECJZ TIME L%d", Lend);
          emit("INC POWER");           /* POWER += 1 a cada passo */
          emit("GOTO L%d", Lstart);
          emit("L%d:", Lend);
      }
    | FREAR '(' NUMBER ')'
      {
          int n = $3;
          int Lstart = new_label();
          int Lend   = new_label();

          emit("; frear(%d)", n);
          emit("SET TIME %d", n);      /* contador em TIME */
          emit("L%d:", Lstart);
          emit("DECJZ TIME L%d", Lend);
          /* decrementa POWER, mas para se POWER chegar a zero */
          emit("DECJZ POWER L%d", Lend);
          emit("GOTO L%d", Lstart);
          emit("L%d:", Lend);
      }
    | VIRAR '(' Direction ')'
      {
          /* Não temos direção real na VM; geramos só comentário/no-op */
          emit("; virar(%s)", $3);
      }
    | PARAR
      {
          emit("; parar()");
          emit("SET POWER 0");
      }
    ;

/* Leitura de sensores vira só comentário (no-op) na MicrowaveVM */
SensorCmd:
      LER '(' Sensor ')' ARROW ID
      {
          emit("; ler(%s) -> %s (no-op nesta VM)", $3, $6);
      }
    ;

Direction:
      ESQUERDA    { $$ = "esquerda"; }
    | DIREITA     { $$ = "direita"; }
    ;

Sensor:
      VELOCIDADE  { $$ = "velocidade"; }
    | COMBUSTIVEL { $$ = "combustivel"; }
    | POSICAO     { $$ = "posicao"; }
    ;

%%

void yyerror(const char *s) {
    fprintf(stderr, "Erro sintatico na linha %d: %s\n", yylineno, s);
    parse_errors = 1;
}

int main(int argc, char **argv) {
    if (argc > 1) {
        FILE *f = fopen(argv[1], "r");
        if (!f) { perror("fopen"); return 1; }
        yyin = f;
    }

    out = stdout;   /* gera código na saída padrão */

    parse_errors = 0;
    yyparse();

    if (parse_errors == 0) {
        /* sucesso: código já foi emitido durante a análise */
        return 0;
    } else {
        /* em caso de erro, código parcial pode ter saído, mas retornamos erro */
        return 2;
    }
}
