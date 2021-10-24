//
// Copyright (c)2014 S C Harrison
// Refer to License.txt for terms and conditions of use.
//



//Define Class
function clsPfSection()
{
   key = 0;
  
   ax = 0;           //.. member's cross sectional area ..
   iz = 0;           //.. member's second moment of area ..
  
  //Dependent on Material Properties
   t_len = 0;        //.. TOTAL length of this section ..
   t_mass = 0;       //.. TOTAL mass of this section ..
   mat = 0;          //.. material of section ..
  
   Descr = "";       //.. section description string ..
}


clsPfSection.prototype.initialise = function()
{
  this.key = 0;
  this.ax = 0;
  this.iz = 0;
  this.mat = 0;
  this.Descr = "<unknown>";  
  
  this.t_len = 0;
  this.t_mass = 0;

}

clsPfSection.prototype.setValues = function(sectionKey, SectionArea, SecondMomentArea, materialKey, Description)
{
  this.key = sectionKey;
  this.ax = SectionArea;
  this.iz = SecondMomentArea;
  this.mat = materialKey;
  this.Descr = Description;
}

clsPfSection.prototype.sprint = function()
{
  var s;
  
  s = "";
  s = s + StrLPad(this.key.toString(), 8);
  s = s + StrLPad(this.ax.toString(), 15);
  s = s + StrLPad(this.iz.toString(), 15);
  s = s + StrLPad(this.mat.toString(), 6);
  s = s + StrLPad(this.Descr.toString(), 28);

return s;

}


clsPfSection.prototype.cprint = function()
{
  WScript.Echo(this.sprint());
}

clsPfSection.prototype.fprint = function(fp)
{
  fp.WriteLine(this.sprint());
}


clsPfSection.prototype.fgetData = function(fp)
{
  var s,s1;
  var n;
  var dataflds;
  var i,n;

  WScript.Echo( "fgetData ...");
  
   s = fp.ReadLine();
   //WScript.Echo( s);
   this.sgetData(s);

  WScript.Echo( "... fgetData");
}


clsPfSection.prototype.sgetData = function(s)
{
  var s1;
  var n;
  var dataflds;
  var i,n;

  WScript.Echo( "sgetData ...");
  WScript.Echo( s);

   dataflds = s.split(" ");
//   s = s.replace(/^\s+|\s+$/gm,''); //trim trailing spaces
//   dataflds = s.match(/-?\d+(?:[,.]\d+)?/gi);
   
   s1="";
   n = dataflds.length;
   for (i=0;i<n;i++)
   {
    WScript.Echo( i + "<" + dataflds[i] + ">" );
    if (dataflds[i] != "")
    {
      if(s1 == "") {
        s1 = dataflds[i];
      }else {
        s1 = s1 + "," + dataflds[i];
      }
    }
   }
   WScript.Echo(s1); 
   dataflds = s1.split(",");
   WScript.Echo();
   
   n = dataflds.length;
   for (i=0;i<n;i++)
   {
    WScript.Echo( i + "<" + dataflds[i] + ">" );
   }

  this.key = parseInt(dataflds[0]);
  this.ax = parseFloat(dataflds[1]);
  this.iz = parseFloat(dataflds[2]);
  this.mat = parseFloat(dataflds[3]);
  this.Descr = dataflds[4];
  
  //Zero Variables
  this.t_len = 0;
  this.t_mass = 0;

  WScript.Echo( "... sgetData");
}


