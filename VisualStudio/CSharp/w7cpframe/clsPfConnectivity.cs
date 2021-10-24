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
    class clsPfConnectivity
    {
        //Define Class

        public int key = 0;

        public int jj = 0;            //.. joint No. @ end "j" of a member ..  [na]
        public int jk = 0;            //.. joint No. @ end "k" of a member ..  [nb]
        public int sect = 0;          //.. section group of member ..          [ns]
        public int rel_i = 0;         //.. end i release of member ..          [mra]
        public int rel_j = 0;         //.. end j release of member ..          [mrb]

        public double L = 0;             //Length of Member

        public clsPfForce jnt_jj; //= null; //new clsPfForce; // clsPfForce
        public clsPfForce jnt_jk; //= null; //new clsPfForce; // clsPfForce



        public void initialise()
        {
            key = 0;
            jj = 0;
            jk = 0;
            sect = 0;
            rel_i = 0;
            rel_j = 0;

            //  this.jnt_jj = new clsPfForce;
            //  this.jnt_jj.initialise;
            //  
            //  this.jnt_jk = new clsPfForce;
            //  this.jnt_jk.initialise;

        }

        public void setValues(int memberKey, int NodeA, int NodeB, int sectionKey, int ReleaseA, int ReleaseB)
        {
            key = memberKey;
            jj = NodeA;
            jk = NodeB;
            sect = sectionKey;
            rel_i = ReleaseA;
            rel_j = ReleaseB;
        }

        public string sprint()
        {
            string s;

            s = "";
            s = s + key.ToString().PadLeft(8);
            s = s + jj.ToString().PadLeft(6);
            s = s + jk.ToString().PadLeft(6);
            s = s + sect.ToString().PadLeft(6);
            s = s + rel_i.ToString().PadLeft(6);
            s = s + rel_j.ToString().PadLeft(2);

            return s;

        }

        public void cprint()
        {
            System.Console.WriteLine(sprint());
            //  jnt_jj.cprint
            //  jnt_jk.cprint

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
            //System.Console.WriteLine( s);
            sgetData(s);

            System.Console.WriteLine("... fgetData");
        }

        public void sgetData(string s)
        {
            string[] dataflds = new string[10]; //(0 To 9);
            char[] delimters = new char[] { ' ', '\t' };
            int i;

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


            //   n = dataflds.length;
            //   for (i=0;i<n;i++)
            //   {
            //    System.Console.WriteLine( i + "<" + dataflds[i] + ">" );
            //   }
            //   
            key = int.Parse(dataflds[0]);
            jj = int.Parse(dataflds[1]);
            jk = int.Parse(dataflds[2]);
            sect = int.Parse(dataflds[3]);
            rel_i = int.Parse(dataflds[4]);
            rel_j = int.Parse(dataflds[5]);

            System.Console.WriteLine("... sgetData");
        }



    } //class
} //name space
