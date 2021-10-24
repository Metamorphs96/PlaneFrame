//
// Copyright (c)2014 S C Harrison
// Refer to License.txt for terms and conditions of use.
//

//Define Class
function clsPfCoordinate()
{
  this.key = 0;
  this.x = 0;           //.. x-coord of a joint ..
  this.y = 0;           //.. y-coord of a joint ..
}


clsPfCoordinate.prototype.initialise = function()
{
  this.key = 0;
  this.x = 0;
  this.y = 0;
}

clsPfCoordinate.prototype.setValues = function(nodeKey,x1,y1)
{
    this.key = nodeKey;
    this.x = x1;
    this.y = y1;
}

clsPfCoordinate.prototype.sprint = function()
{
  var s;
  
  s = StrLPad(this.key.toString(), 8) + StrLPad(this.x.toString(), 12) + StrLPad(this.y.toString(), 12);
  
  return s
}

clsPfCoordinate.prototype.cprint = function()
{
  WScript.Echo(this.sprint());
}

clsPfCoordinate.prototype.fprint = function(fp)
{
  fp.WriteLine(this.sprint());
}

clsPfCoordinate.prototype.fgetData = function(fp)
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


clsPfCoordinate.prototype.sgetData = function(s)
{
  var n;
  var dataflds;
  var i,n;

  WScript.Echo( "sgetData ...");

  //WScript.Echo( s);

   s = s.replace(/^\s+|\s+$/gm,''); //trim trailing spaces
   dataflds = s.match(/-?\d+(?:[,.]\d+)?/gi);


    this.key = parseInt(dataflds[0]);
    this.x = parseFloat(dataflds[1]);
    this.y = parseFloat(dataflds[2]);
   
   WScript.Echo( "... sgetData");
}





