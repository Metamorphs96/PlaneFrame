//
// Copyright (c)2016 S C Harrison
// Refer to License.txt for terms and conditions of use.
//
import java.io.*;
import java.util.regex.Matcher;
import java.util.regex.Pattern;


    class clsPfMemberLoad
    {


        public int key = 0;

        public int mem_no = 0;
        public int lcode = 0;
        public int f_action = 0;
        public double ld_mag1 = 0;     //.. member load magnitude 1 ..
        public double ld_mag2 = 0;     //.. member load magnitude 2 ..
        public double start = 0;       //.. dist from end_1 to start/centroid of load ..
        public double cover = 0;       //.. dist that a load covers ..



        public void initialise()
        {
            key = 0;
            mem_no = 0;
            lcode = 0;
            f_action = 0;
            ld_mag1 = 0;
            ld_mag2 = 0;
            start = 0;
            cover = 0;
        }

        public void setValues(int LoadKey, int memberKey, int LoadType, int ActionKey, double LoadMag1, double LoadStart, double LoadCover)
        {
            key = LoadKey;
            mem_no = memberKey;
            lcode = LoadType;
            f_action = ActionKey;
            ld_mag1 = LoadMag1;
            //ld_mag2 = LoadMag2; //xla version only
            start = LoadStart;
            cover = LoadCover;
        }

        public String sprint()
        {
            String s;

            s = "";
            s = s + String.format("%8d",key);
            s = s + String.format("%6d",mem_no);
            s = s + String.format("%6d",lcode);
            s = s + String.format("%6d",f_action);
            s = s + String.format("%15.4f",ld_mag1);
            s = s + String.format("%15.4f",start);
            s = s + String.format("%12.3f",cover);

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
            int i, n;


            System.out.println("sgetData ...");

            //WScript.Echo( s);

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
            mem_no = Integer.parseInt(dataflds[1]);
            lcode = Integer.parseInt(dataflds[2]);
            f_action = Integer.parseInt(dataflds[3]);
            ld_mag1 = Double.parseDouble(dataflds[4]);

            ld_mag2 = ld_mag1;

            start = Double.parseDouble(dataflds[5]);
            cover = Double.parseDouble(dataflds[6]);

            System.out.println("... sgetData");
        }

    } //class
