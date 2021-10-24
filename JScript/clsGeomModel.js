//
// Copyright (c)2014 S C Harrison
// Refer to License.txt for terms and conditions of use.
//


//Define Class
//function clsPGeomModel()
//{
//  
//}


//GLOBAL
var baseIndex = 0;
var dataBlockTag = "::";



var MinBound = 1; //NB: Collections start item count at 1.
var MaxNodes = 5;

//.. enumeration constants ..

//... Load Actions
var local_act    = 0;
var global_x     = 1;
var global_y     = 2;

//... Load Types
var dst_ld = 1;    //.. distributed loads udl, trap, triangular
var pnt_ld = 2;    //.. point load
var axi_ld = 3;    //.. axial load

var udl_ld = 4;    //.. uniform load
var tri_ld = 5;    //.. triangular load

var mega = 1000000;
var kilo = 1000;
var cent = 100;

var tolerance = 0.0001;
var infinity = 2E+20;
var neg_slope = 1;
var pos_slope = -1;
//
////Public Nodes(MaxNodes) As clsPfCoordinate //Not possible in vba but possible in vb.net
////var Nodes = new Collection //use collection instead of public array
//
//File Parser: Limit State Machine
var MachineOFF  = 0;
var MachineTurnOFF  = 0;

var MachineON  = 1;
var MachineTurnON  = 1;
var MachineRunning  = 1;
var MachineScanning  = 1;

var RecognisedSection  = 2;
var DataBlockFound  = 3;

var lastTxtStr = "";

//------------------------------------------------------------------------------
//Need Public Access to this Data
//As the whole point is to programmatically define and build a structural model
//External to the Class
//------------------------------------------------------------------------------
//Project & Parameters
var ProjectData = new clsProjectData;
var structParam = new clsParameters;

//Materials & Sections
var mat_grp = []; // new  clsPfMaterial;        //material_rec
var sec_grp = []; // new  clsPfSection;         //section_rec

//Dimension & Geometry
var nod_grp = []; // new  clsPfCoordinate;      //coord_rec
var con_grp = []; // new  clsPfConnectivity;    //connect_rec
var sup_grp = []; // new  clsPfSupport;         //support_rec

//Design Actions
var jnt_lod = []; // new  clsPfJointLoad;       //jnt_ld_rec
var mem_lod = []; // new  clsPfMemberLoad;      //mem_ld_rec
var grv_lod = []; // new  clsPfGravityLoad;     //grv_ld_rec


//--------------------------------------------------------------------------------
////DATA COLLECTION SUBROUTINES
////------------------------------------------------------------------------------
//function setNode(ByVal nodeKey , ByVal x1 , ByVal y1 )
//{
//  var nodePtr As clsPfCoordinate
//
//  Set nodePtr = Nodes(nodeKey)
//  Call nodePtr.setValues(nodeKey, x1, y1)
//}

//function setNode2(ByVal nodeKey , ByVal x1 , ByVal y1 )
//{
//  var nodePtr As clsPfCoordinate
//
//  Set nodePtr = nod_grp(nodeKey)
//  Call nodePtr.setValues(nodeKey, x1, y1)
//}
//


function setParameters()
{
  structParam.njt=nod_grp.length;        //.. No. of joints ..
  structParam.nmb=con_grp.length;        //.. No. of members ..
  structParam.nmg=mat_grp.length;        //.. No. of material groups ..
  structParam.nsg=sec_grp.length;        //.. No. of member section groups ..
  structParam.nrj=sup_grp.length;        //.. No. of supported reaction joints ..
  structParam.njl=jnt_lod.length;        //.. No. of loaded joints ..
  structParam.nml=mem_lod.length;        //.. No. of loaded members ..
  structParam.ngl=grv_lod.length;        //.. No. of gravity load cases .. Self weight  
}


function addNode(nodePtr)
{
  //structParam.njt = structParam.njt + 1;
  nod_grp.push(nodePtr);
}

function addMember(memberPtr)
{
  //structParam.nmb = structParam.nmb + 1;
  con_grp.push(memberPtr);
}

function addSupport(supportPtr)
{
  WScript.Echo("ADD Support");
  //structParam.nrj = structParam.nrj + 1;
  sup_grp.push(supportPtr);
  structParam.nr = structParam.nr + supportPtr.rx + supportPtr.ry + supportPtr.rm;
  WScript.Echo("structParam.nr : " + structParam.nr.toString());
}

function addMaterialGroup(materialPtr )
{
  //structParam.nmg = structParam.nmg + 1;
  mat_grp.push(materialPtr);
}

function addSectionGroup(sectionPtr)
{
  //structParam.nsg = structParam.nsg + 1;
  sec_grp.push(sectionPtr);
}

function addJointLoad(LoadPtr)
{
  //structParam.njl = structParam.njl + 1;
  jnt_lod.push(LoadPtr);
}

function addMemberLoad(Loadptr)
{
  //structParam.nml = structParam.nml + 1
  mem_lod.push(Loadptr);
}

function addGravityLoad(Loadptr )
{
  grv_lod.push(Loadptr);
}


function getLength(memberKey)
{
  var ptA, ptB;
  var deltaX, deltaY;
  var magnitude;
  
  ptA = con_grp[memberKey-1].jj-1;
  ptB = con_grp[memberKey-1].jk-1;
  
//  WScript.Echo(con_grp[memberKey-1].key);
//  WScript.Echo(ptA.toString() + "," + ptB.toString());
//  WScript.Echo(nod_grp[ptA].x,nod_grp[ptA].y);
//  WScript.Echo(nod_grp[ptB].x,nod_grp[ptB].y);
  
  deltaX = nod_grp[ptB].x - nod_grp[ptA].x;
  deltaY = nod_grp[ptB].y - nod_grp[ptA].y;
  
//  WScript.Echo(deltaX);
//  WScript.Echo(deltaY);
  magnitude = Math.sqrt(Math.pow(deltaX,2)+Math.pow(deltaY,2));
//  WScript.Echo(magnitude);
  
  return magnitude
}


//REPORTING SUBROUTINES
//------------------------------------------------------------------------------

function cprintjobData()
{
  var i; 

  WScript.Echo("cprintjobData ...");
  ProjectData.cprint();
}

function cprintControlData()
{
  WScript.Echo("cprintControlData ...");
  structParam.cprint();
}

function cprintNodes()
{
  var n; 
  var i; 

  WScript.Echo("cprintNodes ...");
  
//  if (structParam.njt == 0) { 
//    n = max_grps ;
//  } else { 
//    n = structParam.njt;
//  }
  
  n = nod_grp.length;
  for(i = baseIndex; i<n;i++)
  {
    nod_grp[i].cprint();
  }

  WScript.Echo("... cprintNodes");

}

function cprintConnectivity()
{
  var i;
  var n;

  WScript.Echo("cprint: Connectivity");
//  if (structParam.nmb == 0){ 
//    n = max_grps ;
//  } else { 
//    n = structParam.nmb;
//  }
  
  n = con_grp.length;
  for(i = baseIndex; i<n;i++)
  {
    con_grp[i].cprint();
  }

}

function cprintMaterials()
{
  var i; 
  var n; 

  WScript.Echo("cprint: Materials");
//  if (structParam.nmg == 0) { 
//    n = max_mats 
//  } else { 
//    n = structParam.nmg
//  }
  
  n = mat_grp.length;
  for(i = baseIndex; i<n;i++)
  {
    mat_grp[i].cprint();
  }

}

function cprintSections()
{
  var i;
  var n;
  
  WScript.Echo("cprint: Sections");
//  if (structParam.nsg == 0) { 
//    n = max_grps; 
//  } else { 
//    n = structParam.nsg;
//  }

  n = sec_grp.length;
  for(i = baseIndex; i<n;i++)
  {
    sec_grp[i].cprint();
  }
}


function cprintSupports()
{
  var i;
  var n;
  
  WScript.Echo("cprint: Supports");
//  if (structParam.nrj == 0) { 
//    n = max_grps;
//  } else { 
//    n = structParam.nrj;
//  }
  
  n = sup_grp.length;
  for(i = baseIndex; i<n;i++)
  {
    sup_grp[i].cprint();
  }
}

function cprintJointLoads(isPrintRaw)
{
  var i;
  var n;
  
  WScript.Echo("cprint: Joint Loads");
//  if (isPrintRaw) {
//    n = numloads;
//  } else {
//    n = structParam.njl;
//  }

  n = jnt_lod.length;
  for(i = baseIndex; i<n;i++)
  {
    jnt_lod[i].cprint();
  }
  
}


function cprintMemberLoads()
{
  var i;
  var n;
  
  WScript.Echo("cprint: Member Loads");
//  if (structParam.nml == 0) { 
//    n = numloads;
//  } else { 
//    n = structParam.nml;
//  }

  n = mem_lod.length;
  for(i = baseIndex; i<n;i++)
  {
   mem_lod[i].cprint();
  }
}

function cprintGravityLoads()
{  
  var i;
  var n;
  
  WScript.Echo("cprint: Gravity Loads");

  n = grv_lod.length;
  for(i = baseIndex; i<n;i++)
  {
   grv_lod[i].cprint();
  }
  

}


function cprint()
{
  WScript.Echo("cprint ...");

  WScript.Echo("Project Data");
  WScript.Echo("------------");
  cprintjobData();
  cprintControlData();
  
  WScript.Echo("Materials");
  WScript.Echo("------------");
  cprintMaterials();
  cprintSections();
  
  WScript.Echo("Model");
  WScript.Echo("------------");
  cprintNodes();
  cprintConnectivity();
  cprintSupports();
  
  WScript.Echo("Loading");
  WScript.Echo("------------");
  cprintJointLoads(false);
  cprintMemberLoads();
  cprintGravityLoads();
  
  WScript.Echo("... cprint");
}


//FILE READING SUBROUTINES
//------------------------------------------------------------------------------
function isDataBlockHeaderString(s)
{
  var p; 
  
  p = s.indexOf(dataBlockTag);
  if (p != -1) {
    return true;
  } else {
    return false;
  }
}

function fgetNodeData(fp)
{
  var nodePtr;  //= new clsPfCoordinate;
  
  var s;
  var i , n; 
  var dataflds;
  
  var MachineState; 
  var quit; //Switch Machine OFF and Quit
  var done; //Finished Reading File but not processing data, prepare machine to switch off
  var isDataBlockFound;
  
  
  quit = false;
  MachineState = MachineON; //and is Scanning file
  done = false;
  isDataBlockFound = false;
 
  WScript.Echo("fgetNodeData ...");
  
  done = false;
  while (!(done) && !(quit))
  {
    switch (MachineState) {
      case  MachineTurnOFF:
        quit = true;
        WScript.Echo("Machine to be Turned OFF");
        break;
      case  MachineScanning:
        if (!fp.AtEndOfStream) {
          s = fp.ReadLine();
          WScript.Echo(">" + s + "<");
          
          nodePtr = new clsPfCoordinate;
          
          isDataBlockFound = isDataBlockHeaderString(s);
          if (isDataBlockFound) {
            WScript.Echo("data block found");
            MachineState = DataBlockFound;
          } else {
            
            nodePtr.sgetData(s);
            addNode(nodePtr);
            
            MachineState = MachineScanning;
          }
        } else {
          done = true;
          MachineState = MachineTurnOFF;
        }
        break;
      case  DataBlockFound:
        //Signifies End of Current Data Block
        done = true;
        MachineState = MachineTurnOFF;
        break;
    } //switch
    
    nodePtr = null;
    
  } //Loop
  lastTxtStr = s;
  WScript.Echo("lastTxtStr: " + lastTxtStr);
  WScript.Echo("... fgetNodeData");
  
}


function fgetMemberData(fp)
{
  var memberPtr;
  
  var s;
  var i , n;
  var dataflds = [];
  
  var MachineState; 
  var quit; //Switch Machine OFF and Quit
  var done; //Finished Reading File but not processing data, prepare machine to switch off
  var isDataBlockFound;
    
  quit = false;
  MachineState = MachineON; //and is Scanning file
  done = false;
  isDataBlockFound = false;
 
  WScript.Echo("fgetMemberData ...");
  
  done = false;
  while (!(done) && !(quit))
  {
    switch (MachineState)
    {
      case  MachineTurnOFF:
        quit = true;
        WScript.Echo("Machine to be Turned OFF");
        break;
      case  MachineScanning:
        if (!fp.AtEndOfStream) {
        
          //s = fp.ReadLine();;
          s = fp.ReadLine();
          
          memberPtr = new clsPfConnectivity;
          memberPtr.initialise;
          memberPtr.jnt_jj = new clsPfForce;
          memberPtr.jnt_jj.initialise();
          memberPtr.jnt_jk = new clsPfForce;
          memberPtr.jnt_jk.initialise();
          
          isDataBlockFound = isDataBlockHeaderString(s);
          if (isDataBlockFound) {
            MachineState = DataBlockFound;
          } else {
            
            memberPtr.sgetData(s);
            addMember(memberPtr);
            
            MachineState = MachineScanning;
          }
        } else {
          done = true;
          MachineState = MachineTurnOFF;
        }
        break;
        
      case  DataBlockFound:
        //Signifies End of Current Data Block
        done = true;
        MachineState = MachineTurnOFF;
        break;
        
    } //switch
    
    memberPtr = null;
    
  } //loop
  
  lastTxtStr = s;
  
  WScript.Echo("... fgetMemberData");
  
}


function fgetSupportData(fp)
{
  var supportPtr;
  var s;
  var i , n; 
  var dataflds;
  
  var MachineState; 
  var quit; //Switch Machine OFF and Quit
  var done; //Finished Reading File but not processing data, prepare machine to switch off
  var isDataBlockFound;
    
  quit = false;
  MachineState = MachineON; //and is Scanning file
  done = false;
  isDataBlockFound = false;
 
 WScript.Echo("fgetSupportData ...");
  
  done = false;
  while (!(done) && !(quit))
  {
    switch (MachineState)
    {
      case  MachineTurnOFF:
        quit = true;
        WScript.Echo("Machine to be Turned OFF");
        break;
      case  MachineScanning:
        if (!fp.AtEndOfStream) {
          s = fp.ReadLine();
          supportPtr = new  clsPfSupport;
          
          isDataBlockFound = isDataBlockHeaderString(s);
          if (isDataBlockFound) {
            MachineState = DataBlockFound;
          } else {

            supportPtr.sgetData(s);
            addSupport(supportPtr);

            MachineState = MachineScanning;
          }
        } else {
          done = true;
          MachineState = MachineTurnOFF;
        }
        break;
      case  DataBlockFound:
        //Signifies End of Current Data Block
        done = true;
        MachineState = MachineTurnOFF;
        break;
    } //} End Select
    
    supportPtr = null;
    
  } //Loop
  
  lastTxtStr = s;
  
  WScript.Echo("... fgetSupportData");

}

function fgetMaterialData(fp)
{
  var materialPtr;
  var s;
  var i , n;
  var dataflds;
  
  var MachineState; 
  var quit; //Switch Machine OFF and Quit
  var done; //Finished Reading File but not processing data, prepare machine to switch off
  var isDataBlockFound;
    
  quit = false;
  MachineState = MachineON; //and is Scanning file
  done = false;
  isDataBlockFound = false;
 
 WScript.Echo("fgetMaterialData ...");
  
  done = false
  while (!(done) && !(quit))
  {
    switch (MachineState)
    {
      case  MachineTurnOFF:
        quit = true;
        WScript.Echo("Machine to be Turned OFF");
        break;
      case  MachineScanning:
        if (!fp.AtEndOfStream) {
          s = fp.ReadLine();
          materialPtr = new  clsPfMaterial;
          
          isDataBlockFound = isDataBlockHeaderString(s);
          if (isDataBlockFound) {
            MachineState = DataBlockFound;
          } else {

              materialPtr.sgetData(s);
              addMaterialGroup(materialPtr);

            MachineState = MachineScanning;
          }
        } else {
          done = true;
          MachineState = MachineTurnOFF;
        }
        break;
      case  DataBlockFound:
        //Signifies End of Current Data Block
        done = true;
        MachineState = MachineTurnOFF;
        break;
    } //End Select
    
    materialPtr = null;
    
  } //loop
  
  lastTxtStr = s;
  
  WScript.Echo("... fgetMaterialData");
  
}


function fgetSectionData(fp)
{
  var sectionPtr;
  var s;
  var i , n; 
  var dataflds;
  
  var MachineState;
  var quit; //Switch Machine OFF and Quit
  var done; //Finished Reading File but not processing data, prepare machine to switch off
  var isDataBlockFound;
    
  quit = false;
  MachineState = MachineON; //and is Scanning file
  done = false;
  isDataBlockFound = false;
 
 WScript.Echo("fgetSectionData ...");
  
  done = false;
  while (!(done) && !(quit))
{
    switch (MachineState)
{
      case  MachineTurnOFF:
        quit = true;
        WScript.Echo("Machine to be Turned OFF");
        break;
      case  MachineScanning:
        if (!fp.AtEndOfStream) {
          s = fp.ReadLine();
          sectionPtr = new  clsPfSection;
          
          
          isDataBlockFound = isDataBlockHeaderString(s);
          if (isDataBlockFound) {
            MachineState = DataBlockFound;
          } else {

            sectionPtr.sgetData(s);
            addSectionGroup(sectionPtr);
            
            MachineState = MachineScanning;
          }
        } else {
          done = true;
          MachineState = MachineTurnOFF;
        }
        break;
      case  DataBlockFound:
        //Signifies End of Current Data Block
        done = true;
        MachineState = MachineTurnOFF;
        break;
    } //End Select
    
    
    sectionPtr = null;
    
  } //Loop
  
  lastTxtStr = s;
  
  
  
  WScript.Echo("... fgetSectionData");
  
}

function fgetJointLoadData(fp)
{
  var jloadPtr;
  var s;
  var i , n; 
  var dataflds;
  
  var MachineState;
  var quit; //Switch Machine OFF and Quit
  var done; //Finished Reading File but not processing data, prepare machine to switch off
  var isDataBlockFound;
    
  quit = false;
  MachineState = MachineON; //and is Scanning file
  done = false;
  isDataBlockFound = false;
 
 WScript.Echo("fgetJointLoadData ...");
  
  done = false;
  while (!(done) && !(quit))
{
    switch (MachineState)
{
      case  MachineTurnOFF:
        quit = true;
        WScript.Echo("Machine to be Turned OFF");
        break;
      case  MachineScanning:
        if (!fp.AtEndOfStream) {
          s = fp.ReadLine();
          jloadPtr = new  clsPfJointLoad;

          isDataBlockFound = isDataBlockHeaderString(s);
          if (isDataBlockFound) {
            MachineState = DataBlockFound;
          } else {

              jloadPtr.sgetData(s);
              addJointLoad(jloadPtr);

            MachineState = MachineScanning;
          }
        } else {
          done = true;
          MachineState = MachineTurnOFF;
        }
        break;
      case  DataBlockFound:
        //Signifies End of Current Data Block
        done = true;
        MachineState = MachineTurnOFF;
        break;
    } //End Select
    
    jloadPtr = null;
    
  } //Loop
  
  lastTxtStr = s;
  
  
  WScript.Echo("... fgetJointLoadData");
  
}

function fgetMemberLoadData(fp)
{
  var mLoadPtr;
  var s;
  var i , n; 
  var dataflds;
  
  var MachineState; 
  var quit; //Switch Machine OFF and Quit
  var done; //Finished Reading File but not processing data, prepare machine to switch off
  var isDataBlockFound;
    
  quit = false;
  MachineState = MachineON; //and is Scanning file
  done = false;
  isDataBlockFound = false;
 
 WScript.Echo("fgetMemberLoadData ...");
  
  done = false;
  while (!(done) && !(quit))
{
    switch (MachineState)
{
      case  MachineTurnOFF:
        quit = true;
        WScript.Echo("Machine to be Turned OFF");
        break;
      case  MachineScanning:
        if (!fp.AtEndOfStream) {
          s = fp.ReadLine();
          mLoadPtr = new  clsPfMemberLoad;

          isDataBlockFound = isDataBlockHeaderString(s);
          if (isDataBlockFound) {
            MachineState = DataBlockFound;
          } else {

              mLoadPtr.sgetData(s);
              addMemberLoad(mLoadPtr);
            
            MachineState = MachineScanning;
          }
        } else {
          done = true;
          MachineState = MachineTurnOFF;
        }
        break;
      case  DataBlockFound:
        //Signifies End of Current Data Block
        done = true;
        MachineState = MachineTurnOFF;
        break;
    } //End Select
    
    mLoadPtr = null;
    
  } //Loop
  
  lastTxtStr = s;
  
  
  WScript.Echo("... fgetMemberLoadData");
  
}

function fgetGravityLoadData(fp)
{
  var gLoadPtr;
  var s;
  var i , n;
  var dataflds;
  
  var MachineState; 
  var quit; //Switch Machine OFF and Quit
  var done; //Finished Reading File but not processing data, prepare machine to switch off
  var isDataBlockFound;
  var isUseDefaultData;
 
  WScript.Echo("fgetGravityLoadData ...");
  
  isDataBlockFound = false;
  if (!fp.AtEndOfStream) {
    quit = false;
    MachineState = MachineON; //and is Scanning file
    done = false;
    isUseDefaultData = false;
  } else {
    done = true;
    MachineState = MachineTurnOFF;
    isUseDefaultData = true;
  }

  while (!(done) && !(quit))
{
    switch (MachineState)
{
      case  MachineTurnOFF:
        quit = true;
        WScript.Echo("Limit State File Parser Machine to be Turned OFF");
        break;
        
      case  MachineScanning:
        if (!fp.AtEndOfStream) {
          s = fp.ReadLine();
          gLoadPtr = new  clsPfGravityLoad;
          
          isDataBlockFound = isDataBlockHeaderString(s);
          if (isDataBlockFound) {
            MachineState = DataBlockFound;
          } else {

              gLoadPtr.sgetData(s);
              addGravityLoad();

            MachineState = MachineScanning;
          }
        } else {
          WScript.Echo("... End of File");
          done = true;
          MachineState = MachineTurnOFF;
        }
        break;
        
      case  DataBlockFound:
        //Signifies End of Current Data Block
        done = true;
        MachineState = MachineTurnOFF;
        break;
        
    } //End Select
    
    gLoadPtr = null;
    
  } //Loop
  
  if (!fp.AtEndOfStream) {
    lastTxtStr = s;
  } else {
    lastTxtStr = "";
  }
  
  if (isUseDefaultData) {
    WScript.Echo("Using Default Data");
    // addGravityLoad(2, -9.81);
  }

  //File Data Ignored
  //Default Values Used Only
  
  WScript.Echo("... fgetGravityLoadData");
}


//Limit State Machine: File Parser
//File format to match requirements for F_wrk.exe (With File Date Modified = Friday, 23 August 1996, 13:18:04)
function pframeReader00(fp)
{ //begin function
  
  var pwid = 20;
  var i, tmp, p, n;
  var s, grp;
  var dataCtrlBlk;
  
  var MachineState;
  var quit;
  var done;
  var isDataBlockFound;
  
  WScript.Echo("pframeReader00 ...");
  
  s ="";
  quit = false;
  
  MachineState = MachineON; //and is Scanning file
  done = false;
  isDataBlockFound = false;

  while (!(done) && !(quit))
  {
    switch (MachineState) {
      case  MachineTurnOFF:
       
        quit = true;
        WScript.Echo("Machine to be Turned OFF");
        break;
       
      case  MachineScanning:
        if (!fp.AtEndOfStream) {
          s = fp.ReadLine();
          isDataBlockFound = isDataBlockHeaderString(s);
          
          //WScript.Echo("<" + s + ">");
          //WScript.Echo("machine scanning ...");
          if (isDataBlockFound) {
            MachineState = DataBlockFound;
          } else {
            MachineState = MachineScanning;
          }
        } else {
          done = true;
          MachineState = MachineTurnOFF;
        }
        break;
      case  DataBlockFound:
        WScript.Echo("DataBlockFound:MAIN " + s);
        i = 0;
        grp = s.match(/([\t A-Za-z]+):{2}/);
//        WScript.Echo( i + "match<" + grp + ">" );
//        n = grp.length;
//        WScript.Echo("n: " + n.toString());
//        for (i=0;i<=n;i++)
//        {
//           WScript.Echo( i + "# <" + grp[i] + ">" );
//        }
        
        
        
        s = grp[1];
        s = s.replace(/^\s+|\s+$/gm,''); //trim trailing spaces
        dataCtrlBlk = s;  //UCase(Trim(Left(s, Len(s) - 2)))
        
        //WScript.Echo("Found: <" + dataCtrlBlk + ">");
        MachineState = RecognisedSection;
        break;
        
      case  RecognisedSection:
      
        switch (dataCtrlBlk) {
          case  "JOB DETAILS":  //Alternative to Job Data
            WScript.Echo("1[" + dataCtrlBlk + "]");
            ProjectData.fgetData(fp);
            MachineState = MachineScanning;
            break;
            
          case  "JOB DATA": //Alternative to Job Details
            WScript.Echo("2[" + dataCtrlBlk + "]");
            ProjectData.fgetData(fp);
            MachineState = MachineScanning;
            break;
            
          case  "CONTROL DATA":
            WScript.Echo("3[" + dataCtrlBlk + "]");
            //structParam.initialise(0)
            structParam.fgetData(fp, false); // true);
            MachineState = MachineScanning;
            structParam.nr = 0;
            WScript.Echo("structParam.nr : " + structParam.nr.toString());
            break;
            
          case  "NODES":
            WScript.Echo("4[" + dataCtrlBlk + "]");
            fgetNodeData(fp);
            s = lastTxtStr;
            MachineState = DataBlockFound;
            //MachineState = MachineScanning;
            break;
            
          case  "MEMBERS":
            WScript.Echo("5[" + dataCtrlBlk + "]");
            fgetMemberData(fp, s);
            s = lastTxtStr;
            MachineState = DataBlockFound;
            break;
            
          case  "SUPPORTS":
            WScript.Echo("6[" + dataCtrlBlk + "]");
            fgetSupportData(fp);
            s = lastTxtStr;
            MachineState = DataBlockFound;
            //MachineState = MachineScanning;
            break;
            
          case  "MATERIALS":
            WScript.Echo("7[" + dataCtrlBlk + "]");
            fgetMaterialData(fp);
            s = lastTxtStr;
            MachineState = DataBlockFound;
            break;
            
          case  "SECTIONS":
            WScript.Echo("8[" + dataCtrlBlk + "]");
            fgetSectionData(fp);
            s = lastTxtStr;
            MachineState = DataBlockFound;
            break;
            
          case  "JOINT LOADS":
            WScript.Echo("9[" + dataCtrlBlk + "]");
            fgetJointLoadData(fp);
            s = lastTxtStr;
            MachineState = DataBlockFound;
            break;
            
          case  "MEMBER LOADS":
            WScript.Echo("10[" + dataCtrlBlk + "]");
            fgetMemberLoadData(fp);
            s = lastTxtStr;
            if (!fp.AtEndOfStream) {
              MachineState = DataBlockFound;
            } else {
              MachineState = MachineTurnOFF;
            }
            break;
            
          case  "GRAVITY LOADS":
            WScript.Echo("11[" + dataCtrlBlk + "]");
            fgetGravityLoadData(fp);
            s = lastTxtStr;
            MachineState = MachineTurnOFF;
            break;
            
          default:
            MachineState = MachineScanning;
            break;
            
        } //switch
        break;
        
      default:
        if (fp.AtEndOfStream) {
          WScript.Echo("DataBlockFound: End Of File");
          done = true;
          MachineState = MachineTurnOFF;
        } else {
          MachineState = MachineScanning;
        }
        break;
        
    } // Switch: machine state
    
  } //Loop
  
  WScript.Echo("... pframeReader00");

} // End Function



//DATA FILE STORE SUBROUTINES
//------------------------------------------------------------------------------

function SaveDataToTextFile(fp )
{
  var pwid = 40;
  var i;
  
  WScript.Echo("SaveDataToTextFile ...");
  fp.WriteLine("JOB DATA" + dataBlockTag);
  ProjectData.fprint(fp)
  
  //NB: It some versions of original Pascal application require screen magnification factor
  //other versions don//t. if needed and not present the program will crash. if not needed but
  //is present it is simply ignored. Therefore always write to the file.
  fp.WriteLine("CONTROL DATA" + dataBlockTag);
  structParam.fprint(fp)
             
  fp.WriteLine("NODES" + dataBlockTag);
  for(i = baseIndex; i<nod_grp.length;i++)
  {
    nod_grp[i].fprint(fp)
  }

  fp.WriteLine("MEMBERS" + dataBlockTag);
  for(i = baseIndex; i<con_grp.length;i++)
  {
    con_grp[i].fprint(fp);
  }
  
  fp.WriteLine("SUPPORTS" + dataBlockTag);
  for(i = baseIndex; i<sup_grp.length;i++)
  {
    sup_grp[i].fprint(fp);
  }
 
  fp.WriteLine("MATERIALS" + dataBlockTag);
  for(i = baseIndex; i<mat_grp.length;i++)
  {
    mat_grp[i].fprint(fp);
  }
  
  fp.WriteLine("SECTIONS" + dataBlockTag);
  for(i = baseIndex; i<sec_grp.length;i++)
  {
    sec_grp[i].fprint(fp);
  }
  
  fp.WriteLine("JOINT LOADS" + dataBlockTag);
  WScript.Echo("njl= ", structParam.njl);
  for(i = baseIndex; i<jnt_lod.length;i++)
  {
    jnt_lod[i].fprint(fp);
  }
  
  fp.WriteLine("MEMBER LOADS" + dataBlockTag);
  for(i = baseIndex; i<mem_lod.length;i++)
  {
    mem_lod[i].fprint(fp);
  }
  

  fp.WriteLine("GRAVITY LOADS" + dataBlockTag);

  fp.Close();
  
  WScript.Echo("... SaveDataToTextFile");
      
}
