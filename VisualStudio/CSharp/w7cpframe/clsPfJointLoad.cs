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

        public string sprint()
        {
            string s;

            s = "";
            s = s + key.ToString().PadLeft(8);
            s = s + jt.ToString().PadLeft(6);
            s = s + fx.ToString().PadLeft(15);
            s = s + fy.ToString().PadLeft(15);
            s = s + mz.ToString().PadLeft(15);

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
            System.Console.WriteLine(s);
            sgetData(s);

            System.Console.WriteLine("... fgetData");
        }

        public void sgetData(string s)
        {
            string[] dataflds = new string[10]; //(0 To 9);
            char[] delimters = new char[] { ' ', '\t' };
            int i, n;

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

            n = dataflds.Length;
            for (i = 0; i < n; i++)
            {
                System.Console.WriteLine(i + "<" + dataflds[i] + ">");
            }

            key = int.Parse(dataflds[0]);
            jt = int.Parse(dataflds[1]);
            fx = double.Parse(dataflds[2]);
            fy = double.Parse(dataflds[3]);
            mz = double.Parse(dataflds[4]);


            System.Console.WriteLine("... sgetData");
        }




    } //class
}  //name space
