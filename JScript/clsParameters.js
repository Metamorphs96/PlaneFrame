//
// Copyright (c)2014 S C Harrison
// Refer to License.txt for terms and conditions of use.
//



//Define Class
function clsParameters()
{
  this.njt=0;        //.. No. of joints ..
  this.nmb=0;        //.. No. of members ..
  this.nmg=0;        //.. No. of material groups ..
  this.nsg=0;        //.. No. of member section groups ..
  this.nrj=0;        //.. No. of supported reaction joints ..
  this.njl=0;        //.. No. of loaded joints ..
  this.nml=0;        //.. No. of loaded members ..
  this.ngl=0;        //.. No. of gravity load cases .. Self weight
  
  this.nr=0;         //.. No. of restraints @ the supports ..
  
  this.mag=0;        //.. Magnification Factor for graphics
}


clsParameters.prototype.getInitValue = function(baseIndx)
{
  if (baseIndx == 0) {
    return -1;
  } else if (baseIndx == 1) {
    return 0;
  }
}

clsParameters.prototype.initialise = function(baseIndex)
{
    WScript.Echo( "initialise ...");
    this.njt = this.getInitValue(baseIndex);
    this.nmb = this.getInitValue(baseIndex);
    
    this.nrj = this.getInitValue(baseIndex);
    this.nmg = this.getInitValue(baseIndex);
    
    this.nsg = this.getInitValue(baseIndex);
    this.njl = this.getInitValue(baseIndex);
    
    this.nml = this.getInitValue(baseIndex);
    this.ngl = this.getInitValue(baseIndex);
    
    this.nr = this.getInitValue(baseIndex);
    
    this.mag =0;
    WScript.Echo( "... initialise");
}

clsParameters.prototype.sprint = function()
{
  var s = "";
  
  s = s + StrLPad(this.njt.toString(), 6) + StrLPad(this.nmb.toString(), 6);
  s = s + StrLPad(this.nrj.toString(), 6) + StrLPad(this.nmg.toString(), 6);
  s = s + StrLPad(this.nsg.toString(), 6) + StrLPad(this.njl.toString(), 6);
  s = s + StrLPad(this.nml.toString(), 6) + StrLPad(this.ngl.toString(), 6);
  s = s + StrLPad(this.mag.toString(), 6);
  
  //s = s + StrLPad(this.nr.toString(), 6) + StrLPad(this.mag.toString(), 6);
  
  return s;
}

clsParameters.prototype.cprint = function()
{
  WScript.Echo(this.sprint());
}

clsParameters.prototype.fprint = function(fp)
{
  fp.WriteLine(this.sprint());
}

clsParameters.prototype.fgetData = function(fp, isIgnore)
{
  var s;
  var n;
  var dataflds; //(0 To 9);
  var i,n;

  WScript.Echo( "fgetData ...");
  
   s = fp.ReadLine();
   WScript.Echo( s);

   //dataflds = s.split(" "); //No good returns spaces
   s = s.replace(/^\s+|\s+$/gm,''); //trim trailing spaces
   dataflds = s.match(/\s*(\d*)\s*/gi);
   
   
//   n = dataflds.length;
//   for (i=0;i<n;i++)
//   {
//    WScript.Echo( i + "<" + dataflds[i] + ">" );
//   }

   //Call parseDelimitedString(s, dataflds, n, " ")

  //typically ignore as all counters are incremented as data read
  //isIgnore=False only used to test parser.
  if (isIgnore) {
    //Clear the control data, and count records as read data from file
    this.initialise(0);
    
  } else {

    this.njt = parseInt(dataflds[0]);
    this.nmb = parseInt(dataflds[1]);
    this.nrj = parseInt(dataflds[2]);
    this.nmg = parseInt(dataflds[3]);
    this.nsg = parseInt(dataflds[4]);
    this.njl = parseInt(dataflds[5]);
    this.nml = parseInt(dataflds[6]);
    this.ngl = parseInt(dataflds[7]);

  }
 
  
  if (dataflds[8] != "") {
    this.mag = dataflds[8];
  } else {
    this.mag = 1;
  }
  
  WScript.Echo( "Dimension & Geometry");
  WScript.Echo( "-------------------------------");
  WScript.Echo( "Number of Joints       : " + this.njt);
  WScript.Echo( "Number of Members      : " + this.nmb);
  WScript.Echo( "Number of Supports     : " + this.nrj);
  
  WScript.Echo( "Materials & Sections");
  WScript.Echo( "-------------------------------");
  WScript.Echo( "Number of Materials    : " + this.nmg);
  WScript.Echo( "Number of Sections     : " + this.nsg);
  
  WScript.Echo( "Design Actions");
  WScript.Echo( "-------------------------------");
  WScript.Echo( "Number of Joint Loads  : " + this.njl);
  WScript.Echo( "Number of Member Loads : " + this.nml);
  WScript.Echo( "Number of Gravity Loads : " + this.ngl);
  
  WScript.Echo( "Screen Magnifier: " + this.mag);
 
  WScript.Echo( "... fgetData");
}
