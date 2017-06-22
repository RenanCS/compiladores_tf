class Factorial{
    public static void main(String[] a){
	//System.out.println(new Fac().ComputeFac(10));
    }
}

class Fac {

    public int ComputeFac(int num){
	int num_aux ;
	
	    num_aux = num * (this.ComputeFac(num-1)) ;
	return num_aux ;
    }

    public int ComputeFac2(int num, int cat){
	int num_aux ;
	
	    num_aux = num * (this.ComputeFac(num-1)) ;
	return num_aux ;
    }

}
class Fac2 {
    Fac f;

    public int Init(){
	int num_aux ;
	f = new Fac();
	    num_aux = f.ComputeFac(5) ;
	return num_aux ;
    }


}
