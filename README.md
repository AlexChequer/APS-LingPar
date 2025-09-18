# CarLang – Especificação em EBNF

## Objetivo
CarLang é uma linguagem de alto nível para controlar um carro virtual em uma VM.  
A ideia é permitir o controle do carro (acelerar, frear, virar, parar) além do uso e leitura de sensores (velocidade, combustível, posição), com estruturas como **variáveis, condicionais e loops**.

---

## Especificação da Linguagem em EBNF

```ebnf
Program     = { Statement } ;

Statement   = Assignment | IfStmt | WhileStmt | Command ;

Assignment  = Identifier "=" Expression ";" ;

IfStmt      = "if" "(" Condition ")" "{" { Statement } "}" 
              [ "else" "{" { Statement } "}" ] ;

WhileStmt   = "while" "(" Condition ")" "{" { Statement } "}" ;

Command     = DriveCmd ";" | SensorCmd ";" ;

DriveCmd    = "accelerar" "(" Expression ")"      (* aumenta a velocidade *)
            | "frear" "(" Expression ")"          (* reduz a velocidade *)
            | "virar" "(" Direction ")"           (* muda direção *)
            | "parar" ;                           (* velocidade = 0 *)

SensorCmd   = "ler" "(" Sensor ")" "->" Identifier ;

Expression  = Term { ("+" | "-" | "*" | "/") Term } ;
Term        = Number | Identifier | "(" Expression ")" ;

Condition   = Expression RelOp Expression ;
RelOp       = "==" | "!=" | ">" | "<" | ">=" | "<=" ;

Direction   = "esquerda" | "direita" ;
Sensor      = "velocidade" | "combustivel" | "posicao" ;

Identifier  = Letter { Letter | Digit | "_" } ;
Number      = Digit { Digit } ;
```

## Características da Linguagem

- **Variáveis:** armazenam valores numéricos de acordo com a leituras de sensores.  
- **Condicionais:** permitem controle de fluxo com `if/else`.  
- **Loops:** permitem repetição com `while`.  
- **Comandos do carro:**
  - `acelerar(x)` → aumenta velocidade em `x`.
  - `frear(x)` → reduz velocidade em `x`.
  - `virar(direita|esquerda)` → muda direção.
  - `parar` → zera a velocidade.
- **Sensores (somente leitura):**
  - `velocidade`
  - `combustivel`
  - `posicao`

---

## Exemplo de Programa em CarLang

```carlang
ler(combustivel) -> fuel;
while (fuel > 0) {
    accelerar(10);
    ler(velocidade) -> v;
    if (v > 100) {
        frear(20);
    }
    virar(direita);
    ler(combustivel) -> fuel;
}
parar;
```

Descrição:
O programa acelera enquanto houver combustível, reduz a velocidade se ultrapassar 100 km/h e vira à direita em cada iteração. Quando o combustível acaba, o carro para.   
Letter      = "a" - "Z"       
Digit       = "0" - "9"     
