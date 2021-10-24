//
// Copyright (c)2016 S C Harrison
// Refer to License.txt for terms and conditions of use.
//
import java.io.*;
import java.util.regex.Matcher;
import java.util.regex.Pattern;


    class clsPfJointLoad
    {


        public int key = 0;

        public int jt = 0;
        public double fx = 0;          //.. horizontal load @ a joint ..
        public double fy = 0;          //.. vertical   load @ a joint ..
        public double mz = 0;          //.. moment applied  @ a joint ..



        public void initialise()
        {
            key = 0;
            jt = 0;
            fx = 0;
            fy = 0;
            mz = 0;
        }

        public void setValues(int LoadKey, int Node, double ForceX, double ForceY, double Moment)
        {
            key = LoadKey;
            jt = Node;
            fx = ForceX;
            fy = ForceY;
            mz = Moment;
        }

        public String sprint()
        {
            String s;

            s = "";
            s = s + String.format("%8d",key);
            s = s + String.format("%6d",jt);
            s = s + String.format("%15.4f",fx);
            s = s + String.format("%15.4f",fy);
            s = s + String.format("%15.4f",mz);

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
            System.out.println(s);
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
            jt = Integer.parseInt(dataflds[1]);
            fx = Double.parseDouble(dataflds[2]);
            fy = Double.parseDouble(dataflds[3]);
            mz = Double.parseDouble(dataflds[4]);


            System.out.println("... sgetData");
        }




    } //class