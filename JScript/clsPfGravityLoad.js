//
// Copyright (c)2014 S C Harrison
// Refer to License.txt for terms and conditions of use.
//


//Define Class
function clsPfGravityLoad()
{
  f_action = 0;
  load =0;        //.. mass per unit length of a member load ..
}


clsPfGravityLoad.prototype.initialise = function()
{
  this.f_action = 0;
  this.load = 0;
}

clsPfGravityLoad.prototype.setValues = function(ActionKey, LoadMag)
{
  this.f_action = ActionKey;
  this.load = LoadMag;
}

clsPfGravityLoad.prototype.sprint = function()
{
    var s;
  
  s = "";
  s = s + StrLPad(this.f_action.toString(), 6);
  s = s + StrLPad(this.load.toString(), 15);
  
  return s;
}

clsPfGravityLoad.prototype.cprint = function()
{
  WScript.Echo(this.sprint());
}

clsPfGravityLoad.prototype.fprint = function(fp)
{
  fp.WriteLine(this.sprint());
}


