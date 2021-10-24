//
// Copyright (c)2016 S C Harrison
// Refer to License.txt for terms and conditions of use.
//
import java.io.*;
import java.util.regex.Matcher;
import java.util.regex.Pattern;


    class clsPfGravityLoad
    {

        public int f_action = 0;
        public double load = 0;        //.. mass per unit length of a member load ..

        public void initialise()
        {
            f_action = 0;
            load = 0;
        }

        public void setValues(int ActionKey, double LoadMag)
        {
            f_action = ActionKey;
            load = LoadMag;
        }

        public String sprint()
        {
            String s;

            s = "";
            s = s + String.format("%6d",f_action);
            s = s + String.format("%12.4f",load);

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

        public void sgetData(String s)
        {
            String[] dataflds = new String[10]; //(0 To 9);
            int i;


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


            f_action = Integer.parseInt(dataflds[0]);
            load = Double.parseDouble(dataflds[1]);


            System.out.println("... sgetData");
        }



    } //class

