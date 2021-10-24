//
// Copyright (c)2014 S C Harrison
// Refer to License.txt for terms and conditions of use.
//



function cpFrameMainApp(ifullName,ofullName,TraceFName)
{
    var isAllowOverWrite;
    
//  var fpText, fpRpt, fpTracer;
  
    WScript.Echo("cpframe ...");
    WScript.Echo("2D/Plane Frame Analysis ... ");
    
    WScript.Echo("Input Data File     : " + ifullName);
    fpText = fopenTXT(ifullName,"rt",false);
    
    if (fpText != null)
    {

      //Trace File
      WScript.Echo("Trace Report File   : " + TraceFName);
      fpTracer = fopenTXT(TraceFName,"wt",true);
      
      
      // Read_Data(fpText);
      
      pframeReader00(fpText);
      setParameters(); //Ignore control parameters read, and replace with size of arrays actually read.
      
      WScript.Echo();
      WScript.Echo("DATA PRINTOUT");
      cprint();
      
      WScript.Echo("-------------");
      WScript.Echo(getLength(2));
      WScript.Echo("-------------");
      
      
      
//      WScript.Echo("Output Report File  : " + ofullName);
//      fpRpt = fopenTXT(ofullName,"wt");
//      if (fpRpt != null)
//      {
//        //Test writing data file
//        SaveDataToTextFile(fpRpt);
//        fpRpt.Close();
//      }

      WScript.Echo("--------------------------------------------------------------------------------");
      WScript.Echo("Analysis ...");
      Analyse_Frame();
      WScript.Echo("... Analysis");
      fpTracer.Close();
      
      
     
     WScript.Echo("Report Results ...");
     WScript.Echo("Output Report File  : " + ofullName);
     fpRpt = fopenTXT(ofullName,"wt",true);
     if (fpRpt != null)
     {
       //Output_Results();
       PrintResults();
       
       fpRpt.Close();
     } else {
       WScript.Echo("Report file NOT created");
     }
     WScript.Echo("... Report Results");


    } else {
      WScript.Echo("File Object NOT created");
    }
    
    WScript.Echo("... 2D/Plane Frame Analysis");
    WScript.Echo("... cpframe");
    WScript.Echo("<< END >>");

} //cpframe

function cMain()
{
  var fso,WshShell,objArgs;
  
  //General
  var doAction, fpath1, fldr1, objPath;
  var fDrv, fPath, fName, fExt;
  var ifullName;
  var ofullName;
  var TraceFName;
  var s;
  var isOk;
  
  
  fso = new ActiveXObject("Scripting.FileSystemObject");
  WshShell = new ActiveXObject("WScript.Shell");
  objArgs = WScript.Arguments;
  
  
  if (objArgs.length == 1) {
      fpath1 = objArgs(0);
      ifullName = fpath1;
  //    WScript.Echo("<" + ifullName + ">");
      
      objPath = fnsplit2(fpath1);
      
      fDrv = objPath[0];
      fPath = objPath[1];
      fName = objPath[2];
      fExt = objPath[3];  
      
  //    WScript.Echo("<" + fDrv + ">");
  //    WScript.Echo("<" + fPath + ">");
  //    WScript.Echo("<" + fName + ">");
  //    WScript.Echo("<" + fExt + ">");
      
      ofullName = fnmerge(fDrv, fPath, fName, '.rpt');
  //    WScript.Echo("<" + ofullName + ">");
      TraceFName = fnmerge(fDrv, fPath, fName, '.trc');
  //    WScript.Echo("<" + TraceFName + ">");
  
      cpFrameMainApp(ifullName,ofullName,TraceFName);
  
  
  } else {
    WScript.Echo("Not enough parameters: provide data file name");
  }
  
}
