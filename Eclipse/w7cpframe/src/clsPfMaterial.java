//
// Copyright (c)2016 S C Harrison
// Refer to License.txt for terms and conditions of use.
//
import java.io.*;
import java.util.regex.Matcher;
import java.util.regex.Pattern;


  class clsPfMaterial
    {

        public int key = 0;

        public double density = 0;        //.. density ..
        public double emod = 0;           //.. elastic Modulus ..
        public double therm = 0;          //.. coeff of thermal expansion..

        public void initialise()
        {
            key = 0;
            density = 0;
            emod = 0;
            therm = 0;
        }

        public void setValues(int materialKey, double massDensity, double ElasticModulus, double CoeffThermExpansion)
        {
            key = materialKey;
            density = massDensity;
            emod = ElasticModulus;
            therm = CoeffThermExpansion;
        }

        public String sprint()
        {
            String s; 

            s = "";
            s = s + String.format("%8d",key);
            s = s + String.format("%15.4f",density);
            s = s + String.format("%15.4f",emod);
            s = s + String.format("%15.4f",therm);

            return s;

        }

        public void cprint()
        {
            System.out.println(sprint());
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
            //WScript.Echo( s);
            sgetData(s);


            System.out.println("... fgetData");
        }


        public void sgetData(String s)
        {
            String[] dataflds = new String[10]; //(0 To 9);
            int i,n;

            System.out.println("sgetData ...");

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


            n = dataflds.length;
            for (i = 0; i < n; i++)
            {
                System.out.println(i + "<" + dataflds[i] + ">");
            }

            key = Integer.parseInt(dataflds[0]);
            density = Double.parseDouble(dataflds[1]);
            emod = Double.parseDouble(dataflds[2]);
            therm = Double.parseDouble(dataflds[3]);


            System.out.println("... sgetData");
        }

    } //class
