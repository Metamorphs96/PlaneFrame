//
// Copyright (c)2016 S C Harrison
// Refer to License.txt for terms and conditions of use.
//
import java.io.*;
import java.util.regex.Matcher;
import java.util.regex.Pattern;


    class clsPfSupport
    {


        public int key = 0;
        public int js = 0;
        public int rx = 0;          //.. joint X directional restraint ..
        public int ry = 0;          //.. joint Y directional restraint ..
        public int rm = 0;          //.. joint Z rotational restraint ..



        public void initialise()
        {
            key = 0;
            js = 0;
            rx = 0;
            ry = 0;
            rm = 0;
        }

        public void setValues(int supportKey, int SupportNode, int RestraintX, int RestraintY, int RestraintMoment)
        {
            key = supportKey;
            js = SupportNode;
            rx = RestraintX;
            ry = RestraintY;
            rm = RestraintMoment;
        }


        public String sprint()
        {
            String s;

            s = "";
            s = s + String.format("%8d",key);
            s = s + String.format("%6d",js);
            s = s + String.format("%6d",rx);
            s = s + String.format("%6d",ry);
            s = s + String.format("%6d",rm);

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
            String [] dataflds = new String[10]; //(0 To 9);
            int i, n;

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


            n = dataflds.length;
            for (i = 0; i < n; i++)
            {
                System.out.println(i + "<" + dataflds[i] + ">");
            }

            key = Integer.parseInt(dataflds[0]);
            js = Integer.parseInt(dataflds[1]);
            rx = Integer.parseInt(dataflds[2]);
            ry = Integer.parseInt(dataflds[3]);
            rm = Integer.parseInt(dataflds[4]);



            System.out.println("... sgetData");
        }




    } //class

