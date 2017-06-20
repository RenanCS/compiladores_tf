%{
  import java.io.*;
%}
   
%token CLASS, PUBLIC, STATIC, VOID,MAIN , STRING, STRINGAF EXTENDS, RETURN, INT, BOOL
%token IF, ELSE, WHILE, LEN, PRINT, TRUE, FALSE, NEW, AND, THIS 
%token Identifier, INTEGER_LITERAL 

%right '='
%nonassoc '<'
%left AND
%left '-' '+'
%left '*'
%right '!'
%left '.'
%left '['

%type <sval> Identifier
%type <obj> Type
%type <obj> BaseType
%type <obj> Exp
%type <ival> INT
%type <ival> INTEGER_LITERAL

%%
Goal : MainClass ClassDeclarationList  
     ;

ClassDeclarationList : ClassDeclarationList ClassDeclaration
                     |
                     ;
 
MainClass : CLASS Identifier '{' PUBLIC STATIC VOID MAIN '(' STRING '[' ']' Identifier ')' '{' StatementList '}' '}'
          ;

ClassDeclaration : 	CLASS Identifier {  
                          TS_entry nodo = ts.pesquisa($2);
                          if (nodo != null) 
                              yyerror("Classe: " + $2 + "< ja foi declarada");
                          else {
                                  nodo = ts.insert(new TS_entry($2, null, $2, ClasseID.NomeClasse)); 
                                  classeAtual = nodo.getLocais();
                               }
                      }


                      extendsOPC '{' VarMethodDeclarationList '}'
                 ;

extendsOPC : EXTENDS Identifier
           |
           ;

VarMethodDeclarationList : Type Identifier  {

                          TS_entry nodo = classeAtual.pesquisa($2);
                          if (nodo != null) 
                              yyerror("Tipo: " + $2 + " ja foi declarado");
                          else {
                                  nodo = classeAtual.insert(new TS_entry($2, (TS_entry)$1, $2, ClasseID.NomeParam)); 
                               }
                          }


                            ';' VarMethodDeclarationList
                         | MethodDeclarationList
                         ;


MethodDeclarationList : MethodDeclarationList MethodDeclaration
                      |
                      ;


MethodDeclaration : PUBLIC Type Identifier {
                          TS_entry nodo = classeAtual.pesquisa($3);
                          if (nodo != null) 
                              yyerror("Funcao: " + $3 + " ja foi declarada");
                          else {
                                  nodo = classeAtual.insert(new TS_entry($3, (TS_entry)$2, $3, ClasseID.NomeFuncao)); 
                                  funcaoAtual = nodo.getLocais();
                               }
                      }




     '(' ParamListOpc ')' '{' VarStatementList RETURN Exp ';' '}'
                  ;

VarStatementList : Type Identifier ';'     VarStatementList
			   	 | Statement 					StatementList
				 |
                 ;

ParamListOpc  : Type Identifier   {
                       TS_entry nodo = funcaoAtual.pesquisa($2);
                          if (nodo != null) 
                              yyerror("Tipo: " + $2 + " ja foi declarado");
                          else {
                                  nodo = funcaoAtual.insert(new TS_entry($2, (TS_entry)$1, $2, ClasseID.NomeParam));   
                               }
                    } ParamList
              |
              ;

ParamList : ',' Type Identifier {
                          TS_entry nodo = funcaoAtual.pesquisa($3);
                          if (nodo != null) 
                              yyerror("Tipo: " + $3 + " ja foi declarado");
                          else {
                                  nodo = funcaoAtual.insert(new TS_entry($3, (TS_entry)$2, $3, ClasseID.NomeParam)); 
                               }
                             }
                         ParamList
          | 
          ;


StatementList : StatementList Statement
              |
              ;


BaseType : 	INT '[' ']' { $$ = Tp_ARRAY; }
	     | 	BOOL { $$ = Tp_BOOL; }
	     | 	INT { $$ = Tp_INT; }
         ;

Type : BaseType { $$ = $1;}
	 | 	Identifier {  TS_entry nodo = ts.pesquisa($1);
                          if (nodo != null) 
                              $$ = nodo;
                          else {
                                  yyerror("Tipo: " + $1 + " nao existe");
                                  $$ = Tp_ERRO;
                               }
                  }
     ;
   

Statement 	: 	'{' StatementList '}'
	| 	IF '(' Exp ')' Statement ELSE Statement  
                  {
                        if ( ((TS_entry)$3).getTipo() != Tp_BOOL.getTipo()) 
                           yyerror("(sem) expressão (if) deve ser lógica "+((TS_entry)$3).getTipo());
                  }  
	| 	WHILE '(' Exp ')' Statement
                 {
                        if ( ((TS_entry)$3).getTipo() != Tp_BOOL.getTipo()) 
                           yyerror("(sem) expressão (while) deve ser lógica "+((TS_entry)$3).getTipo());
                  } 
	| 	PRINT '(' Exp ')' ';'
                 {
                        if ( ((TS_entry)$3).getTipo() != Tp_STRING.getTipo()) 
                           yyerror("(sem) expressão (if) deve ser string "+((TS_entry)$3).getTipo());
                  } 
	| 	Identifier '=' Exp ';'
	| 	Identifier '[' Exp ']' '=' Exp ';'
  ;

Exp : Exp AND Exp                                 { $$ = validaTipo(AND, (TS_entry)$1, (TS_entry)$3); } 
    | Exp '<' Exp                                 { $$ = validaTipo('<', (TS_entry)$1, (TS_entry)$3); }
    | Exp '+' Exp                                 { $$ = validaTipo('+', (TS_entry)$1, (TS_entry)$3); }
    | Exp '-' Exp                                 { $$ = validaTipo('-', (TS_entry)$1, (TS_entry)$3); }
    | Exp '*'Exp                                  { $$ = validaTipo('*', (TS_entry)$1, (TS_entry)$3); }
	| Exp '[' Exp ']'                        { $$ = Tp_ERRO; }
	| Exp '.' LEN                            { $$ = Tp_ERRO; }
	| Exp '.' Identifier '(' LExpOpc ')'     { $$ = Tp_ERRO; }
	| INTEGER_LITERAL                               { $$ = Tp_INT; }
	| TRUE                                          { $$ = Tp_BOOL; }
	| FALSE                                         { $$ = Tp_BOOL; }
	| Identifier                             { TS_entry nodo = funcaoAtual.pesquisa($1);
                                                  if (nodo == null)
                                                    nodo = classeAtual.pesquisa($1); 
                                                  if (nodo == null)
                                                    nodo = ts.pesquisa($1);
                                                  if (nodo == null)
                                                    yyerror("(sem) var <" + $1 + "> nao declarada");                
                                                  else
                                                    $$ = nodo.getTipo();
                                            }   
	| THIS                                   { $$ = Tp_ERRO; }
	| NEW INT '[' Exp ']'                    { $$ = Tp_ERRO; }
	| NEW Identifier '(' ')'                 { $$ = Tp_ERRO; }
	| '!' Exp                                       { $$ = $2; }
	| '(' Exp ')'                                   { $$ = $2; }
    ;

LExpOpc : Exp LExpList
        |
        ;

LExpList : ',' Exp  LExpList 
         |
         ;

%%

  private Yylex lexer;

  private TabSimb ts;
  private TabSimb classeAtual;
  private TabSimb funcaoAtual;

  public static TS_entry Tp_INT =  new TS_entry("int", null, "", ClasseID.TipoBase);
  public static TS_entry Tp_FLOAT = new TS_entry("float", null, "", ClasseID.TipoBase);
  public static TS_entry Tp_BOOL = new TS_entry("bool", null, "", ClasseID.TipoBase);
  public static TS_entry Tp_STRING = new TS_entry("string", null, "", ClasseID.TipoBase);
  public static TS_entry Tp_ARRAY = new TS_entry("array", null, "", ClasseID.TipoBase);
  public static TS_entry Tp_STRUCT = new TS_entry("struct", null, "", ClasseID.TipoBase);
  public static TS_entry Tp_ERRO = new TS_entry("_erro_", null, "", ClasseID.TipoBase);

  public static final int ARRAY = 1500;
  public static final int ATRIB = 1600;

  private String currEscopo;
  private ClasseID currClass;

  private int yylex () {
    int yyl_return = -1;
    try {
      yylval = new ParserVal(0);
      yyl_return = lexer.yylex();
    }
    catch (IOException e) {
      System.err.println("IO error: "+e.getMessage());
    }
    return yyl_return;
  }

  public void yyerror (String error) {
    System.err.println ("Erro (linha: "+ lexer.getLine() + ")\tMensagem: "+error);
  }


  public Parser(Reader r) {
    lexer = new Yylex(r, this);

    ts = new TabSimb();
    classeAtual = new TabSimb();
    funcaoAtual = new TabSimb();

    //
    // não me parece que necessitem estar na TS
    // já que criei todas como public static...
    //
    ts.insert(Tp_ERRO);
    ts.insert(Tp_INT);
    ts.insert(Tp_FLOAT);
    ts.insert(Tp_BOOL);
    ts.insert(Tp_STRING);
    ts.insert(Tp_ARRAY);
    ts.insert(Tp_STRUCT);
  }

  public void setDebug(boolean debug) {
    yydebug = debug;
  }

  public void listarTS() { ts.listar();}

  static boolean interactive;

  public static void main(String args[]) throws IOException {
      System.out.println("\n\nVerificador semantico simples\n");

      Parser yyparser;
      if ( args.length > 0 ) {
        // parse a file
        yyparser = new Parser(new FileReader(args[0]));
      }
      else {
        // interactive mode
        System.out.println("[Quit with CTRL-D]");
        System.out.print("> ");
        interactive = true;
  	    yyparser = new Parser(new InputStreamReader(System.in));
      }

      yyparser.yyparse();
    
  //  if (interactive) {
      System.out.println();
      yyparser.listarTS();

      System.out.print("\n\n-------------------------------------------------------------Feito!\n");
  //  }
  }

  TS_entry validaTipo(int operador, TS_entry A, TS_entry B) {
       
         switch ( operador ) {
              case ATRIB:
                    if ( (A == Tp_INT && B == Tp_INT)                        ||
                         ((A == Tp_FLOAT && (B == Tp_INT || B == Tp_FLOAT))) ||
                         (A ==Tp_STRING)                                     ||
                         (A == B) )
                         return A;
                     else
                         yyerror("(sem) tipos incomp. para atribuicao: "+ A.getTipoStr() + " = "+B.getTipoStr());
                    break;

              case '-' :
              case '*' :
              case '+' :
                    if ( A == Tp_INT && B == Tp_INT)
                          return Tp_INT;
                    else if ( (A == Tp_FLOAT && (B == Tp_INT || B == Tp_FLOAT)) ||
                                (B == Tp_FLOAT && (A == Tp_INT || A == Tp_FLOAT)) ) 
                         return Tp_FLOAT;
                    else if (A==Tp_STRING || B==Tp_STRING)
                        return Tp_STRING;
                    else
                        yyerror("(sem) tipos incomp. para soma: "+ A.getTipoStr() + " + "+B.getTipoStr());
                    break;
             case '<' :
             case '>' :
                  if ((A == Tp_INT || A == Tp_FLOAT) && (B == Tp_INT || B == Tp_FLOAT))
                         return Tp_BOOL;
                  else
                        yyerror("(sem) tipos incomp. para op relacional: "+ A.getTipoStr() + " > "+B.getTipoStr());
                  break;
             case AND:
                  if (A == Tp_BOOL && B == Tp_BOOL)
                         return Tp_BOOL;
                 else
                        yyerror("(sem) tipos incomp. para op lógica: "+ A.getTipoStr() + " && "+B.getTipoStr());
                 break;
             case '[':
                  if (B != Tp_INT)
                      yyerror("(sem) expressão indexadora deve ser inteira: " + B.getTipoStr());                
                  else if (A.getTipo() != Tp_ARRAY)
                            yyerror("(sem) var <" + A.getTipoStr() + "> nao é do tipo array");                
                  else 
                     return A.getTipoBase();
                  break;
            }
            return Tp_ERRO;
        }

