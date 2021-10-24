//
// Copyright (c)2014 S C Harrison
// Refer to License.txt for terms and conditions of use.
//



//Define Class
function clsPfJointLoad()
{
 key = 0;

 jt = 0;
 fx = 0;          //.. horizontal load @ a joint ..
 fy = 0;          //.. vertical   load @ a joint ..
 mz = 0;          //.. moment applied  @ a joint ..
}


clsPfJointLoad.prototype.initialise = function()
{
  this.key = 0;
  this.jt = 0;
  this.fx = 0;
  this.fy = 0;
  this.mz = 0;
}

clsPfJointLoad.prototype.setValues = function(LoadKey, Node, ForceX, ForceY, Moment)
{
  this.key = LoadKey;
  this.jt = Node;
  this.fx = ForceX;
  this.fy = ForceY;
  this.mz = Moment;
}

clsPfJointLoad.prototype.sprint = function()
{
  var s;
  
  s = "";
  s = s + StrLPad(this.key.toString(), 8);
  s = s + StrLPad(this.jt.toString(), 6);
  s = s + StrLPad(this.fx.toString(), 15);
  s = s + StrLPad(this.fy.toString(), 15);
  s = s + StrLPad(this.mz.toString(), 15);
               
  return s
}

clsPfJointLoad.prototype.cprint = function()
{
  WScript.Echo(this.sprint());
}

clsPfJointLoad.prototype.fprint = function(fp)
{
  fp.WriteLine(this.sprint());
}

clsPfJointLoad.prototype.fgetData = function(fp)
{
  var s;
  var n;
  var dataflds;
  var i,n;

  WScript.Echo( "fgetData ...");
  
   s = fp.ReadLine();
   WScript.Echo( s);
   this.sgetData(s);

   WScript.Echo( "... fgetData");
}

clsPfJointLoad.prototype.sgetData = function(s)
{
  var n;
  var dataflds;
  var i,n;

  WScript.Echo( "sgetData ...");
  
   WScript.Echo( s);

   s = s.replace(/^\s+|\s+$/gm,''); //trim trailing spaces
   dataflds = s.match(/-?\d+(?:[,.]\d+)?/gi);
   
   n = dataflds.length;
   for (i=0;i<n;i++)
   {
    WScript.Echo( i + "<" + dataflds[i] + ">" );
   }
   
    this.key = parseInt(dataflds[0]);
    this.jt = parseInt(dataflds[1]);
    this.fx = parseFloat(dataflds[2]);
    this.fy = parseFloat(dataflds[3]);
    this.mz = parseFloat(dataflds[4]);


   WScript.Echo( "... sgetData");
}

