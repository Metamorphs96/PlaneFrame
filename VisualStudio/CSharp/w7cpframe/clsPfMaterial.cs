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
    class clsPfMaterial
    {



        public int key = 0;

        public double density = 0;        //.. density ..
        public double emod = 0;           //.. elastic Modulus ..
        public double therm = 0;          //.. coeff of thermal expansion..



        public void initialise()
        {
            key = 0;
            density = 0;
            emod = 0;
            therm = 0;
        }

        public void setValues(int materialKey, double massDensity, double ElasticModulus, double CoeffThermExpansion)
        {
            key = materialKey;
            density = massDensity;
            emod = ElasticModulus;
            therm = CoeffThermExpansion;
        }

        public string sprint()
        {
            string s; 

            s = "";
            s = s + key.ToString().PadLeft(8);
            s = s + density.ToString().PadLeft( 15);
            s = s + emod.ToString().PadLeft( 15);
            s = s + therm.ToString().PadLeft( 15);

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
            string[] dataflds = new string[10]; //(0 To 9);
            char[] delimters = new char[] { ' ', '\t' };
            int i,n;

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
            density = double.Parse(dataflds[1]);
            emod = double.Parse(dataflds[2]);
            therm = double.Parse(dataflds[3]);


            System.Console.WriteLine("... sgetData");
        }







    } //class
} //name space
