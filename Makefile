BISON=bison
FLEX=flex

# Gera apenas os arquivos C/H
all: parser.c lexer.c carlang.tab.h

parser.c carlang.tab.h: carlang.y
	$(BISON) -d -o parser.c carlang.y

lexer.c: carlang.l carlang.tab.h
	$(FLEX) -o lexer.c carlang.l

clean:
	rm -f parser.c lexer.c carlang.tab.h
