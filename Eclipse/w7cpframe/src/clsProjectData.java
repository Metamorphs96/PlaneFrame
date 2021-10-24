//
// Copyright (c)2016 S C Harrison
// Refer to License.txt for terms and conditions of use.
//
import java.io.*;

  class clsProjectData
    {

        //Define Class

        public int ProjectKey = 0;

        public String HdrTitle1 = "";
        public String LoadCase = "";
        public String ProjectID = "";
        public String Author = "";
        public String runNumber = "0";


        public void initialise()
        {
            ProjectKey = 0;

            HdrTitle1 = "unknown";
            LoadCase = "unknown";
            ProjectID = "unknown";
            Author = "unknown";
            runNumber = "0";

        }

        public void cprint()
        {
            System.out.println(HdrTitle1);
            System.out.println(LoadCase);
            System.out.println(ProjectID);
            System.out.println(Author);
            System.out.println(runNumber);
        }

        public void fprint(BufferedWriter fp)
        {
            try {
				fp.write(HdrTitle1);
				fp.write(LoadCase);
				fp.write(ProjectID);
				fp.write(Author);
				fp.write(runNumber);
			} catch (IOException e) {
				// TODO Auto-generated catch block
				e.printStackTrace();
			}
           
        }

        public void fgetData(BufferedReader fp)
        {

            System.out.println("clsProjectData:fgetData ...");

            try {
				HdrTitle1 = fp.readLine();
				LoadCase = fp.readLine();
	            ProjectID = fp.readLine();
	            Author = fp.readLine();
	            runNumber = fp.readLine();
			} catch (IOException e) {
				// TODO Auto-generated catch block
				e.printStackTrace();
			}
            

            System.out.println("... fgetData");
        }





    } //class

