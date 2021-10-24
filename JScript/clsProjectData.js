//
// Copyright (c)2014 S C Harrison
// Refer to License.txt for terms and conditions of use.
//



//Define Class
function clsProjectData()
{
  this.ProjectKey = 0;
  this.HdrTitle1 = "";
  this.LoadCase = "";
  this.ProjectID = "";
  this.Author = "";
  this.runNumber = 0;
}

clsProjectData.prototype.initialise = function()
{
 this.ProjectKey = 0;

 this.HdrTitle1 = "unknown";
 this.LoadCase = "unknown";
 this.ProjectID = "unknown";
 this.Author = "unknown";
 this.runNumber = 0;

}

clsProjectData.prototype.cprint = function()
{
  WScript.Echo(this.HdrTitle1);
  WScript.Echo(this.LoadCase);
  WScript.Echo(this.ProjectID);
  WScript.Echo(this.Author);
  WScript.Echo(this.runNumber);
}

clsProjectData.prototype.fprint = function(fp)
{
  fp.WriteLine(this.HdrTitle1);
  fp.WriteLine(this.LoadCase);
  fp.WriteLine(this.ProjectID);
  fp.WriteLine(this.Author);
  fp.WriteLine(this.runNumber);
}

clsProjectData.prototype.fgetData = function(fp)
{

  WScript.Echo("fgetData ...");
  
  this.HdrTitle1 = fp.ReadLine();
  this.LoadCase = fp.ReadLine();
  this.ProjectID = fp.ReadLine();
  this.Author = fp.ReadLine();
  this.runNumber = fp.ReadLine();
  
  WScript.Echo("... fgetData");
}

