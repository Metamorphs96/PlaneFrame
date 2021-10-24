//
// Copyright (c)2016 S C Harrison
// Refer to License.txt for terms and conditions of use.
//
import java.io.*;
import java.util.regex.*;


    class clsPfCoordinate
    {
        //Define Class

        public int key = 0;
        public double x = 0;           //.. x-coord of a joint ..
        public double y = 0;           //.. y-coord of a joint ..



        public void initialise()
        {
            key = 0;
            x = 0;
            y = 0;
        }

        public void setValues(int nodeKey, double x1, double y1)
        {
            key = nodeKey;
            x = x1;
            y = y1;
        }

        public String sprint()
        {
            String s;

            s = String.format("%4d %12.3f %12.3f%n",key,x,y);

            return s;
        }

        public void cprint()
        {
            System.out.print(sprint());
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
  
            //Assign data fields to named variables
            key = Integer.parseInt(dataflds[0]);
            x = Double.parseDouble(dataflds[1]);
            y = Double.parseDouble(dataflds[2]);

            System.out.println("... sgetData");
        }

    } // class

