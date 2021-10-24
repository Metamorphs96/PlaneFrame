//
// Copyright (c)2014 S C Harrison
// Refer to License.txt for terms and conditions of use.
//




//Define Class
function clsPfMaterial()
{
  key =0;
  
  density = 0;        //.. density ..
  emod = 0;           //.. elastic Modulus ..
  therm = 0;          //.. coeff of thermal expansion..
}


clsPfMaterial.prototype.initialise = function()
{
  this.key = 0;
  this.density = 0;
  this.emod = 0;
  this.therm = 0;
}

clsPfMaterial.prototype.setValues = function(materialKey, massDensity, ElasticModulus, CoeffThermExpansion)
{
  this.key = materialKey
  this.density = massDensity
  this.emod = ElasticModulus
  this.therm = CoeffThermExpansion
}

clsPfMaterial.prototype.sprint = function()
{
  var s;
  
  s = ""
  s = s + StrLPad(this.key.toString(), 8);
  s = s + StrLPad(this.density.toString(), 15);
  s = s + StrLPad(this.emod.toString(), 15);
  s = s + StrLPad(this.therm.toString(), 15);

  return s;

}

clsPfMaterial.prototype.cprint = function()
{
  WScript.Echo(this.sprint());
}

clsPfMaterial.prototype.fprint = function(fp)
{
  fp.WriteLine(this.sprint());
}

clsPfMaterial.prototype.fgetData = function(fp)
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


clsPfMaterial.prototype.sgetData = function(s)
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
    this.density = parseFloat(dataflds[1]);
    this.emod = parseFloat(dataflds[2]);
    this.therm = parseFloat(dataflds[3]);


   WScript.Echo( "... sgetData");
}




