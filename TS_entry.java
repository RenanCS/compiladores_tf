import java.util.ArrayList;
/**
 * Write a description of class Paciente here.
 * 
 * @author Lucas Ranzi, Renan Carvalho e Wagner Henz 
 * @version (24/06/2017)
 */
public class TS_entry
{
   private String id;
   private ClasseID classe;  
   private TS_entry tipo;
   private int nElem;
   private TS_entry tipoBase;
   private TS_entry extendClass;
   private TabSimb locais;


   // construtor para arrays
   public TS_entry(String umId, TS_entry umTipo, int ne, TS_entry umTBase, ClasseID umaClasse) {
      id = umId;
      tipo = umTipo;
      nElem = ne;
      tipoBase = umTBase;
      classe = umaClasse;
      locais = new TabSimb();
   }

   // construtor default
   public TS_entry(String umId, TS_entry umTipo, ClasseID classe) {
      this(umId, umTipo, -1, null, classe);
   }


public TabSimb getLocais() {
       return locais; 
   }

   public String getId() {
       return id; 
   }

   public TS_entry getTipo() {
       return tipo; 
   }
   
   public String getTipoStr() {
       return tipo2str(this); 
   }

   public int getNumElem() {
       return nElem; 
   }

   public TS_entry getTipoBase() {
       return tipoBase; 
   }

    public TS_entry getExtends() {
       return extendClass; 
    }

    public void setExtends(TS_entry extendParam){
        extendClass = extendParam;
    }



   public String toString(String space){

       StringBuilder aux = new StringBuilder("");
        
       aux.append(space + "Id: ");
       aux.append(String.format("%-10s", id));

       aux.append("\tClasse: ");
       aux.append(classe);
       aux.append("\tTipo: "); 
       aux.append(tipo2str(this.tipo)); 
       
      if (this.tipo == Parser.Tp_ARRAY) {
           aux.append(" (ne: ");
           aux.append(nElem);
           aux.append(", tBase: ");
           aux.append(tipo2str(this.tipoBase));
           aux.append(")");

    }    

        ArrayList<TS_entry> lista = locais.getLista();

      
        for (TS_entry t : lista) {
            aux.append("\n\t");
            aux.append(t.toString(space +"\t"));
        }

      return aux.toString();
   }

   
   public String toString() {
      return toString("");

   }

    public String tipo2str(TS_entry tipo) {
      if (tipo == null)  return "null"; 
      //else if (tipo==Parser.Tp_STRUCT) return "struct";
      //else if (tipo==Parser.Tp_FLOAT)  return "float";
     
      else if (tipo==Parser.Tp_INT)    return "int"; 
      else if (tipo==Parser.Tp_BOOL)   return "boolean"; 
      else if (tipo==Parser.Tp_STRING) return "string";
      else if (tipo==Parser.Tp_ARRAY)  return "array";
      else if (tipo==Parser.Tp_ERRO)  return  "_erro_";
      else if (tipo==Parser.Tp_CLASS)  return  tipo.getId();
	  else                             return "erro/tp";
   }

}






