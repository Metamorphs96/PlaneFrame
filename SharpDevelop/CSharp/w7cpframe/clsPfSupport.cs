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


        public string sprint()
        {
            string s;

            s = "";
            s = s + key.ToString().PadLeft(8);
            s = s + js.ToString().PadLeft(6);
            s = s + rx.ToString().PadLeft(6);
            s = s + ry.ToString().PadLeft(6);
            s = s + rm.ToString().PadLeft(6);

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
            string [] dataflds = new string[10]; //(0 To 9);
            char [] delimters = new char[] { ' ', '\t' };
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
            js = int.Parse(dataflds[1]);
            rx = int.Parse(dataflds[2]);
            ry = int.Parse(dataflds[3]);
            rm = int.Parse(dataflds[4]);



            System.Console.WriteLine("... sgetData");
        }




    } //class
} //name space
