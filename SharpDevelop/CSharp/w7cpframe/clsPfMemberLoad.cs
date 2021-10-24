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

        public string sprint()
        {
            string s;

            s = "";
            s = s + key.ToString().PadLeft(8);
            s = s + mem_no.ToString().PadLeft(6);
            s = s + lcode.ToString().PadLeft(6);
            s = s + f_action.ToString().PadLeft(6);
            s = s + ld_mag1.ToString().PadLeft(15);
            s = s + start.ToString().PadLeft(15);
            s = s + cover.ToString().PadLeft(12);

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

            //WScript.Echo( s);

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
            mem_no = int.Parse(dataflds[1]);
            lcode = int.Parse(dataflds[2]);
            f_action = int.Parse(dataflds[3]);
            ld_mag1 = double.Parse(dataflds[4]);

            ld_mag2 = ld_mag1;

            start = double.Parse(dataflds[5]);
            cover = double.Parse(dataflds[6]);

            System.Console.WriteLine("... sgetData");
        }

    } //class
} //name space
