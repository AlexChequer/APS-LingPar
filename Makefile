CC=gcc
CFLAGS=-Wall -Wextra -O2

# Em Linux geralmente -lfl; no macOS pode ser -ll
LEXLIB=-lfl

all: carlang

carlang: parser.c lexer.c src/main.c
	$(CC) $(CFLAGS) -o $@ parser.c lexer.c src/main.c $(LEXLIB)

parser.c carlang.tab.h: src/carlang.y
	bison -d -o parser.c src/carlang.y

lexer.c: src/carlang.l carlang.tab.h
	flex -o lexer.c src/carlang.l

clean:
	rm -f carlang parser.c carlang.tab.h lexer.c

test: carlang
	./carlang src/sample.car || true
