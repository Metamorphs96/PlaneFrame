//
// Copyright (c)2014 S C Harrison
// Refer to License.txt for terms and conditions of use.
//



//xStrings
//Created to simplify conversion of programs from other languages
//(ie. C, AutoLISP)
// In JavaScript strings are immutable and can only be replaced in whole: assign something else to string variable
//Need to split string apart, and append old end to new beginning


// 
// Built-In: 
//
// substr(s , sp, l )
//
// StrLen = s.length;
// strupr(s) = s.toUpperCase;
// strlwr(s) = s.toLowerCase;
// strchr(s , c ) = s.indexOf(c);
// StrRChr(s , c ) = s.lastIndexOf(c);



//Set 1st N characters of string to given character
//Create new string
function StrNset( ch , n )
{
   var i,s;
   
   s = ""
   for(i=1;i<=n;i++){
    s = s + ch;
   }
   return s;
}


//left pad a string with spaces
function StrLPad(s , lStr )
{
var ss, i;
  ss = StrNset(" ",lStr - s.length);
  return ss + s;
} //{...PStrLPad}

//left pad a string with given character
function StrLPadc(s, lStr, c )
{
var ss , i; 
  ss = StrNset(c,lStr - s.length);
  return ss + s;
} //{...PStrLPadc}

//Right pad a string with spaces
function StrRPad(s , lStr )
{
var ss, i; 
  ss = StrNset(" ",lStr - s.length);
  return s + ss;
} //{...PStrRPad}

//Right pad a string with given character
function StrRPadc(s , lStr, c )
{
var ss , i; 
  ss = StrNset(c,lStr - s.length);
  return s + ss;
} //{...PStrRPadc}




//-------------------------------------
//MS DOS and Windows File Paths
//-------------------------------------
function fnDrv(fPath )
{
var p1;
  p1 = fPath.indexOf(":");
  if (p1 == 0) {
    return "";
  } else {
    return fPath.substr(0,p1+1);
  } //End If
}

function fnDir(fPath )
{
var s; 
var p1 , p2;

  //find last occurence of directory delimiter
  p1 = fPath.indexOf(":");
  p2 = fPath.lastIndexOf("\\");
  
  if ((p1 == 0) && (p2 == 0)) {
    return "";
  } else if (p1 == 0) {
      return fPath.substr(0, p2);
  } else {
      return fPath.substr(p1 + 1, p2 - p1);
  } //End If
}

//Allowing for long filenames
//filename assumed to exist between, last path separator character '\'
//and first extension separator character '.'
function fnName(fPath )
{
var s;
var p1 , p2;

  //find last occurence of directory delimiter
  p1 = fPath.lastIndexOf("\\");
  p2 = fPath.indexOf(".");
  if (p1 == 0 && p2 == 0) {
    return fPath;
  } else if (p1 == 0) {
    return fPath.substr(1, p2 - 1);
  } else if (p2 == 0) {
    return fPath.substr( p1 + 1, fPath.length - p1 - 1);
  } else {
    return fPath.substr(p1 + 1, p2 - p1 - 1);
  } //End If
}


//Allowing for long filenames
//filename assumed to exist between, last path separator character '\'
//and last extension separator character '.'
function fnName2(fPath )
{
var s;
var p1 , p2 , l;

  //find last occurence of directory delimiter
  p1 = fPath.lastIndexOf("\\");
  p2 = fPath.lastIndexOf("."); //Can be part of folder name
  l = fPath.length;
  if (p1 == 0 && p2 == 0) {
    return fPath;
  } else if (p1 == 0) { //No path statement
    return fPath.substr( 1, p2 - 1);
  } else if (p2 == 0) { //No file extension
    return fPath.substr( p1 + 1, Len(fPath) - p1);
  } else if (p2 < p1 && l == p1) { //folder name includes '.' and no filename given
    return "";
  } else {
    return fPath.substr( p1 + 1, p2 - p1 - 1);
  } //End If
}


//Allowing for long filenames
//file extension assumed to lie between the end of the string
//and the last extension separator character '.'
//thus filename can have more than 1 '.' in its name such as 'fn.txt.bak'
//But '.' also permitted in folder paths
function fnExt(fPath)
{ 
var s;
var p1 , p2;

// First extension separator character
//  p1 = InStr(1, fPath, ".", vbTextCompare)
//  If p1 = 0 Then
//    fnExt = ""
//  Else
//    fnExt = Mid(fPath, p1, Len(fPath))
//  End If
  p1 = fPath.lastIndexOf("\\");
  p2 = fPath.lastIndexOf(".");
  if (p2 == 0) {
    return "";
  } else if (p2 > p1) {
    return fPath.substr(p2, fPath.length);
  } else {
    return "";
  } //End If
  
}

//JScript cannot return modify parameter values
//But can return arrays and/or objects
function fnsplit(fPath)
{
  var drv,fdir,fname,fext;
  
  drv = fnDrv(fPath);
  fdir = fnDir(fPath);
  fname = fnName(fPath);
  fext = fnExt(fPath);
  
  return[drv,fdir,fname,fext]
}

function fnsplit2(fPath) // , drv , fdir , fname , fext)
{
  var drv,fdir,fname,fext;
  
  drv = fnDrv(fPath);
  fdir = fnDir(fPath);
  fname = fnName2(fPath);
  fext = fnExt(fPath);
  
  return[drv,fdir,fname,fext]
}


function fnmerge( drv , fdir , fname , fext )
{
  var fPath;
  
  fPath = drv + fdir + fname + fext;
//  WScript.Echo(fPath);
  return fPath;
}


function FmtAcadPath(fPath )
{ 
  var s;
//  var regExpr1 = /\\/gi;

  var regExpr1 = new RegExp("\\\\","gi");
  
  s = fPath.replace(regExpr1,"/");
  return s;
}


function getFolderPath(fPath1)
{
  var fldr2,fdrv2,fdir2,fname2,fext2
  var pathObj
  
    if (fso.FileExists(fpath1)) {
      //Extract Folder Name from Full File Path
      pathObj = fnsplit2(fPath1)
      fldr2 = pathObj[0] + pathObj[1];
    } else {
      //File doesn't exist
      if (fso.FolderExists(fPath1)) {
        //Have Folder Path to start with
        fldr2 = fPath1;
      } else {
        WScript.Echo( fPath1 + " Folder doesn't exist.");
        fldr2 = "";
     }
    }
    
    if (fldr2.substr(fldr2.length-1,1) == "\\") {
        WScript.Echo(fldr2);
        fldr2 = fldr2.substr(0,fldr2.length-1);
    }
    return( fldr2);
    
}    



