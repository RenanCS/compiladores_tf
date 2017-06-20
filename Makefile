# only works with the Java extension of yacc: 
# byacc/j from http://troi.lincom-asg.com/~rjamison/byacc/

JFLEX  = java -jar jflex.jar 
BYACCJ = ./yacc.linux -tv -J
JAVAC  = javac

# targets:

all: Parser.class

run: Parser.class
	java Parser

build: clean Parser.class

clean:
	rm -f *~ *.class Yylex.java Parser.java y.output

Parser.class: Yylex.java Parser.java
	$(JAVAC) Parser.java

Yylex.java: lexicoT1.flex
	$(JFLEX) lexicoT1.flex

Parser.java: sintaticoT1.y
	$(BYACCJ) sintaticoT1.y
