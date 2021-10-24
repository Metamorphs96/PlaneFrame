//
// Copyright (c)2016 S C Harrison
// Refer to License.txt for terms and conditions of use.
//
import java.io.*;
import java.util.regex.Matcher;
import java.util.regex.Pattern;

    class clsPfConnectivity
    {
        //Define Class

        public int key = 0;

        public int jj = 0;            //.. joint No. @ end "j" of a member ..  [na]
        public int jk = 0;            //.. joint No. @ end "k" of a member ..  [nb]
        public int sect = 0;          //.. section group of member ..          [ns]
        public int rel_i = 0;         //.. end i release of member ..          [mra]
        public int rel_j = 0;         //.. end j release of member ..          [mrb]

        public double L = 0;             //Length of Member

        public clsPfForce jnt_jj; //= null; //new clsPfForce; // clsPfForce
        public clsPfForce jnt_jk; //= null; //new clsPfForce; // clsPfForce


        

        public void initialise()
        {
            key = 0;
            jj = 0;
            jk = 0;
            sect = 0;
            rel_i = 0;
            rel_j = 0;

            //  this.jnt_jj = new clsPfForce;
            //  this.jnt_jj.initialise;
            //  
            //  this.jnt_jk = new clsPfForce;
            //  this.jnt_jk.initialise;

        }

        public void setValues(int memberKey, int NodeA, int NodeB, int sectionKey, int ReleaseA, int ReleaseB)
        {
            key = memberKey;
            jj = NodeA;
            jk = NodeB;
            sect = sectionKey;
            rel_i = ReleaseA;
            rel_j = ReleaseB;
        }

        public String sprint()
        {
            String s;

            s = "";
            s = s + String.format("%8d",key);
            s = s + String.format("%8d",jj);
            s = s + String.format("%8d",jk);
            s = s + String.format("%8d",sect);
            s = s + String.format("%8d",rel_i);
            s = s + String.format("%8d",rel_j);

            return s;

        }

        public void cprint()
        {
            System.out.println(sprint());
            //  jnt_jj.cprint
            //  jnt_jk.cprint

        }

        public void fprint(BufferedWriter fp)
        {
            try {
				fp.write(sprint());
			} catch (IOException e) {
				// TODO Auto-generated catch block
				e.printStackTrace();
			}
        }

        public void fgetData(BufferedReader fp)
        {
            String s="";

            System.out.println("fgetData ...");

            try {
				s = fp.readLine();
			} catch (IOException e) {
				// TODO Auto-generated catch block
				e.printStackTrace();
			}
            sgetData(s);

            System.out.println("... fgetData");
        }

        public void sgetData(String s)
        {
            String[] dataflds = new String[10]; //(0 To 9);
            int i;

            System.out.println("sgetData ...");
            System.out.println(s);

            //Trim Trailing Spaces from input String
            String regExpTrimPattern = "^\\s+|\\s+$"; //trim trailing spaces          
            Pattern regExpPatternObj = Pattern.compile(regExpTrimPattern);
            Matcher regExpMatches = regExpPatternObj.matcher(s);
            String regResult = regExpMatches.replaceAll("");
            
            //Get Data fields from input String
            String regExpNumberPattern = "-?\\d+(?:[,.]\\d+)?";
            regExpPatternObj = Pattern.compile(regExpNumberPattern);
            regExpMatches = regExpPatternObj.matcher(regResult);
            i=0;
            while (regExpMatches.find()){
            	dataflds[i] = regExpMatches.group().trim();
            	i = i+1;
            }


   
            key = Integer.parseInt(dataflds[0]);
            jj = Integer.parseInt(dataflds[1]);
            jk = Integer.parseInt(dataflds[2]);
            sect = Integer.parseInt(dataflds[3]);
            rel_i = Integer.parseInt(dataflds[4]);
            rel_j = Integer.parseInt(dataflds[5]);

            System.out.println("... sgetData");
        }



    } //class