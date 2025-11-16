# Makefile para CarLang (Flex + Bison) - usa libfl do Homebrew quando disponível

FL_LIB := $(shell test -f /opt/homebrew/opt/flex/lib/libfl.a && echo /opt/homebrew/opt/flex/lib/libfl.a || echo -lfl)

.PHONY: all carlang lexer parser clean run

all: carlang

carlang: parser.tab.c lex.yy.c
	gcc -o carlang parser.tab.c lex.yy.c $(FL_LIB)

parser.tab.c parser.tab.h: parser.y
	bison -d parser.y

lex.yy.c: lexer.l parser.tab.h
	flex lexer.l

lexer: lex.yy.c
	@echo "Lexer gerado: lex.yy.c"

parser: parser.tab.c
	@echo "Parser gerado: parser.tab.c parser.tab.h"

run: carlang
	@if [ -f a.carlang ]; then \
	  ./carlang a.carlang; \
	else \
	  echo "Arquivo a.carlang não encontrado. Crie um arquivo de teste e rode 'make run' novamente."; \
	fi

clean:
	rm -f carlang parser.tab.c parser.tab.h lex.yy.c
