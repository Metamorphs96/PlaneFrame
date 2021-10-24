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
    class clsPfGravityLoad
    {

        public int f_action = 0;
        public double load = 0;        //.. mass per unit length of a member load ..

        public void initialise()
        {
            f_action = 0;
            load = 0;
        }

        public void setValues(int ActionKey, double LoadMag)
        {
            f_action = ActionKey;
            load = LoadMag;
        }

        public string sprint()
        {
            string s;

            s = "";
            s = s + f_action.ToString().PadLeft(6);
            s = s + load.ToString().PadLeft(15);

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


            f_action = int.Parse(dataflds[0]);
            load = double.Parse(dataflds[1]);


            System.Console.WriteLine("... sgetData");
        }



    } //class
} //name space
