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

        public string sprint()
        {
            string s;

            s = key.ToString().PadLeft(8) + x.ToString().PadLeft(12) + y.ToString().PadLeft(12);

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
            sgetData(s);

            System.Console.WriteLine("... fgetData");
        }


        public void sgetData(string s)
        {
            string[] dataflds = new string[10]; //(0 To 9);
            char[] delimters = new char[] { ' ', '\t' };
            int i;


            System.Console.WriteLine("sgetData ...");

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


            key = int.Parse(dataflds[0]);
            x = double.Parse(dataflds[1]);
            y = double.Parse(dataflds[2]);

            System.Console.WriteLine("... sgetData");
        }

    } // class
} //name space
