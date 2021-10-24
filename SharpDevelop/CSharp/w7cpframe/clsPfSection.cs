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

        public string Descr = "";       //.. section description string ..



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

        public void setValues(int sectionKey, double SectionArea, double SecondMomentArea, int materialKey, string Description)
        {
            key = sectionKey;
            ax = SectionArea;
            iz = SecondMomentArea;
            mat = materialKey;
            Descr = Description;
        }

        public string sprint()
        {
            string s;

            s = "";
            s = s + key.ToString().PadLeft(8);
            s = s + ax.ToString().PadLeft(15);
            s = s + iz.ToString().PadLeft(15);
            s = s + mat.ToString().PadLeft(6);
            s = s + Descr.ToString().PadLeft(28);

            return s;

        }


        public void cprint()
        {
            System.Console.WriteLine(sprint());
        }

        public void fprint(StreamWriter fp)
        {
            fp.WriteLine(sprint());
        }


        public void fgetData(StreamReader fp)
        {
            string s;


            System.Console.WriteLine("fgetData ...");

            s = fp.ReadLine();
            //WScript.Echo( s);
            sgetData(s);

            System.Console.WriteLine("... fgetData");
        }


        public void sgetData(string s)
        {
            string [] dataflds = new string[10]; //(0 To 9);
            char [] delimters = new char[] { ' ', '\t' };
            int i,n;
            string s1;

            System.Console.WriteLine("sgetData ...");
            System.Console.WriteLine(s);

            string regResult;
            string pattern = @"^\s+|\s+$"; //trim trailing spaces
            regResult = Regex.Replace(s, pattern, "");

            dataflds.Initialize();
            string pattern2 = @"-?\d+(?:[,.]\d+)?";
            i = 0;
            foreach (Match match in Regex.Matches(regResult, pattern2))
            {
                if (match.Value != "")
                {
                    dataflds[i] = match.Value;
                    System.Console.WriteLine(match.Value);
                    i++;
                }
            }

            s1 = "";
            n = dataflds.Length;
            for (i = 0; i < n; i++)
            {
                System.Console.WriteLine(i + "<" + dataflds[i] + ">");
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
            System.Console.WriteLine(s1);
            System.Console.WriteLine();

            n = dataflds.Length;
            for (i = 0; i < n; i++)
            {
                System.Console.WriteLine(i + "<" + dataflds[i] + ">");
            }

            key = int.Parse(dataflds[0]);
            ax = double.Parse(dataflds[1]);
            iz = double.Parse(dataflds[2]);
            mat = int.Parse(dataflds[3]);
            Descr = dataflds[4];

            //Zero Variables
            t_len = 0;
            t_mass = 0;

            System.Console.WriteLine("... sgetData");
        }





    } //class
} // name space
