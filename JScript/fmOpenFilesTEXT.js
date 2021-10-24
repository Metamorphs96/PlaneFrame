//
// Copyright (c)2014 S C Harrison
// Refer to License.txt for terms and conditions of use.
//


//
//File Handling Routines
//

function fopenTXT(fname, fmode, isAllowOverWrite)
{
  var ForReading = 1;
  var ForWriting = 2;
  var ForAppending = 8;
  var TristateUseDefault = -2;
  var TristateTrue = -1;
  var TristateFalse = 0;

  var fso;
  var fp;

  fso = new ActiveXObject("Scripting.FileSystemObject");
  
  fp = null;
  
//  WScript.Echo(fname);
//  WScript.Echo(fmode.toLowerCase());
  
  
  //if fmode = "wt" => create and open text file for writing
  if (fmode.toLowerCase() == "wt") { //ASCII file
    if (!fso.FileExists(fname)) {
      fp = fso.OpenTextFile(fname, ForWriting, true, TristateFalse);
      
    } else if (isAllowOverWrite == true) {
       fp = fso.OpenTextFile(fname, ForWriting, true, TristateFalse);
    }
    
  } else if (fmode.toLowerCase() == "uwt") { //unicode
      if (!fso.FileExists(fname))
        fp = fso.OpenTextFile(fname, ForWriting, true, TristateTrue);
    
  //if fmode = "at" append to end of file
  } else if (fmode.toLowerCase() == "at") { //ASCII file
      if (fso.FileExists(fname))
        fp = fso.OpenTextFile(fname, ForAppending, false, TristateFalse);
    
  } else if (fmode.toLowerCase() == "uat") { //unicode
      if (fso.FileExists(fname))
        fp = fso.OpenTextFile(fname, ForAppending, false, TristateTrue);

  //if fmode = "rt" read text file
  } else if (fmode.toLowerCase() == "rt") { //ASCII file
      if (fso.FileExists(fname))
        fp = fso.OpenTextFile(fname, ForReading, false, TristateFalse);
  } else if (fmode.toLowerCase() == "urt") { //unicode
      if (fso.FileExists(fname))
        fp = fso.OpenTextFile(fname, ForReading, false, TristateTrue);
  } //End if
  
  return fp
} //End Function

