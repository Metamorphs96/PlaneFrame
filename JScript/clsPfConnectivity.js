//
// Copyright (c)2014 S C Harrison
// Refer to License.txt for terms and conditions of use.
//


//Define Class
function clsPfConnectivity()
{
  key=0;
  
   jj = 0;            //.. joint No. @ end "j" of a member ..  [na]
   jk = 0;            //.. joint No. @ end "k" of a member ..  [nb]
   sect = 0;          //.. section group of member ..          [ns]
   rel_i = 0;         //.. end i release of member ..          [mra]
   rel_j = 0;         //.. end j release of member ..          [mrb]
   
   L = 0;             //Length of Member
   
   jnt_jj = null; //new clsPfForce; // clsPfForce
   jnt_jk = null; //new clsPfForce; // clsPfForce
}


clsPfConnectivity.prototype.initialise = function()
{
  this.key=0;
  this.jj = 0;
  this.jk = 0;
  this.sect = 0;
  this.rel_i = 0;
  this.rel_j = 0;
  
//  this.jnt_jj = new clsPfForce;
//  this.jnt_jj.initialise;
//  
//  this.jnt_jk = new clsPfForce;
//  this.jnt_jk.initialise;

}

clsPfConnectivity.prototype.setValues = function(memberKey, NodeA, NodeB, sectionKey, ReleaseA, ReleaseB)
{
  this.key = memberKey;
  this.jj = NodeA;
  this.jk = NodeB;
  this.sect = sectionKey;
  this.rel_i = ReleaseA;
  this.rel_j = ReleaseB;
}

clsPfConnectivity.prototype.sprint = function()
{
  var s;
  
  s = "";
  s = s + StrLPad(this.key.toString(), 8)
  s = s + StrLPad(this.jj.toString(), 6)
  s = s + StrLPad(this.jk.toString(), 6)
  s = s + StrLPad(this.sect.toString(), 6)
  s = s + StrLPad(this.rel_i.toString(), 6)
  s = s + StrLPad(this.rel_j.toString(), 2)

  return s

}

clsPfConnectivity.prototype.cprint = function()
{
  WScript.Echo(this.sprint());
//  jnt_jj.cprint
//  jnt_jk.cprint

}

clsPfConnectivity.prototype.fprint = function(fp)
{
  fp.WriteLine(this.sprint());
}

clsPfConnectivity.prototype.fgetData = function(fp)
{
  var s;
  var n;
  var dataflds;
  var i,n;

  WScript.Echo( "fgetData ...");
  
  s = fp.ReadLine();
  //WScript.Echo( s);
  this.sgetData(s);
   
  WScript.Echo( "... fgetData");
}

clsPfConnectivity.prototype.sgetData = function(s)
{
  var n;
  var dataflds;
  var i,n;

  WScript.Echo( "sgetData ...");

  WScript.Echo( s);

   s = s.replace(/^\s+|\s+$/gm,''); //trim trailing spaces
   dataflds = s.match(/\s*(\d*)\s*/gi);
   
   
//   n = dataflds.length;
//   for (i=0;i<n;i++)
//   {
//    WScript.Echo( i + "<" + dataflds[i] + ">" );
//   }
//   
    this.key = parseInt(dataflds[0]);
    this.jj = parseInt(dataflds[1]);
    this.jk = parseInt(dataflds[2]);
    this.sect = parseInt(dataflds[3]);
    this.rel_i = parseInt(dataflds[4]);
    this.rel_j = parseInt(dataflds[5]);
   
   WScript.Echo( "... sgetData");
}
