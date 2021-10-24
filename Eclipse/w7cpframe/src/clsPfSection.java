//
// Copyright (c)2016 S C Harrison
// Refer to License.txt for terms and conditions of use.
//
import java.io.*;
import java.util.regex.Matcher;
import java.util.regex.Pattern;



    class clsPfSection
    {

        //Define Class

        public int key = 0;

        public double ax = 0;           //.. member's cross sectional area ..
        public double iz = 0;           //.. member's second moment of area ..

        //Dependent on Material Properties
        public double t_len = 0;        //.. TOTAL length of this section ..
        public double t_mass = 0;       //.. TOTAL mass of this section ..

        public int mat = 0;          //.. material of section ..

        public String Descr = "";       //.. section description String ..



        public void initialise()
        {
            key = 0;
            ax = 0;
            iz = 0;
            mat = 0;
            Descr = "<unknown>";

            t_len = 0;
            t_mass = 0;

        }

        public void setValues(int sectionKey, double SectionArea, double SecondMomentArea, int materialKey, String Description)
        {
            key = sectionKey;
            ax = SectionArea;
            iz = SecondMomentArea;
            mat = materialKey;
            Descr = Description;
        }

        public String sprint()
        {
            String s;

            s = "";
            s = s + String.format("%8d",key);
            s = s + String.format("%15.4f",ax);
            s = s + String.format("%15.4f",iz);
            s = s + String.format("%6d",mat);
            s = s + String.format("%28s",Descr);

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
            String [] dataflds = new String[10]; //(0 To 9);
            int i,n;
            String s1;

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

            s1 = "";
            n = dataflds.length;
            for (i = 0; i < n; i++)
            {
                System.out.println(i + "<" + dataflds[i] + ">");
                if (dataflds[i] != "")
                {
                    if (s1 == "")
                    {
                        s1 = dataflds[i];
                    }
                    else
                    {
                        s1 = s1 + "," + dataflds[i];
                    }
                }
            }
            System.out.println(s1);
            System.out.println();

            n = dataflds.length;
            for (i = 0; i < n; i++)
            {
                System.out.println(i + "<" + dataflds[i] + ">");
            }

            key = Integer.parseInt(dataflds[0]);
            ax = Double.parseDouble(dataflds[1]);
            iz = Double.parseDouble(dataflds[2]);
            mat = Integer.parseInt(dataflds[3]);
            Descr = dataflds[4];

            //Zero Variables
            t_len = 0;
            t_mass = 0;

            System.out.println("... sgetData");
        }





    } //class

