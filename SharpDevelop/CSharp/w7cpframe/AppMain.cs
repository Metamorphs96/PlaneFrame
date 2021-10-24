//
// Copyright (c)2016 S C Harrison
// Refer to License.txt for terms and conditions of use.
//
using System;
using System.Collections.Generic;
using System.Text;
using System.IO;

namespace w7cpframe
{
    class AppMain
    {
        static StreamReader fpText;
        static StreamWriter fpRpt;
        static StreamWriter fpTracer;

        static void cpFrameMainApp(string ifullName, string ofullName, string TraceFName)
        {
            clsGeomModel GModel = new clsGeomModel();
            planeframe02 pframe = new planeframe02();
            //string tmpStr;

            System.Console.WriteLine("cpframe ...");
            System.Console.WriteLine("2D/Plane Frame Analysis ... ");

            System.Console.WriteLine("Input Data File     : " + ifullName);
            fpText = new StreamReader(ifullName);

            if (fpText != null) //File available for INPUT
            {

                //Test File Reading
                //System.Console.WriteLine("Test File Reading ...");
                //tmpStr = fpText.ReadLine();
                //System.Console.WriteLine("<{0}>",tmpStr);
                //System.Console.WriteLine("... Test File Reading");

                //GModel.initialise();
                //GModel.fgetDataTest(fpText);
                //GModel.pframeReader00(fpText);
                //GModel.cprint(); 

                pframe.Initialise();  
                pframe.GModel.initialise();
                pframe.GModel.pframeReader00(fpText);

                //Trace File
                System.Console.WriteLine("Trace Report File   : " + TraceFName);
                fpTracer = new StreamWriter(TraceFName);

                System.Console.WriteLine();
                System.Console.WriteLine("DATA PRINTOUT");
                pframe.GModel.cprint();

                System.Console.WriteLine("--------------------------------------------------------------------------------");
                System.Console.WriteLine("Analysis ...");
                pframe.fpTracer = fpTracer;
                pframe.Analyse_Frame();
                System.Console.WriteLine("... Analysis");
                fpTracer.Close();

                System.Console.WriteLine("Report Results ...");
                System.Console.WriteLine("Output Report File  : " + ofullName);
                fpRpt = new StreamWriter(ofullName);
                if (fpRpt != null)
                {
                    //Output_Results();
                    //PrintResults();
                    pframe.fpRpt = fpRpt;
                    pframe.fprintResults(); 

                    fpRpt.Close();
                }
                else
                {
                    System.Console.WriteLine("Report file NOT created");
                }
                System.Console.WriteLine("... Report Results");


            }
            else
            {
                System.Console.WriteLine("File Object NOT created");
            }

            System.Console.WriteLine("... 2D/Plane Frame Analysis");
            System.Console.WriteLine("... cpframe");
            System.Console.WriteLine("<< END >>");

        } //cpFrameMainApp



        static void Main(string[] args)
        {
            string s;
            string fpath1;
            string ifullName;
            string ofullName;
            string TraceFName;

            if (args.Length == 1)
            {
                System.Console.WriteLine(args[0]);

                fpath1 = args[0];
                ifullName = fpath1;
                ofullName = Path.ChangeExtension(fpath1, ".rpt");
                TraceFName = Path.ChangeExtension(fpath1, ".trc");
                System.Console.WriteLine(ifullName);
                System.Console.WriteLine(ofullName);
                System.Console.WriteLine(TraceFName);

                cpFrameMainApp(ifullName, ofullName, TraceFName);

                System.Console.WriteLine("Press any key to Continue ...");
                s = System.Console.ReadLine();
            }
            else
            {
                System.Console.WriteLine("Not enough Parameters: Provide Data file name.");
            }

        }


    } // class
} // name space
