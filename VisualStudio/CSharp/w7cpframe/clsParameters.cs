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
            System.Console.WriteLine("initialise ...");
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
            System.Console.WriteLine("... initialise");
        }

        public string sprint()
        {
            string s = "";

            s = s + njt.ToString().PadLeft(6) + nmb.ToString().PadLeft(6);
            s = s + nrj.ToString().PadLeft(6) + nmg.ToString().PadLeft(6);
            s = s + nsg.ToString().PadLeft(6) + njl.ToString().PadLeft(6);
            s = s + nml.ToString().PadLeft(6) + ngl.ToString().PadLeft(6);
            s = s + mag.ToString().PadLeft(6);

            //s = s + StrLPad(this.nr.toString(), 6) + StrLPad(this.mag.toString(), 6);

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

        public void fgetData(StreamReader fp, bool isIgnore)
        {
            string s;
            string [] dataflds = new string[10]; //(0 To 9);
            char [] delimters = new char [] {' ','\t'};
            int i;

            clsParameters myself = new clsParameters();

            System.Console.WriteLine("clsParameters:fgetData ...");

            s = fp.ReadLine();
            System.Console.WriteLine("Source String: <{0}>",s);
            string regResult;
            string pattern = @"^\s+|\s+$"; //trim trailing spaces
            regResult = Regex.Replace(s,pattern,"" );
            System.Console.WriteLine("Trimmed String: <{0}>", regResult);

            //dataflds.Initialize();
            string pattern2 = @"-?\d+(?:[,.]\d+)?";
            i = 0;
            foreach (Match match in Regex.Matches(regResult, pattern2))
            {
                if (match.Value != "")
                {
                    dataflds[i] = match.Value;
                    System.Console.WriteLine("Match: <{0}>", match.Value);
                    i++;
                }
                else 
                {
                    System.Console.WriteLine("RegExp:???? <{0}>", match.Value);
                }
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

                njt = int.Parse(dataflds[0]);
                nmb = int.Parse(dataflds[1]);
                nrj = int.Parse(dataflds[2]);
                nmg = int.Parse(dataflds[3]);
                nsg = int.Parse(dataflds[4]);
                njl = int.Parse(dataflds[5]);
                nml = int.Parse(dataflds[6]);
                ngl = int.Parse(dataflds[7]);

            }


            if (dataflds[8] != "")
            {
                mag = int.Parse(dataflds[8]);
            }
            else
            {
                mag = 1;
            }

            System.Console.WriteLine("Dimension & Geometry");
            System.Console.WriteLine("-------------------------------");
            System.Console.WriteLine("Number of Joints       : {0}", njt);
            System.Console.WriteLine("Number of Members      : {0}", nmb);
            System.Console.WriteLine("Number of Supports     : {0}", nrj);

            System.Console.WriteLine("Materials & Sections");
            System.Console.WriteLine("-------------------------------");
            System.Console.WriteLine("Number of Materials    : {0}", nmg);
            System.Console.WriteLine("Number of Sections     : {0}", nsg);

            System.Console.WriteLine("Design Actions");
            System.Console.WriteLine("-------------------------------");
            System.Console.WriteLine("Number of Joint Loads  : {0}", njl);
            System.Console.WriteLine("Number of Member Loads : {0}", nml);
            System.Console.WriteLine("Number of Gravity Loads : {0}", ngl);

            System.Console.WriteLine("Screen Magnifier: {0}", mag);

            System.Console.WriteLine("... clsParameters:fgetData");
        }



    } //Class
} //namespace
