//
// Copyright (c)2014 S C Harrison
// Refer to License.txt for terms and conditions of use.
//



//Define Class
function clsPfMemberLoad()
{
   key = 0;
  
   mem_no = 0;
   lcode = 0;
   f_action = 0;
   ld_mag1 = 0;     //.. member load magnitude 1 ..
   ld_mag2 = 0;     //.. member load magnitude 2 ..
   start = 0;       //.. dist from end_1 to start/centroid of load ..
   cover = 0;       //.. dist that a load covers ..
}


clsPfMemberLoad.prototype.initialise = function()
{
  this.key =0;
  this.mem_no = 0;
  this.lcode = 0;
  this.f_action = 0;
  this.ld_mag1 = 0;
  this.ld_mag2 = 0;
  this.start = 0;
  this.cover = 0;
}

clsPfMemberLoad.prototype.setValues = function(LoadKey, memberKey, LoadType, ActionKey, LoadMag1, LoadStart, LoadCover)
{
  this.key = LoadKey;
  this.mem_no = memberKey;
  this.lcode = LoadType;
  this.f_action = ActionKey;
  this.ld_mag1 = LoadMag1;
  //ld_mag2 = LoadMag2; //xla version only
  this.start = LoadStart;
  this.cover = LoadCover;
}

clsPfMemberLoad.prototype.sprint = function()
{
  var s;
  
  s = "";
  s = s + StrLPad(this.key.toString(), 8);
  s = s + StrLPad(this.mem_no.toString(), 6);
  s = s + StrLPad(this.lcode.toString(), 6);
  s = s + StrLPad(this.f_action.toString(), 6);
  s = s + StrLPad(this.ld_mag1.toString(), 15);
  s = s + StrLPad(this.start.toString(), 15);
  s = s + StrLPad(this.cover.toString(), 12);

return s;

}

clsPfMemberLoad.prototype.cprint = function()
{
  WScript.Echo(this.sprint());
}

clsPfMemberLoad.prototype.fprint = function(fp)
{
  fp.WriteLine(this.sprint());
}


clsPfMemberLoad.prototype.fgetData = function(fp)
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


clsPfMemberLoad.prototype.sgetData = function(s)
{
  var n;
  var dataflds;
  var i,n;

  WScript.Echo( "sgetData ...");
  
  //WScript.Echo( s);

   s = s.replace(/^\s+|\s+$/gm,''); //trim trailing spaces
   dataflds = s.match(/-?\d+(?:[,.]\d+)?/gi);
   
   
   n = dataflds.length;
   for (i=0;i<n;i++)
   {
    WScript.Echo( i + "<" + dataflds[i] + ">" );
   }
   
  this.key = parseInt(dataflds[0]);
  this.mem_no = parseInt(dataflds[1]);
  this.lcode = parseInt(dataflds[2]);
  this.f_action = parseInt(dataflds[3]);
  this.ld_mag1 = parseFloat(dataflds[4]);
  
  this.ld_mag2 = this.ld_mag1;
  
  this.start = parseFloat(dataflds[5]);
  this.cover = parseFloat(dataflds[6]);

   WScript.Echo( "... sgetData");
}


