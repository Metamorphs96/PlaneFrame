//
// Copyright (c)2014 S C Harrison
// Refer to License.txt for terms and conditions of use.
//


//Define Class
function clsPfForce()
{

  axial = 0;        //.. axial force ..
  shear = 0;        //.. shear force ..
  momnt =0;         //.. end moment ..
}


clsPfForce.prototype.initialise = function()
{
  this.axial = 0;
  this.shear = 0;
  this.momnt = 0;
}


clsPfForce.prototype.sprint = function()
{
  var s;
  
  s = "";
  s = s + StrLPad(this.axial.toString(), 8);
  s = s + StrLPad(this.shear.toString(), 8);
  s = s + StrLPad(this.momnt.toString(), 8);

return s;

}



clsPfForce.prototype.cprint = function()
{
  WScript.Echo(this.sprint());
}

