//
// Copyright (c)2016 S C Harrison
// Refer to License.txt for terms and conditions of use.
//

using System;
using System.Collections.Generic;
using System.Text;
using System.IO;
using System.Text.RegularExpressions;

namespace w7cpframe
{
    class clsProjectData
    {

        //Define Class

        public int ProjectKey = 0;

        public string HdrTitle1 = "";
        public string LoadCase = "";
        public string ProjectID = "";
        public string Author = "";
        public string runNumber = "0";


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
            System.Console.WriteLine(HdrTitle1);
            System.Console.WriteLine(LoadCase);
            System.Console.WriteLine(ProjectID);
            System.Console.WriteLine(Author);
            System.Console.WriteLine(runNumber);
        }

        public void fprint(StreamWriter fp)
        {
            fp.WriteLine(HdrTitle1);
            fp.WriteLine(LoadCase);
            fp.WriteLine(ProjectID);
            fp.WriteLine(Author);
            fp.WriteLine(runNumber);
        }

        public void fgetData(StreamReader fp)
        {

            System.Console.WriteLine("fgetData ...");

            HdrTitle1 = fp.ReadLine();
            LoadCase = fp.ReadLine();
            ProjectID = fp.ReadLine();
            Author = fp.ReadLine();
            runNumber = fp.ReadLine();

            System.Console.WriteLine("... fgetData");
        }





    } //class
} // name space
