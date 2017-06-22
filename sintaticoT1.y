%{
  import java.io.*;
%}
   
%token CLASS, PUBLIC, STATIC, VOID,MAIN , STRING, STRINGAF EXTENDS, RETURN, INT, BOOL
%token IF, ELSE, WHILE, LEN, PRINT, TRUE, FALSE, NEW, AND, THIS 
%token IDENT, INTEGER_LITERAL 

%right '='
%nonassoc '<'
%left AND
%left '-' '+'
%left '*'
%right '!'
%left '.'
%left '['


%type <obj> Type
%type <obj> BaseType
%type <obj> Exp
%type <sval> IDENT
%type <ival> INT
%type <sval> STRING
%type <sval> TRUE
%type <sval> FALSE
%type <sval> INTEGER_LITERAL

%%
Goal : MainClass MoreClass  
     ;

MoreClass : MoreClass Class
                     |
                     ;
 
MainClass : CLASS IDENT '{' PUBLIC STATIC VOID MAIN '(' STRING '[' ']' IDENT ')' '{' MoreStatement '}' '}'
          ;

Class : 	CLASS IDENT {  
                          if (ts.pesquisa($2) != null) yyerror("(Class) classe: " + $2 + " ja declarada.");
                          else classeAtual = ts.insert(new TS_entry($2, Tp_CLASS, ClasseID.NomeClasse)).getLocais();
                      } ExtendsClass '{' VarMethodDeclarationList '}'
                 ;

ExtendsClass : EXTENDS IDENT {
                    if (ts.pesquisa($2) == null) yyerror("(ExtendsClass) classe: " + $2 + " nao definida.");
                  }
           |
           ;

VarMethodDeclarationList : Type IDENT  {
                                if (classeAtual.pesquisa($2) != null) yyerror("Tipo: " + $2 + " ja foi declarado");
                                else classeAtual.insert(new TS_entry($2, ((TS_entry)$1), ClasseID.VarGlobal)); 
                                yyerror("BUG --------------   -------------- >" +  $1);
                               
                                yyerror("FIM --------------   -------------- >" + ($1 instanceof TS_entry) + "\n\n\n\n");

                            } ';' VarMethodDeclarationList
                         | MoreMethod
                         ;


MoreMethod : MoreMethod Method
                      |
                      ;


Method : PUBLIC Type IDENT  {
                              if (classeAtual.pesquisa($3) != null) yyerror("Funcao: " + $3 + " ja foi declarada");
                              else funcaoAtual = classeAtual.insert(new TS_entry($3, (TS_entry)$2, ClasseID.NomeFuncao)).getLocais();
                      } '(' Param ')' '{' VarStatementList RETURN Exp ';' '}'
                  ;

VarStatementList : Type IDENT {
                          if (funcaoAtual.pesquisa($2) != null) yyerror("Tipo ja declarado: " + $2);
                          else funcaoAtual.insert(new TS_entry($2, (TS_entry)$1, ClasseID.VarLocal));     
                    } ';' VarStatementList
			           | Statement MoreStatement
				         |
                 ;

Param  : Type IDENT {
                          if (funcaoAtual.pesquisa($2) != null) yyerror("Tipo ja declarado: " + $2);
                          else funcaoAtual.insert(new TS_entry($2, (TS_entry)$1, ClasseID.NomeParam));     
                    } MoreParam
        |
        ;

MoreParam : ',' Type IDENT {
                          if (funcaoAtual.pesquisa($3) != null) yyerror("Tipo: " + $3 + " ja foi declarado");
                          else funcaoAtual.insert(new TS_entry($3, (TS_entry)$2, ClasseID.NomeParam)); 
                    } MoreParam
          | 
          ;


MoreStatement : MoreStatement Statement
              |
              ;

BaseType :  INT '[' ']'   { $$ = Tp_ARRAY; }
     |  BOOL          { $$ = Tp_BOOL; }
     |  INT           { $$ = Tp_INT; } 
     ;

Type :  BaseType { $$ = $1; }
	   | 	IDENT {  
            TS_entry nodo = ts.pesquisa($1);
            if (nodo != null) $$ = nodo;
            else {
                yyerror("Tipo: " + $1 + " nao existe");
                $$ = Tp_ERRO;
            }
         }
     ;
   

Statement 	: 	'{' MoreStatement '}'
	| 	IF '(' Exp ')' 
                  {
                        if ( ((TS_entry)$3).getTipo() != Tp_BOOL.getTipo()) 
                           yyerror("(statement if) expressão (if) deve ser lógica "+((TS_entry)$3).getTipo());
                  }  Statement ELSE Statement  
	| 	WHILE '(' Exp ')' 
                 {
                        if ( ((TS_entry)$3).getTipo() != Tp_BOOL.getTipo()) 
                           yyerror("(statement while) expressão (while) deve ser lógica "+((TS_entry)$3).getTipo());
                  } Statement
	| 	PRINT '(' Exp ')' ';'
                 {
                        if ( ((TS_entry)$3).getTipo() != Tp_STRING.getTipo()) 
                           yyerror("(statement print) expressão (print) deve ser string "+((TS_entry)$3).getTipo());
                  } 
	| 	IDENT '=' Exp ';' { 
                  TS_entry nodo = funcaoAtual.pesquisa($1);
                  if (nodo == null) nodo = classeAtual.pesquisa($1); 

                  if (nodo == null) yyerror("(statement ident) var <" + $1 + "> nao declarada");                
                  else if (nodo.getTipo() != $3 ) yyerror("(statement other) tipos incompativeis, variavel: " + $1 + " com " + $3); 
        }
	| 	IDENT '[' Exp ']' '=' Exp ';'   
  ;

Exp : Exp AND Exp                                 { $$ = validaTipo(AND, (TS_entry)$1, (TS_entry)$3); } 
    | Exp '<' Exp                                 { $$ = validaTipo('<', (TS_entry)$1, (TS_entry)$3); }
    | Exp '+' Exp                                 { $$ = validaTipo('+', (TS_entry)$1, (TS_entry)$3); }
    | Exp '-' Exp                                 { $$ = validaTipo('-', (TS_entry)$1, (TS_entry)$3); }
    | Exp '*'Exp                                  { $$ = validaTipo('*', (TS_entry)$1, (TS_entry)$3); }
  	| Exp '[' Exp ']'                        { $$ = Tp_ERRO; }
  	| Exp '.' LEN  { 
              if ($1 == Tp_ARRAY)
              $$ = Tp_INT; 
              else {
                yyerror("(len) deve ser tipo array, recebeu " + $1); 
                $$ = Tp_ERRO;
              }
            }
  	| Exp '.' IDENT '(' ParamMethod ')'     { 
            if ($1 instanceof TabSimb){
              TS_entry nodo = ((TabSimb)$1).pesquisa($3);
              if(nodo != null){
                  $$ = nodo.getTipo();
              } else  {
                yyerror("(exp . IDENT ( ParamMethod )) nao encontrou este metodo:" + $1); 
                $$ = Tp_ERRO; 
              }
            } else {
              yyerror("(exp . IDENT ( ParamMethod )) tipo errado encontrou:" + $1 + " nome " + $3); 
              $$ = Tp_ERRO; 
            }
        }
  	| INTEGER_LITERAL { $$ = Tp_INT; }
  	| TRUE { $$ = Tp_BOOL; }
  	| FALSE { $$ = Tp_BOOL; }
  	| IDENT { 
            TS_entry nodo = funcaoAtual.pesquisa($1);
            if (nodo == null) nodo = classeAtual.pesquisa($1); 

            if (nodo == null) yyerror("(exp) var <" + $1 + "> nao declarada");         
            else $$ = nodo.getTipo();
        }   
  	| THIS  { $$ = classeAtual; }
  	| NEW INT '[' Exp ']' { 
              if($4 != Tp_INT) yyerror("(exp) tipos incompativeis, deveria ser INT: " + $4);
              $$ = Tp_ARRAY; 
        }
  	| NEW IDENT '(' ')' { 
        TS_entry nodo = ts.pesquisa($2);
        if(nodo == null){
          yyerror("(NEW IDENT ()) classe nao encontrada: " + $2);
          $$ = Tp_ERRO;   
        } else $$ = nodo.getLocais(); 
      }
  	| '!' Exp  { if($2 == Tp_BOOL) $$ = $2; else yyerror("(! exp) tipo incompativel, deveria ser bool: " + $2);}
  	| '(' Exp ')' { $$ = $2; }
    ;

ParamMethod : Exp MoreParamMethod
        |
        ;

MoreParamMethod : ',' Exp  MoreParamMethod 
         |
         ;

%%

  private Yylex lexer;

  private TabSimb ts;
  private TabSimb classeAtual;
  private TabSimb funcaoAtual;

  public static TS_entry Tp_INT =  new TS_entry("int", null, ClasseID.TipoBase);
  public static TS_entry Tp_BOOL = new TS_entry("bool", null, ClasseID.TipoBase);
  public static TS_entry Tp_STRING = new TS_entry("string", null, ClasseID.TipoBase);
  public static TS_entry Tp_ARRAY = new TS_entry("array", null, ClasseID.TipoBase);
  public static TS_entry Tp_CLASS = new TS_entry("class", null, ClasseID.TipoBase);
  public static TS_entry Tp_ERRO = new TS_entry("_erro_", null, ClasseID.TipoBase);

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
    ts.insert(Tp_CLASS);
    ts.insert(Tp_ERRO);
    ts.insert(Tp_INT);
    ts.insert(Tp_BOOL);
    ts.insert(Tp_STRING);
    ts.insert(Tp_ARRAY);
  }

  public void setDebug(boolean debug) {
    yydebug = debug;
  }

  public void listarTS() { ts.listar();}

  static boolean interactive;

  public static void main(String args[]) throws IOException {
      System.out.println("\n\nBEGIN "+args[0]+"\n");

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

      System.out.print("\n\nEND "+args[0]+"\n");
  //  }
  }

  TS_entry validaTipo(int operador, TS_entry A, TS_entry B) {
       
         switch ( operador ) {
              case '=':
                    if (A != Tp_ERRO && A == B)
                      return A;
                    else
                         yyerror("(igual) tipos incomp. para atribuicao: "+ A.getTipoStr() + " = "+B.getTipoStr());
                    break;
              case '-' :
              case '*' :
                    if ( A == Tp_INT && A == B)
                          return Tp_INT;
                    else
                        yyerror("(vezes || menos ) tipos incomp.: "+ A.getTipoStr() + " + "+B.getTipoStr());
                    break;
              case '+' :
                    if ( A == Tp_INT && A == B)
                          return Tp_INT;
                    else if (A == Tp_STRING || B == Tp_STRING)
                        return Tp_STRING;
                    else
                        yyerror("(mais) tipos incomp. para soma: "+ A.getTipoStr() + " + "+B.getTipoStr());
                    break;
             case '<' :
             case '>' :
                  if ( A == Tp_INT && A == B)
                         return Tp_BOOL;
                  else
                        yyerror("(sem) tipos incomp. para op relacional: "+ A.getTipoStr() + " > "+B.getTipoStr());
                  break;
             case AND:
                  if (A == Tp_BOOL && A == B)
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

//yyerror("BUG --------------   -------------- >" + $1);
//funcaoAtual.listar();
//classeAtual.listar();
//yyerror("FIM --------------   -------------- >" + $1 + "\n\n\n\n");