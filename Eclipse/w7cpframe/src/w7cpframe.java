//
// Copyright (c)2016 S C Harrison
// Refer to License.txt for terms and conditions of use.
//
import java.io.*;

public class w7cpframe {
	static BufferedReader fpText;
	static BufferedWriter fpRpt;
	static BufferedWriter fpTracer;

	static void cpFrameMainApp(String ifullName, String ofullName,
			String TraceFName) {
		clsGeomModel GModel = new clsGeomModel();
		planeframe02 pframe = new planeframe02();
		String tmpStr;

		System.out.println("cpframe ...");
		System.out.println("2D/Plane Frame Analysis ... ");

		System.out.println("Input Data File     : " + ifullName);
		// fpText = new StreamReader(ifullName);
		try {
			FileReader fr = new FileReader(ifullName);
			BufferedReader fpText = new BufferedReader(fr); // alternative:
															// US-ASCII
			if (fpText != null) // File available for INPUT
			{

				// Test File Reading
				// System.out.println("Test File Reading ...");
				// tmpStr = fpText.readLine();
				// System.out.println("Read: <" + tmpStr + ">");
				// System.out.println("... Test File Reading");
				// fpText.close();

				// GModel.initialise();
				// GModel.fgetDataTest(fpText);
				// GModel.testTokens();

				// GModel.pframeReader00(fpText);
				// GModel.cprint();

				pframe.Initialise();
				pframe.GModel.initialise();
				pframe.GModel.pframeReader00(fpText);

				// Trace File
				System.out.println("Trace Report File   : " + TraceFName);
				FileWriter fw;
				fw = new FileWriter(TraceFName);
				BufferedWriter fpTracer = new BufferedWriter(fw);
				System.out.println();
				System.out.println("DATA PRINTOUT");
				pframe.GModel.cprint();

				System.out
						.println("--------------------------------------------------------------------------------");
				System.out.println("Analysis ...");
				pframe.fpTracer = fpTracer;
				pframe.Analyse_Frame();
				System.out.println("... Analysis");
				fpTracer.close();

				System.out.println("Report Results ...");
				System.out.println("Output Report File  : " + ofullName);
				FileWriter fw2;
				fw2 = new FileWriter(ofullName);
				BufferedWriter fpRpt = new BufferedWriter(fw2);

				// if (fpRpt != null)
				// {
				 pframe.fpRpt = fpRpt;
				 pframe.fprintResults();
				 fpRpt.close();
				 
				 
				// }
				// else
				// {
				// System.out.println("Report file NOT created");
				// }
				// System.out.println("... Report Results");

			} // if
				// else
				// {
				// System.out.println("File Object NOT created");
				// }

		} catch (FileNotFoundException e) {
			System.out.println("Error: File Not Found");
		} catch (IOException e) {
			System.out.println("IO Error?");
		}

		System.out.println("... 2D/Plane Frame Analysis");
		System.out.println("... cpframe");
		System.out.println("<< END >>");

	} // cpFrameMainApp

	public static void main(String[] args) {
		// char ch;
		// String s;
		String fpath1;
		String ifullName;
		String ofullName;
		String TraceFName;

		if (args.length == 1) {
			System.out.println(args[0]);

			fpath1 = args[0];
			ifullName = fpath1;
			ofullName = ifullName.replaceFirst("\\.dat", ".rpt");
			TraceFName = ifullName.replaceFirst("\\.dat", ".trc");
			System.out.println(ifullName);
			System.out.println(ofullName);
			System.out.println(TraceFName);

			cpFrameMainApp(ifullName, ofullName, TraceFName);

			// System.out.println("Press any key to continue ...");
			// try {
			// char ch = (char) System.in.read(); //Console.ReadLine();
			// }
			// catch (IOException e)
			// {
			// System.out.println("Error: IOException");
			// }
		} else {
			System.out
					.println("Not enough Parameters: Provide Data file name.");
		}

		System.out.println("All Done!");

	} // main

} // class
