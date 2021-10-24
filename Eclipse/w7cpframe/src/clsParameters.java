//
// Copyright (c)2016 S C Harrison
// Refer to License.txt for terms and conditions of use.
//
import java.io.*;
import java.util.regex.Matcher;
import java.util.regex.Pattern;

    class clsParameters
    {

        public int njt = 0;        //.. No. of joints ..
        public int nmb = 0;        //.. No. of members ..
        public int nmg = 0;        //.. No. of material groups ..
        public int nsg = 0;        //.. No. of member section groups ..
        public int nrj = 0;        //.. No. of supported reaction joints ..
        public int njl = 0;        //.. No. of loaded joints ..
        public int nml = 0;        //.. No. of loaded members ..
        public int ngl = 0;        //.. No. of gravity load cases .. Self weight
        public int nr = 0;         //.. No. of restraints @ the supports ..
        public int mag = 0;        //.. Magnification Factor for graphics

        
        public void initialise()
        {
            System.out.println("initialise ...");
            njt = 0;
            nmb = 0;

            nrj = 0;
            nmg =0;

            nsg =0;
            njl = 0;

            nml = 0;
            ngl = 0;

            nr = 0;

            mag = 0;
            System.out.println("... initialise");
        }

        public String sprint()
        {
            String s = "";
            s = s + String.format("%6d",njt) + String.format("%6d",nmb);
            s = s + String.format("%6d",nrj) + String.format("%6d",nmg);
            s = s + String.format("%6d",nsg) + String.format("%6d",njl);
            s = s + String.format("%6d",nml) + String.format("%6d",ngl);
            s = s + String.format("%6d",mag);

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

        public void fgetData(BufferedReader fp, boolean isIgnore)
        {
            String s="";

            System.out.println("fgetData ...");

            try {
				s = fp.readLine();
			} catch (IOException e) {
				// TODO Auto-generated catch block
				e.printStackTrace();
			}
            sgetData(s,isIgnore);

            System.out.println("... fgetData");
        }       
        
        public void sgetData(String s, boolean isIgnore)
        {
            String [] dataflds = new String[10]; //(0 To 9);
            int i;

            System.out.println("clsParameters:sgetData ...");

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

            //typically ignore as all counters are incremented as data read
            //isIgnore=False only used to test parser.
            if (isIgnore)
            {
                //Clear the control data, and count records as read data from file
                initialise(); // (0);
            }
            else
            { //Testing Reading Data

                njt = Integer.parseInt(dataflds[0]);
                nmb = Integer.parseInt(dataflds[1]);
                nrj = Integer.parseInt(dataflds[2]);
                nmg = Integer.parseInt(dataflds[3]);
                nsg = Integer.parseInt(dataflds[4]);
                njl = Integer.parseInt(dataflds[5]);
                nml = Integer.parseInt(dataflds[6]);
                ngl = Integer.parseInt(dataflds[7]);

            }


            if (dataflds[8] != "")
            {
                mag = Integer.parseInt(dataflds[8]);
            }
            else
            {
                mag = 1;
            }

            System.out.println("Dimension & Geometry");
            System.out.println("-------------------------------");
            System.out.format("Number of Joints       : %d", njt);
            System.out.format("Number of Members      : %d", nmb);
            System.out.format("Number of Supports     : %d", nrj);

            System.out.println("Materials & Sections");
            System.out.println("-------------------------------");
            System.out.format("Number of Materials    : %d", nmg);
            System.out.format("Number of Sections     : %d", nsg);

            System.out.println("Design Actions");
            System.out.println("-------------------------------");
            System.out.format("Number of Joint Loads  : %d", njl);
            System.out.format("Number of Member Loads : %d", nml);
            System.out.format("Number of Gravity Loads : %d", ngl);

            System.out.format("Screen Magnifier: %d", mag);

            System.out.println("... clsParameters:sgetData");
        }



    } //Class
