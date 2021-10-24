//
// Copyright (c)2014 S C Harrison
// Refer to License.txt for terms and conditions of use.
//



//Define Class
function clsPfSupport()
{
  key =0;
  js  = 0;
  rx = 0;          //.. joint X directional restraint ..
  ry = 0;          //.. joint Y directional restraint ..
  rm = 0;          //.. joint Z rotational restraint ..
}


clsPfSupport.prototype.initialise = function()
{
  this.key = 0;
  this.js = 0;
  this.rx = 0;
  this.ry = 0;
  this.rm = 0;
}

clsPfSupport.prototype.setValues = function(supportKey, SupportNode, RestraintX, RestraintY, RestraintMoment)
{
  this.key = supportKey
  this.js = SupportNode
  this.rx = RestraintX
  this.ry = RestraintY
  this.rm = RestraintMoment
}


clsPfSupport.prototype.sprint = function()
{
  var s;
  
  s = "";
  s = s + StrLPad(this.key.toString(), 8);
  s = s + StrLPad(this.js.toString(), 6);
  s = s + StrLPad(this.rx.toString(), 6);
  s = s + StrLPad(this.ry.toString(), 6);
  s = s + StrLPad(this.rm.toString(), 6);
           
  return s         
}

clsPfSupport.prototype.cprint = function()
{
  WScript.Echo(this.sprint());
}

clsPfSupport.prototype.fprint = function(fp)
{
  fp.WriteLine(this.sprint());
}


clsPfSupport.prototype.fgetData = function(fp)
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


clsPfSupport.prototype.sgetData = function(s)
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
    this.js = parseFloat(dataflds[1]);
    this.rx = parseFloat(dataflds[2]);
    this.ry = parseFloat(dataflds[3]);
    this.rm = parseFloat(dataflds[4]);
    
   
   
   WScript.Echo( "... sgetData");
}


