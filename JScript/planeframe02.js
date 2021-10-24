//
// Copyright (c)2014 S C Harrison
// Refer to License.txt for terms and conditions of use.
//



// Need to convert to zero based arrays.
// But also retain some of logic: for example 6 degrees of freedom NOT zero to 5.
// Can ignore the zeroth indexed elements in some situations.
// But ignoring the elements is wasteful of memory
// In JavaScript need to initialise and create the zeroth element before avoid using: not really any different than other language.
// Could use constants or functions for the array indices: though may make less readable {too wordy}
// All table data read in, assumes a starting index of 1: this cannot be used to directly index the arrays.
// Probably shouldn't have been in first place.

//Plan: replace indices with constants/descriptors


//
//------------------------------------------------------------------------------
//INTERFACE
//------------------------------------------------------------------------------
//
// Define Global/Public Variables
//==============================================================================
//var jobData; //(5); // String

var data_loaded; // Boolean

var sumx; // Double
var sumy; // Double



//------------------------------------------------------------------------------
//IMPLEMENTATION
//------------------------------------------------------------------------------

//.. enumeration constants ..
var ndx0=0;
var ndx1=0;
var ndx2=1;

var startIndex=0;
var startZero = 0;
var StartCounter = 1;

var df1 = 0; //degree of freedom 1
var df2 = 1;
var df3 = 2;
var df4 = 3;
var df5 = 4;
var df6 = 5;

var dataBlockTag; // String = "::"

//... Constant declarations ...
 var numloads=80;   // Integer = 80
 var order=50;      // Integer = 50
 var v_size=50;     // Integer = 50
 var max_grps=25;   // Integer = 25
 var max_mats=10;   // Integer = 10
 var n_segs=10;     // Byte = 10

//Scalars
var cosa; // Double               //   .. member's direction cosines ..
var sina; // Double               //   .. member's direction cosines ..
var c2; // Double                 //   .. Cos^2
var s2; // Double                 //   .. Sin^2
var cs; // Double                 //   .. Cos x Sin
var fi; // Double                 //   .. fixed end moment @ end "i" of a member ..
var fj; // Double                 //   .. fixed end moment @ end "j" of a member ..
var a_i; // Double                //   .. fixed end axial force @ end "i" ..
var a_j; // Double                //   .. fixed end axial force @ end "j" ..
var ri; // Double                 //   .. fixed end shear @ end "i" ..
var rj; // Double                 //   .. fixed end shear @ end "j" ..
var dii; // Double                //   .. slope function @ end "i" ..
var djj; // Double                //   .. slope function @ end "j" ..
var ao2; // Double
var ldc; // Integer               //   .. load type
var x1; // Double                 //   .. start position ..
var la; // Double                 //   .. dist from end "i" to centroid of load ..
var lb; // Double                 //   .. dist from end "j" to centroid of load ..
var udl; // Double                //   .. uniform load
var wm1; // Double                //   .. load magnitude 1
var wm2; // Double                //   .. load magnitude 2
var cvr; // Double                //   .. length covered by load
var w1; // Double
var ra; // Double                 //   .. reaction @ end A
var rb; // Double                 //   .. reaction @ end B
var w_nrm; // Double              //   .. total load normal to member ..
var w_axi; // Double              //   .. total load axial to member ..
var wchk; // Double               //   .. check reaction sum on span
var nrm_comp; // Double           //   .. load normal to member
var axi_comp; // Double           //   .. load axial to member
var poa; // Double                //   .. point of application ..
var stn; // Double
var seg; // Double


var hbw; // Integer               //   .. upper band width of the joint stiffness matrix ..
var nn;  // Integer               //   .. No. of degrees of freedom @ the joints ..
var n3; // Integer                //   .. No. of joints x 3 ..
var eaol; // Double               //   .. elements of the member stiffness matrix .. EA/L
var trl; // Double                //   .. true length of a member ..
var gam; // Double                //   .. gamma =  cover/length

var ci; // Double
var cj; // Double
var ccl; // Double
var ai; // Double
var aj; // Double

var global_i; // Byte
var global_j; // Integer
var global_k; // Integer

//Index Variables
var j0; // Integer
var j1; // Integer
var j2; // Integer
var j3; // Integer

//Index Variables
var k0; // Integer
var k1; // Integer
var k2; // Integer
var k3; // Integer

var diff; // Integer
var flag; // Byte
var sect; // Byte
var rel; // Byte


var poslope; // Boolean

var maxM; // Double,
var MinM; // Double
var MaxMJnt; // Byte,
var maxMmemb; // Byte,
var MinMJnt; // Byte,
var MinMmemb; // Byte
var maxA; // Double,
var MinA; // Double
var MaxAJnt; // Byte,
var maxAmemb; // Byte,
var MinAJnt; // Byte,
var MinAmemb; // Byte
var maxQ; // Double
var MinQ; // Double
var MaxQJnt; // Byte,
var maxQmemb; // Byte
var MinQJnt;
var MinQmemb; // Byte


//------------------
//Array Variables
//------------------

//Vectors and Matrices
//Vectors
var mlen=[];                                     //(v_size)                   // Double      //.. member length ..
var rjl=[];                                      //(v_size)                   // Integer     //.. restrained joint list ..
var crl=[];                                      //(v_size)                   // Integer     //.. cumulative joint restraint list ..

var fc=[];                                       //(v_size)                   // Double      //.. combined joint loads ..

var dd=[];                                       //(v_size)                   // Double      //.. joint displacements @ free nodes ..
var dj=[];                                       //(v_size)                   // Double      //.. joint displacements @ ALL the nodes ..
var ad=[];                                       //(v_size)                   // Double      //.. member end forces not including fixed end forces ..
var ar=[];                                       //(v_size)                   // Double      //.. support reactions ..

//Matrices
var rot_mat=[];                                  //(v_size, 2)                // Double      //.. member rotation  matrix ..
var s=[];                                        //(order, v_size)            // Double      //.. member stiffness matrix ..
var sj=[];                                       //(order, v_size)            // Double      //.. joint  stiffness matrix ..

var af=[];                                       //(order, v_size)            // Double      //.. member fixed end forces ..
var mom_spn=[];                                  //(max_grps, 0 To n_segs)    // Double      //.. member span moments ..


//{###### Pf_Solve.PAS ######
// ... a module of Bandsolver routines for ( the Framework Program-
//     R G Harrison   --  Version 1.1  --  12/05/05  ...
//     Revision history //-
//        12/05/05 - implemented ..
//{<<< START CODE >>>>}
//===========================================================================


function getArrayIndex(key) {

  switch(baseIndex)
  {
    case 0:
      return (key - 1);
      break;
    case 1:
      return key;
      break
  }
}



//  << Choleski_Decomposition >>
//  ..  matrix decomposition by the Choleski method..
function Choleski_Decomposition(sj, ndof, hbw) {
  var p,q;  //Integer;
  var su, te; // Double;

  var indx1, indx2, indx3;
  //    WrMat["Decompose IN sj ..", sj, ndof, hbw]
  //    PrintMat["Choleski_Decomposition  IN sj[] ..", sj[], dd[], ndof, hbw]


  WScript.Echo("<Choleski_Decomposition ...>");
  WScript.Echo("ndof, hbw", ndof, hbw);
  for (global_i = baseIndex; global_i < ndof; global_i++) {
        WScript.Echo("global_i=", global_i);
    p = ndof - global_i - 1;

    if (p > hbw-1) {
      p = hbw-1;
    }

    for (global_j = baseIndex; global_j < (p+1); global_j++) {
      q = (hbw-2) - global_j;
      if (q > global_i - 1) {
        q = global_i - 1;
      }

      su = sj[global_i][global_j];

      if (q >= 0) {
        for (global_k = baseIndex; global_k < q+1; global_k++) {
          if (global_i > global_k) {
           //su = su - sj[global_i - global_k][global_k + 1] * sj[global_i - global_k][global_k + global_j];
                  indx1 = global_i - global_k - 1;
                  indx2 = global_k + 1;
                  indx3 = global_k + global_j + 1;
                  su = su - sj[indx1][indx2] * sj[indx1][indx3];
          } // End If [
        } // next k
      } // End If [

      if (global_j != 0) {
        sj[global_i][global_j] = su * te;
      } else {
        if (su <= 0) {
          WScript.Echo("matrix -ve TERM Terminated ???");
          //End

        } else {
          // BEGIN
          te = 1 / Math.sqrt(su);
          sj[global_i][global_j] = te;
        } // End If [
      } // End If [
    } // next j
       
     WScript.Echo("SJ[]: ",global_i);       
     fpTracer.WriteLine("SJ[]: " + global_i.toString());
     fprintMatrix(sj);      
          
          
  } // next i

  //   PrintMat["Choleski_Decomposition  OUT sj[] ..", sj[], dd[], ndof, hbw]

} //.. Choleski_Decomposition ..


//  << Solve_Displacements >>
//  .. perform forward and backward substitution ; i<= solve the system ..
function Solve_Displacements() {
  var su;
  var i, j;
  var idx1, idx2;

  WScript.Echo("<Solve_Displacements ...>");
  for (i = baseIndex; i < nn; i++) {
    j = i + 1 - hbw;
    if (j < 0) {
      j = 0;
    }
    su = fc[i];
    if (j - i + 1 <= 0) {
      for (global_k = j; global_k < i; global_k++) {
        if (i - global_k + 1 > 0) {
          idx1 = i - global_k;
          su = su - sj[global_k][idx1] * dd[global_k];
        } // End If [
      } // next k
    } // End If [
    dd[i] = su * sj[i][df1];
  } // next i

  for (i = nn-1; i >= baseIndex; i--) {
    j = i + hbw - 1;
    if (j > nn-1) {
      j = nn-1;
    }

    su = dd[i];
    if (i + 1 <= j) {
      for (global_k = i + 1; global_k <= j; global_k++) {
        if (global_k + 1 > i) {
          idx2 = global_k - i;
          su = su - sj[i][idx2] * dd[global_k];
        } // End If [
      } // next k
    } // End If [

    dd[i] = su * sj[i][df1];
  } // next i
  //       WrFVector["Solve Displacements  dd..  ", dd[], nn]
} //.. Solve_Displacements ..

//End    ////.. CholeskiDecomp Module ..
//===========================================================================



//{###### Pf_Anal.PAS ######
// ... a module of Analysis Routines for ( the Framework Program -
//     R G Harrison   --  Version 1.1  --  12/05/05  ...
//     Revision history //-
//        12/05/05 - implemented ..

//{<<< START CODE >>>>}
//===========================================================================


//  << Fill_Restrained_Joints_Vector >>
function Fill_Restrained_Joints_Vector() {

  //WScript.Echo("structParam.njt : " + structParam.njt.toString());
  //WScript.Echo("structParam.nr : " + structParam.nr.toString());
  n3 = 3 * structParam.njt;                                          //From Number of Joints
  nn = n3 - structParam.nr;                                          //From Number of Restraints


  //WScript.Echo("<Fill_Restrained_Joints_Vector ...>");
  for (global_i = baseIndex; global_i < structParam.nrj; global_i++) {
    //With sup_grp[global_i]
    j3 = (3 * sup_grp[global_i].js)-1;
    rjl[j3 - 2] = sup_grp[global_i].rx;
    rjl[j3 - 1] = sup_grp[global_i].ry;
    rjl[j3] = sup_grp[global_i].rm;
    //WScript.Echo( j3.toString() + ": rjl.. " +  rjl[j3 - 2] + "," + rjl[j3 - 1] + "," + rjl[j3]);
    // EndWith
  } // next i


  crl[ndx1] = rjl[ndx1];
  //WScript.Echo( ndx1.toString() + ": crl.. ", crl[ndx1]);
  for (global_i = ndx1+1; global_i < n3; global_i++) {
    crl[global_i] = crl[global_i - 1] + rjl[global_i];
    //WScript.Echo( global_i.toString() + ": crl.. ", crl[global_i]);
  } // next i

  //WScript.Echo("Fill_Restrained_Joints_Vector n3, nn, nr .. ", n3, nn, structParam.nr);

} //.. Fill_Restrained_Joints_Vector ..


//-----------------------------------------------------------------------------
//  << Check_J >>
function End_J() // Boolean
{
  var tmp;

  //WScript.Echo("End_J ...");
  tmp = false;
  global_j = j1;
  if (rjl[global_j] == 1) {
    global_j = j2;
    if (rjl[global_j] == 1) {
      global_j = j3;
      if (rjl[global_j] == 1) {
        diff = Translate_Ndx(k3) - Translate_Ndx(k1) + 1;
        tmp = true;
      } // End If [
    } // End If [
  } // End If [

  return tmp;

} //End Function  //.. End_J ..


//  << End_K >>
function End_K() // Boolean
{
  var tmp;

  //WScript.Echo("End_K ...");
  tmp = false;
  global_k = k3;
  if (rjl[global_k] == 1) {
    global_k = k2;
    if (rjl[global_k] == 1) {
      global_k = k1;
      if (rjl[global_k] == 1) {
        diff = Translate_Ndx(j3) - Translate_Ndx(j1) + 1;
        tmp = true;
      } // End If [
    } // End If [
  } // End If [

  return tmp;

} //End Function  //.. End_K ..


//  << Calc_Bandwidth >>
function Calc_Bandwidth() {

  WScript.Echo("<Calc_Bandwidth ...>");
  hbw = 0;
  diff = 0;
  for (global_i = baseIndex; global_i < structParam.nmb; global_i++) {
    //With con_grp[global_i]
    j3 = (3 * con_grp[global_i].jj)-1;
    j2 = j3 - 1;
    j1 = j2 - 1;

    k3 = (3 * con_grp[global_i].jk)-1;
    k2 = k3 - 1;
    k1 = k2 - 1;

    if (!End_J()) {
      //WScript.Echo("BandWidth: Step:1");
      if (!End_K()) {
        //WScript.Echo("BandWidth: Step:2");
        diff = Translate_Ndx(global_k) - Translate_Ndx(global_j) + 1;
        //WScript.Echo("BandWidth: Step:3 : " + diff.toString());
      } // End If [
    } // End If [

    if (diff > hbw) {
      //WScript.Echo("BandWidth: Step:4");
      hbw = diff;
      //WScript.Echo("BandWidth: Step:5 : " + hbw.toString());
    } // End If [

    // EndWith
  } // next i

  //WScript.Echo("Calc_Bandwidth hbw, nn .. ", hbw, nn);

} //.. Calc_Bandwidth ..
//-----------------------------------------------------------------------------


//  << Get_Stiff_Elements >>
// Calculate the Stiffness of Structural Element
function Get_Stiff_Elements(i) // Byte)
{
  var flag; // Byte
  var msect; // Byte
  var mnum; // Byte
  var eiol; // Double EI/L


  WScript.Echo("Get_Stiff_Elements ...");
  //With con_grp[i]
  msect = getArrayIndex(con_grp[i].sect);                            //Section ID/key converted to array index
  mnum = getArrayIndex(sec_grp[msect].mat);                          //Material ID/key converted to array index

  flag = con_grp[i].rel_i + con_grp[i].rel_j;                        //Sum releases each end of member
  eiol = mat_grp[mnum].emod * sec_grp[msect].iz / mlen[i];           //Calculate EI/L

  // WScript.Echo("eiol: " + eiol.toString());
  // WScript.Echo("mlen[i]: " + mlen[i].toString());


  //        .. initialise temp variables ..
  ai = 0;
  aj = ai;
  ao2 = ai / 2;

  switch (flag) {
    case 0:
      ai = 4 * eiol;
      aj = ai;
      ao2 = ai / 2;
      break;

    case 1:
      if (con_grp[i].rel_i == 0) {
        ai = 3 * eiol;
      } else {
        aj = 3 * eiol;
      } // End If
      break;

  } // End Select

  ci = (ai + ao2) / mlen[i];
  cj = (aj + ao2) / mlen[i];
  ccl = (ci + cj) / mlen[i];
  eaol = mat_grp[mnum].emod * sec_grp[msect].ax / mlen[i];

  // EndWith

  cosa = rot_mat[i][ndx1];
  sina = rot_mat[i][ndx2];
} //.. Get_Stiff_Elements ..


//  << Assemble_Stiff_Mat >>
// Assemble
function Assemble_Stiff_Mat(i) // Byte
{

  WScript.Echo("Assemble_Stiff_Mat ...");
  Get_Stiff_Elements(i);

  WScript.Echo("eaol: " + eaol.toString());
  WScript.Echo("cosa: " + cosa.toString());
  WScript.Echo("sina: " + sina.toString());
  WScript.Echo("ccl: " + ccl.toString());
  WScript.Echo("ci: " + ci.toString());
  WScript.Echo("cj: " + cj.toString());
  WScript.Echo("ai: " + ai.toString());
  WScript.Echo("ao2: " + ao2.toString());
  WScript.Echo("aj: " + aj.toString());

  s[df1][df1] = eaol * cosa;
  s[df1][df2] = eaol * sina;
  s[df1][df3] = 0;
  s[df1][df4] = -s[df1][df1];
  s[df1][df5] = -s[df1][df2];
  s[df1][df6] = 0;

  s[df2][df1] = -ccl * sina;
  s[df2][df2] = ccl * cosa;
  s[df2][df3] = ci;
  s[df2][df4] = -s[df2][df1];
  s[df2][df5] = -s[df2][df2];
  s[df2][df6] = cj;

  s[df3][df1] = -ci * sina;
  s[df3][df2] = ci * cosa;
  s[df3][df3] = ai;
  s[df3][df4] = -s[df3][df1];
  s[df3][df5] = -s[df3][df2];
  s[df3][df6] = ao2;

  s[df4][df1] = s[df1][df4];
  s[df4][df2] = s[df1][df5];
  s[df4][df3] = 0;
  s[df4][df4] = s[df1][df1];
  s[df4][df5] = s[df1][df2];
  s[df4][df6] = 0;

  s[df5][df1] = s[df2][df4];
  s[df5][df2] = s[df2][df5];
  s[df5][df3] = -ci;
  s[df5][df4] = s[df2][df1];
  s[df5][df5] = s[df2][df2];
  s[df5][df6] = -cj;

  s[df6][df1] = -cj * sina;
  s[df6][df2] = cj * cosa;
  s[df6][df3] = ao2;
  s[df6][df4] = -s[df6][df1];
  s[df6][df5] = -s[df6][df2];
  s[df6][df6] = aj;

  //  //   PrintMat("Assemble_Stiff_Mat   s () ..", s, dd(), 6, 6)
} //.. Assemble_Stiff_Mat ..


//  << Assemble_Global_Stiff_Matrix >>
//Assemble Member Stiffness Matrix
function Assemble_Global_Stiff_Matrix(i) // Byte)
{

  WScript.Echo("<Assemble_Global_Stiff_Matrix ...>");

  Get_Stiff_Elements(i);

  c2 = cosa * cosa;
  s2 = sina * sina;
  cs = cosa * sina;

  // WScript.Echo("eaol :" + eaol.toString());
  // WScript.Echo("cosa :" + cosa.toString());
  // WScript.Echo("sina :" + sina.toString());

  // WScript.Echo("c2 :" + c2.toString());
  // WScript.Echo("s2 :" + s2.toString());
  // WScript.Echo("cs :" + cs.toString());
  // WScript.Echo("ccl :" + ccl.toString());
  // WScript.Echo("ci :" + ci.toString());
  // WScript.Echo("cj :" + cj.toString());
  // WScript.Echo("ai :" + ai.toString());
  // WScript.Echo("ao2 :" + ao2.toString());
  // WScript.Echo("aj :" + aj.toString());
  // WScript.Echo("-----------------------");

  s[df1][df1] = eaol * c2 + ccl * s2;
  s[df1][df2] = eaol * cs - ccl * cs;
  s[df1][df3] = -ci * sina;
  s[df1][df4] = -s[df1][df1];
  s[df1][df5] = -s[df1][df2];
  s[df1][df6] = -cj * sina;

  s[df2][df2] = eaol * s2 + ccl * c2;
  s[df2][df3] = ci * cosa;
  s[df2][df4] = s[df1][df5];
  s[df2][df5] = -s[df2][df2];
  s[df2][df6] = cj * cosa;

  s[df3][df3] = ai;
  s[df3][df4] = -s[df1][df3];
  s[df3][df5] = -s[df2][df3];
  s[df3][df6] = ao2;

  s[df4][df4] = -s[df1][df4];
  s[df4][df5] = -s[df1][df5];
  s[df4][df6] = -s[df1][df6];

  s[df5][df5] = s[df2][df2];
  s[df5][df6] = -s[df2][df6];

  s[df6][df6] = aj;

  WScript.Echo("<... Assemble_Global_Stiff_Matrix >");

  //  //   PrintMat("Assemble_Global_Stiff_Matrix   s () ..", s, dd(), 6, 6)
} //.. Assemble_Global_Stiff_Matrix ..



//-----------------------------------------------------------------------------

//  << Load_Sj >>
function Load_Sj(j, kk, stiffval) {

  WScript.Echo(">> Load_Sj ...",j,kk,stiffval);
  global_k = Translate_Ndx(kk) - j; 
  
  WScript.Echo("IN:sj[][]: ",j,global_k,sj[j][global_k]);
  sj[j][global_k] = sj[j][global_k] + stiffval;
  WScript.Echo("OUT:sj[][]: ",j,global_k,sj[j][global_k]);
  WScript.Echo();
  
} //.. Load_Sj ..


//  << Process_DOF_J1 >>
function Process_DOF_J1() {

  WScript.Echo("Process_DOF_J1 ...",j1);

  //Process J1
  global_j = Translate_Ndx(j1);
  sj[global_j][df1] = sj[global_j][df1] + s[df1][df1];
  WScript.Echo("OUT:sj[][]: ",global_j,df1,sj[global_j][df1]);
  
  
  //Cascade Influence of J1 down through J2,J3,K1,K2,K3
  if (rjl[j2] == 0) {
    sj[global_j][df2] = sj[global_j][df2] + s[df1][df2];
    WScript.Echo("OUT:sj[][]: ",global_j,df2,sj[global_j][df2]);
  }

  if (rjl[j3] == 0) {
    Load_Sj(global_j, j3, s[df1][df3]);
  }
  if (rjl[k1] == 0) {
    Load_Sj(global_j, k1, s[df1][df4]);
  }
  if (rjl[k2] == 0) {
    Load_Sj(global_j, k2, s[df1][df5]);
  }
  if (rjl[k3] == 0) {
    Load_Sj(global_j, k3, s[df1][df6]);
  }
} //.. Process_DOF_J1 ..


//  << Process_DOF_J2 >>
function Process_DOF_J2() {

  WScript.Echo("Process_DOF_J2 ...",j2);
  
  // Process J2 
  global_j = Translate_Ndx(j2);
  sj[global_j][ df1] = sj[global_j][df1] + s[df2][df2];
  WScript.Echo("OUT:sj[][]: ",global_j,df1,sj[global_j][df1]);
  
  //Cascade influence of J2 through J3, K1, K2, K3 
  if (rjl[j3] == 0) {
    sj[global_j][ df2] = sj[global_j][df2] + s[df2][df3];
    WScript.Echo("OUT:sj[][]: ",global_j,df2,sj[global_j][df2]);
  }

  if (rjl[k1] == 0) {
    Load_Sj(global_j, k1, s[df2][df4]);
  }
  if (rjl[k2] == 0) {
    Load_Sj(global_j, k2, s[df2][df5]);
  }
  if (rjl[k3] == 0) {
    Load_Sj(global_j, k3, s[df2][df6]);
  }
} //.. Process_DOF_J2 ..


//  << Process_DOF_J3 >>
function Process_DOF_J3() {

  WScript.Echo("Process_DOF_J3 ...",j3);

  //Process J3 
  global_j = Translate_Ndx(j3);
  sj[global_j][df1] = sj[global_j][df1] + s[df3][df3];
  WScript.Echo("OUT:sj[][]: ",global_j,df1,sj[global_j][df1]);
  
  
  //Cascade influence J3 through K1, K2, K3 
  if (rjl[k1] == 0) {
    Load_Sj(global_j, k1, s[df3][df4]);
  }
  if (rjl[k2] == 0) {
    Load_Sj(global_j, k2, s[df3][df5]);
  }
  if (rjl[k3] == 0) {
    Load_Sj(global_j, k3, s[df3][df6]);
  }
} //.. Process_DOF_J3 ..


//  << Process_DOF_K1 >>
function Process_DOF_K1() {

  WScript.Echo("Process_DOF_K1 ...",k1);
  
  //Process K1
  global_j = Translate_Ndx(k1);
  sj[global_j][df1] = sj[global_j][df1] + s[df4][df4];
  WScript.Echo("OUT:sj[][]: ",global_j,df1,sj[global_j][df1]);
  

  //Cascade influence K1 through K2, K3 
  if (rjl[k2] == 0) {
  
    WScript.Echo("IN:sj[][]: ",global_j,df2,sj[global_j][df2]);
    WScript.Echo("IN:s[][]: ",df4,df5,s[df4][df5]);
  
    sj[global_j][df2] = sj[global_j][df2] + s[df4][df5];
    
    WScript.Echo("OUT:sj[][]: ",global_j,df2,sj[global_j][df2]);
  }

  if (rjl[k3] == 0) {
    Load_Sj(global_j, k3, s[df4][df6]);
  }
} //.. Process_DOF_K1 ..


//  << Process_DOF_K2 >>
function Process_DOF_K2() {

  WScript.Echo("Process_DOF_K2 ...",k2);
  
  //Process K2
  global_j = Translate_Ndx(k2);
  sj[global_j][df1] = sj[global_j][df1] + s[df5][df5];

  WScript.Echo("OUT:sj[][]: ",global_j,df1,sj[global_j][df1]);
  
  //Cascade influence K2 through K3
  if (rjl[k3] == 0) {
  
    WScript.Echo("IN:sj[][]: ",global_j,df2,sj[global_j][df2]);
    WScript.Echo("IN:s[][]: ",df5,df6,s[df5][df6]);
    
    sj[global_j][df2] = sj[global_j][df2] + s[df5][df6];
    
    WScript.Echo("OUT:sj[][]: ",global_j,df2,sj[global_j][df2]);
  }
} //.. Process_DOF_K2 ..


//  << Process_DOF_K3 >>
function Process_DOF_K3() {
  WScript.Echo("Process_DOF_K3 ...",k3);
  global_j = Translate_Ndx(k3);

  //Process K3
  WScript.Echo("IN:sj[][]: ",global_j,df1,sj[global_j][df1]);
  WScript.Echo("IN:s[][]: ",df6,df6,s[df6][df6]);
  
  sj[global_j][df1] = sj[global_j][df1] + s[df6][df6];
  
  WScript.Echo("OUT:sj[][]: ",global_j,df1,sj[global_j][df1]);
  WScript.Echo();
  
  
} //.. Process_DOF_K3 ..


//  << Assemble_Struct_Stiff_Matrix >>
function Assemble_Struct_Stiff_Matrix(i) // Byte)
{
  //        .. initialise temp variables ..


  WScript.Echo("<Assemble_Struct_Stiff_Matrix ...>",i);
  j3 = (3 * con_grp[i].jj)-1;
  j2 = j3 - 1;
  j1 = j2 - 1;

  k3 = (3 * con_grp[i].jk)-1;
  k2 = k3 - 1;
  k1 = k2 - 1;

  WScript.Echo("J:",j3.toString(),j2.toString(),j1.toString());
  WScript.Echo("K:",k3.toString(),k2.toString(),k1.toString());

  //Process End A
  
  if (rjl[j3] == 0) {
    Process_DOF_J3();
  } //.. do j3 ..

  if (rjl[j2] == 0) {
    Process_DOF_J2();
  } //.. do j2 ..

  if (rjl[j1] == 0) {
    Process_DOF_J1();
  } //.. do j1 ..

  //Process End B
  
  if (rjl[k3] == 0) {
    Process_DOF_K3();
  } //.. do k3 ..

  if (rjl[k2] == 0) {
    Process_DOF_K2();
  } //.. do k2 ..

  if (rjl[k1] == 0) {
    Process_DOF_K1();
  } //.. do k1 ..

  WScript.Echo("<... Assemble_Struct_Stiff_Matrix >",i);


} //.. Assemble_Struct_Stiff_Matrix ..

//-----------------------------------------------------------------------------


//  << Calc_Member_Forces >>
function Calc_Member_Forces() {
  for (global_i = baseIndex; global_i < structParam.nmb; global_i++) {
    //With con_grp[global_i]

    WScript.Echo("<Calc_Member_Forces ...> " + global_i.toString());
    Assemble_Stiff_Mat(global_i);

    //        .. initialise temporary end restraint indices ..
    j3 = 3 * con_grp[global_i].jj-1;
    j2 = j3 - 1;
    j1 = j2 - 1;

    k3 = 3 * con_grp[global_i].jk-1;
    k2 = k3 - 1;
    k1 = k2 - 1;

    for (global_j = baseIndex; global_j <= df6; global_j++) {
      ad[global_j] = s[global_j][df1] * dj[j1] + s[global_j][df2] * dj[j2] + s[global_j][df3] * dj[j3];
      ad[global_j] = ad[global_j] + s[global_j][ df4] * dj[k1] + s[global_j][ df5] * dj[k2] + s[global_j][ df6] * dj[k3];
    } // next j

    //.. Store End forces ..
    WScript.Echo(global_i.toString());
    con_grp[global_i].jnt_jj.axial = -(af[global_i][df1] + ad[df1]);
    con_grp[global_i].jnt_jj.shear = -(af[global_i][df2] + ad[df2]);
    con_grp[global_i].jnt_jj.momnt = -(af[global_i][df3] + ad[df3]);

    con_grp[global_i].jnt_jk.axial = af[global_i][df4] + ad[df4];
    con_grp[global_i].jnt_jk.shear = af[global_i][df5] + ad[df5];
    con_grp[global_i].jnt_jk.momnt = af[global_i][df6] + ad[df6];

    //.. Member Joint j End forces
    if (rjl[j1] != 0) {
      ar[j1] = ar[j1] + ad[df1] * cosa - ad[df2] * sina;
    } //.. Fx
    if (rjl[j2] != 0) {
      ar[j2] = ar[j2] + ad[df1] * sina + ad[df2] * cosa;
    } //.. Fy
    if (rjl[j3] != 0) {
      ar[j3] = ar[j3] + ad[df3];
    } //.. Mz

    //.. Member Joint k End forces
    if (rjl[k1] != 0) {
      ar[k1] = ar[k1] + ad[df4] * cosa - ad[df5] * sina;
    } //.. Fx
    if (rjl[k2] != 0) {
      ar[k2] = ar[k2] + ad[df4] * sina + ad[df5] * cosa;
    } //.. Fy
    if (rjl[k3] != 0) {
      ar[k3] = ar[k3] + ad[df6];
    } //.. Mz


    // EndWith
  } // next i
} //.. Calc_Member_Forces ..


//  << Calc_Joint_Displacements >>
function Calc_Joint_Displacements() {

  WScript.Echo("<Calc_Joint_Displacements ...>");
  for (global_i = baseIndex; global_i < n3; global_i++) {
    if (rjl[global_i] == 0) {
      dj[global_i] = dd[Translate_Ndx(global_i)];
    }
  } // next i
} //.. Calc_Joint_Displacements ..


//  << Get_Span_Moments >>
function Get_Span_Moments() {
  var seg, stn; // Double
  var rx; // Double
  var mx; // Double
  var i, j; // Byte

  WScript.Echo("<Get_Span_Moments ...>");
  //.. Get_Span_Moments ..
  for (i = baseIndex; i < structParam.nmb; i++) {
    seg = mlen[i] / n_segs;
    if (poslope) {
      rx = con_grp[i].jnt_jj.shear;
      mx = con_grp[i].jnt_jj.momnt;
    } else {
      rx = con_grp[i].jnt_jk.shear;
      mx = con_grp[i].jnt_jk.momnt;
    } // End If [

    //With con_grp[i]
    for (j = startZero; j <= n_segs; j++) {
      stn = j * seg;
      //WScript.Echo(i,j,stn, mem_lod[i].mem_no);
      //With mem_lod[i]
      
      // if ((mem_lod[i].lcode == 2) && (stn >= mem_lod[i].start) && (stn - mem_lod[i].start < seg)) {
        // stn = mem_lod[i].start;
      // } // End If [
      
      if (poslope) {
        mom_spn[i][j] = mom_spn[i][j] + rx * stn - mx;
      } else {
        mom_spn[i][j] = mom_spn[i][j] + rx * (stn - mlen[i]) - mx;
      } // End If [

      // EndWith
    } // next j
    // EndWith
  } // next i
} //.. Get_Span_Moments ..
//End    ////.. DoAnalysis Module ..
//===========================================================================



//===========================================================================
//{###### Pf_Load.PAS ######
// ... a unit file of load analysis routines for ( the Framework Program-
//     R G Harrison   --  Version 5.2  --  30/ 3/96  ...
//     Revision history //-
//        29/7/90 - implemented ..
//===========================================================================


//    <<< In_Cover >>>
function In_Cover(x1, x2, mlen) // Boolean
{
  WScript.Echo("In_Cover ...");
  WScript.Echo(x1, x2, mlen);
  if ((x2 == mlen) || (x2 > mlen)) {
    return true;
  } else {
    return ((stn >= x1) && (stn <= x2));
  } // End If [
} //End Function //...In_Cover...


//  << Calc_Moments >>
//  .. RGH   12/4/92
//  .. calc moments ..
function Calc_Moments(mn, mlen, wtot, x1, la, cv, wty, lslope) {
  var x; // Double
  var x2; // Double
  var Lx; // Double
  var idx1; // Integer


  WScript.Echo("Calc_Moments ...",mn);
  
  idx1 = mn - 1
  x2 = x1 + cv;

  seg = mlen / n_segs;

  if (cv != 0) {
    w1 = wtot / cv;
  }

  for (global_j = startZero; global_j <= n_segs; global_j++) {
    stn = global_j * seg;

    if (poslope) {
      x = stn - x1; //.. dist ; i<= sect from stn X-X..
      Lx = stn - la;
    } else {
      x = x2 - stn;
      Lx = la - stn;
    } // End If [

    if (In_Cover(x1, x2, mlen)) {
      switch (wty) //.. calc moments if ( inside load cover..
      {
        case udl_ld:
          //   Uniform Load
          mom_spn[idx1][global_j] = mom_spn[idx1][global_j] - w1 * x*x / 2;
          break;

        case tri_ld:
          //   Triangular Loads
          mom_spn[idx1][global_j] = mom_spn[idx1][global_j] - (w1 * x * x / cv) * x / 3;
          break;

      } // End Select

    } else {
      if (x <= 0) {
        Lx = 0;
      } // End If [

      mom_spn[idx1][global_j] = mom_spn[idx1][global_j] - wtot * Lx;

    } // End If [

  } // next j
} //.. Calc_Moments ..

//    << Combine_Joint_Loads >>
function Combine_Joint_Loads(kMember) // Byte)
{
  var k;
  
  k = kMember - 1;
  
  WScript.Echo("Combine_Joint_Loads ...",kMember);
  cosa = rot_mat[k][ndx1];
  sina = rot_mat[k][ndx2];
  WScript.Echo("cosa:",cosa);
  WScript.Echo("sina:",sina);

  
  //   ... Process end A
  Get_Joint_Indices(con_grp[k].jj);
  WScript.Echo("fc[]: ",fc[j1],fc[j2],fc[j3]);
  fc[j1] = fc[j1] - a_i * cosa + ri * sina; //.. Fx
  fc[j2] = fc[j2] - a_i * sina - ri * cosa; //.. Fy
  fc[j3] = fc[j3] - fi; //.. Mz
  WScript.Echo("fc[]: ",fc[j1],fc[j2],fc[j3]);

  //   ... Process end B
  Get_Joint_Indices(con_grp[k].jk);
  WScript.Echo("fc[]: ",fc[j1],fc[j2],fc[j3]);
  fc[j1] = fc[j1] - a_j * cosa + rj * sina; //.. Fx
  fc[j2] = fc[j2] - a_j * sina - rj * cosa; //.. Fy
  fc[j3] = fc[j3] - fj; //.. Mz
  WScript.Echo("fc[]: ",fc[j1],fc[j2],fc[j3]);

} //.. Combine_Joint_Loads ..


//  << Calc_FE_Forces >>
function Calc_FE_Forces(kMember, la, lb) {
var k;
  WScript.Echo("Calc_FE_Forces ...",k);
  //WScript.Echo(k);

  k = kMember-1;
  WScript.Echo("trl: ",trl);
  WScript.Echo("djj: ",djj);
  WScript.Echo("dii: ",dii);
  
  //.. both ends fixed
  fi = (2 * djj - 4 * dii) / trl;
  fj = (4 * djj - 2 * dii) / trl;
  
  //With con_grp[k]
  flag = con_grp[k].rel_i + con_grp[k].rel_j;
  WScript.Echo("Flag: ",flag);
  
  if (flag == 2) { //.. both ends pinned
    fi = 0;
    fj = 0;
  } // End If [

  if (flag == 1) { //.. propped cantilever
    if ((con_grp[k].rel_i == 0)) { //.. end i pinned
      fi = fi - fj / 2;
      fj = 0;
    } else { //.. end j pinned
      fi = 0;
      fj = fj - fi / 2;
    } // End If [
  } // End If [
  // EndWith

  ri = (fi + fj - w_nrm * lb) / trl;
  rj = (-fi - fj - w_nrm * la) / trl;

  wchk = ri + rj;

  a_i = 0;
  a_j = 0;

} //.. Calc_FE_Forces ..


//<< Accumulate_FE_Actions >>
function Accumulate_FE_Actions(kMemberNum) // Byte)
{
  var k;
  k = kMemberNum - 1

  WScript.Echo("Accumulate_FE_Actions ...",kMemberNum);
  af[k][df1] = af[k][df1] + a_i;
  af[k][df2] = af[k][df2] + ri;
  af[k][df3] = af[k][df3] + fi;
  af[k][df4] = af[k][df4] + a_j;
  af[k][df5] = af[k][df5] + rj;
  af[k][df6] = af[k][df6] + fj;
} //.. Accumulate_FE_Actions ..


//<< Process_FE_Actions >>
function Process_FE_Actions(kMemberNum, la, lb) {
  WScript.Echo("Process_FE_Actions ...",kMemberNum);
  Accumulate_FE_Actions(kMemberNum);
  Combine_Joint_Loads(kMemberNum);
} //.. Process_FE_Actions ..


//    << Do_Global_Load >>
function Do_Global_Load(mem, acd, w0, start) {
  WScript.Echo("Do_Global_Load ...");
  switch (acd) {
    case global_x:
      // .. global X components
      nrm_comp = w0 * sina;
      axi_comp = w0 * cosa;
      break;
    case global_y:
      // .. global Y components
      nrm_comp = w0 * cosa;
      axi_comp = w0 * sina;
      break;
  } // End Select

} //.. Do_Global_Load ..


//<< Do_Axial_Load >>
//.. Load type = "v" => #3
function Do_Axial_Load(mno, wu, x1) {
  WScript.Echo("Do_Axial_Load ...");
  w_nrm = wu;
  la = x1;
  lb = trl - la;
  a_i = -wu * lb / trl;
  a_j = -wu * la / trl;
  fi = 0;
  fj = 0;
  ri = 0;
  rj = 0;
  Process_FE_Actions(mno, la, lb);

} //.. Do_Axial_Load ..


//    << Do_Self_Weight >>
function Do_Self_Weight(mem) // Byte)
{
  var msect; // Byte,
  var mat; // Byte
  var idxMem,idxMsect,idxMat;

  WScript.Echo("Do_Self_Weight ...");
  
  //Convert Member Number to Array Index
  idxMem = mem - 1;
  
  //Convert Section Number to Array Index
  msect = con_grp(idxMem).sect;
  idxMsect = msect - 1;
  
  //Convert Material Number to Array Index
  mat = sec_grp[idxMsect].mat;
  idxMat = mat - 1;
  
  udl = udl * mat_grp[idxMat].density * sec_grp[idxMsect].ax / kilo;
} //.. Do_Self_Weight ..


//  << UDL_Slope >>
function UDL_Slope(w0, v, c) // Double
{
  WScript.Echo("UDL_Slope ...");
  return (w0 * v * (4 * (trl*trl - v*v) - c*c) / (24 * trl));
} //End Function //.. UDL_Slope ..


//<< Do_Part_UDL >>
//.. Load type = "u" => #1
function Do_Part_UDL(mno, wu, x1, cv, wact) {
  var la;
  var lb; // Double

  la = x1 + cv / 2;
  lb = trl - la;

  WScript.Echo("Do_Part_UDL ...",mno);
  if (wact != local_act) {
    Do_Global_Load(mno, wact, wu, x1);
    w_axi = axi_comp * cv;
    Do_Axial_Load(mno, w_axi, la);
  } else {
    nrm_comp = wu;
    axi_comp = 0;
  } // End If [

  w_nrm = nrm_comp * cv;
  dii = UDL_Slope(w_nrm, lb, cv);
  djj = UDL_Slope(w_nrm, la, cv);

  Calc_Moments(mno, trl, w_nrm, x1, la, cv, udl_ld, pos_slope); //.. Calculate the span moments
  Calc_FE_Forces(mno, la, lb);
  Process_FE_Actions(mno, la, lb);
  
  WScript.Echo("... Do_Part_UDL");
  
} //.. Do_Part_UDL ..


//<< PL_Slope >>
function PL_Slope(v) // Double) // Double
{
  WScript.Echo("PL_Slope ...");
  return (w_nrm * v * (trl*trl - v*v) / (6 * trl));
} //End Function //.. PL_Slope ..


//<< Do_Point_load >>
//.. Load type = "p" => #2
function Do_Point_load(mno, wu, x1, wact) {

  WScript.Echo("Do_Point_load ...");
  la = x1;
  lb = trl - la;

  if (wact != local_act) {
    Do_Global_Load(mno, wact, wu, x1);
    w_axi = axi_comp;
    Do_Axial_Load(mno, w_axi, la);
  } else {
    nrm_comp = wu;
    axi_comp = 0;
  } // End If [

  w_nrm = nrm_comp;

  dii = PL_Slope(lb);
  djj = PL_Slope(la);

  Calc_Moments(mno, trl, w_nrm, x1, la, 0, pnt_ld, pos_slope); //.. Calculate the span moments
  Calc_FE_Forces(mno, la, lb);
  Process_FE_Actions(mno, la, lb);

} //.. Do_Point_load ..


//<< Tri_Slope >>
function Tri_Slope(v, w_nrm, cv, sl_switch) // Double
{
  WScript.Echo("Tri_Slope ...");
  gam = cv / trl;
  v = v / trl;
  return (w_nrm * trl*trl * (270 * (v - v*v*v) - gam * gam * (45 * v + sl_switch * 2 * gam)) / 1620);
} //End Function //.. Tri_Slope ..

//<< Do_Triangle >>
//.. Load type =
function Do_Triangle(mno, w0, la, x1, cv, wact, slopedir) {
  var lb; // Double


  WScript.Echo("Do_Triangle ...");
  lb = trl - la;

  if (wact != local_act) {
    Do_Global_Load(mno, wact, w0, x1);
    w_axi = axi_comp * cv / 2;
    Do_Axial_Load(mno, w_axi, la);
  } else {
    nrm_comp = w0;
    axi_comp = 0;
  } // End If [

  w_nrm = nrm_comp * cv / 2;

  dii = Tri_Slope(lb, w_nrm, cv, pos_slope * slopedir); //.. /!  => +ve when +ve slope
  djj = Tri_Slope(la, w_nrm, cv, neg_slope * slopedir); //.. !\  => +ve when -ve slope

  Calc_Moments(mno, trl, w_nrm, x1, la, cv, tri_ld, slopedir); //.. Calculate the span moments
  Calc_FE_Forces(mno, la, lb);
  Process_FE_Actions(mno, la, lb);

} //.. Do_Triangle ..



//<< Do_Distributed_load >>
//.. Load type = "v" => #1
function Do_Distributed_load(mno, wm1, wm2, x1, cv, lact) {
  var wudl; // Double,
  var wtri; // Double,
  var slope; // Double,
  var ltri; // Double

  WScript.Echo("Do_Distributed_load ...",mno);

  if (wm1 == wm2) { //..  load is a UDL
    Do_Part_UDL(mno, wm1, x1, cv, lact);
  } else {
    if (Math.abs(wm1) < Math.abs(wm2)) { //..  positive slope ie sloping upwards / left ; i<= right
      wudl = wm1;
      wtri = wm2 - wudl;
      slope = pos_slope;
      ltri = x1 + 2 * cv / 3;
    } else { //..  negative slope ie sloping upwards \ right ; i<= left
      wudl = wm2;
      wtri = wm1 - wudl;
      slope = neg_slope;
      ltri = x1 + cv / 3;
    } // End If [

    poslope = (slope == pos_slope);

    if (wudl != 0) {
      Do_Part_UDL(mno, wudl, x1, cv, lact);
    } // End If [

    if (wtri != 0) {
      Do_Triangle(mno, wtri, ltri, x1, cv, lact, slope);
    } // End If [

  } // End If [
  
  WScript.Echo("... Do_Distributed_load");

} //.. Do_Distributed_load ..



//    << Get_FE_Forces >>
function Get_FE_Forces(kMemberNum, ldty, wm1, wm2, x1, cvr, lact) {


  WScript.Echo("Get_FE_Forces ...",kMemberNum);
  switch (ldty) //.. Get_FE_Forces ..
  {
    case dst_ld:
      //..  "v" = #1
      Do_Distributed_load(kMemberNum, wm1, wm2, x1, cvr, lact);
      break;
    case pnt_ld:
      //..  "p" = #2
      Do_Point_load(kMemberNum, wm1, x1, lact);
      break;
    case axi_ld:
      //..  "a" = #3
      Do_Axial_Load(kMemberNum, wm1, x1);
      break;

  } // End Select

} //.. Get_FE_Forces ..


//  << Process_Loadcases >>
function Process_Loadcases() {
  var idxMem;

  WScript.Echo("<Process_Loadcases ...>");
  if (structParam.njl != 0) {
    WScript.Echo("[Joint Loads]");
    WScript.Echo("nml = " + structParam.njl.toString());
    for (global_i = baseIndex; global_i < structParam.njl; global_i++) {
      //With jnt_lod[global_i]
      Get_Joint_Indices(jnt_lod[global_i].jt);

      fc[j1] = jnt_lod[global_i].fx;
      fc[j2] = jnt_lod[global_i].fy;
      fc[j3] = jnt_lod[global_i].mz;
      // EndWith
    } // next i
  } // End If [

  if (structParam.nml != 0) {
    WScript.Echo("[Member Loads]");
    WScript.Echo("nml = " + structParam.nml.toString());
    for (global_i = baseIndex; global_i < structParam.nml; global_i++) {
      //With mem_lod[global_i]
      WScript.Echo("i= ",global_i);
      idxMem = mem_lod[global_i].mem_no - 1;
      WScript.Echo("mem_no= ",mem_lod[global_i].mem_no);
      trl = mlen[idxMem];
      cosa = rot_mat[idxMem][ ndx1]; //.. Cos
      sina = rot_mat[idxMem][ ndx2]; //.. Sin
      ldc = mem_lod[global_i].lcode;
      wm1 = mem_lod[global_i].ld_mag1;
      wm2 = mem_lod[global_i].ld_mag2;
      cvr = mem_lod[global_i].cover;
      x1 = mem_lod[global_i].start;
      if ((ldc == dst_ld) && (cvr == 0)) {
        x1 = 0;
        cvr = trl;
      } // End If [
      //Pass Member Numbers, Convert to Index internally
      Get_FE_Forces(mem_lod[global_i].mem_no, ldc, wm1, wm2, mem_lod[global_i].start, cvr, mem_lod[global_i].f_action);
      fpTracer.WriteLine("FC[]:" + global_i.toString());
      fprintVector(fc);
      fpTracer.WriteLine(); 
      // EndWith
      WScript.Echo();
      
    } // next i
  } // End If [

  if (structParam.ngl != 0) {
    WScript.Echo("[Gravity Loads]");
    WScript.Echo("ngl = " + structParam.ngl.toString());
    for (i = baseIndex; i < structParam.nmb; i++) {
      //With grv_lod
      x1 = 0;
      trl = mlen[global_i];
      cvr = trl;
      cosa = rot_mat[global_i][ndx1];
      sina = rot_mat[global_i][ndx2];
      udl = grv_lod.load;
      ldc = dst_ld; // ud_ld        //.. 1
      Do_Self_Weight(global_i);
      nrm_comp = udl;
      if (grv_lod.f_action != local_act) {
        Do_Global_Load(global_i, grv_lod.f_action, udl, 0);
      } // End If [
      Get_FE_Forces(global_i, dst_ld, nrm_comp, nrm_comp, x1, cvr, grv_lod.f_action);
      // EndWith
    } // next i
  } // End If [
} //.. Process_Loadcases ..

//End    ////.. DoLoads Module ..
//===========================================================================




//  << Zero_Vars >>
function Zero_Vars() {
  var i,j;

  WScript.Echo("Zero_Vars ...");
  //Erase mlen;  // Each element set ; i<= 0.
  for(i=0;i<v_size;i++) {
    mlen[i] = 0;
  }

  //Erase ad;
  for(i=0;i<v_size;i++) {
    ad[i] = 0;
  }

  //Erase fc;
  for(i=0;i<v_size;i++) {
    fc[i] = 0;
  }

  //Erase ar;
  for(i=0;i<v_size;i++) {
    ar[i] = 0;
  }

  //Erase dj;
  for(i=0;i<v_size;i++) {
    dj[i] = 0;
  }

  //Erase dd;
  for(i=0;i<v_size;i++) {
    dd[i] = 0;
  }

  //Erase rjl;
  for(i=0;i<v_size;i++) {
    rjl[i] = 0;
  }

  //Erase crl;
  for(i=0;i<v_size;i++) {
    crl[i] = 0;
  }

  //Erase rot_mat;
  for(i=0;i<v_size;i++) {
    rot_mat[i] = new Array();
    for (j=0;j<2;j++)
        rot_mat[i][j] = 0;
  }

  for(i=0;i<order;i++) {
    af[i] = new Array();
    for (j=0;j<v_size;j++)
        af[i][j] = 0;
  }

  //Erase sj;
  for(i=0;i<order;i++) {
    sj[i] = new Array();
    for (j=0;j<v_size;j++)
        sj[i][j] = 0;
  }

  for(i=0;i<order;i++) {
    s[i] = new Array();
    for (j=0;j<v_size;j++)
    s[i][j] = 0;
  }


  for(i=0;i<max_grps;i++) {
    mom_spn[i] = new Array();
    for (j=0;j<(n_segs+1);j++)
        mom_spn[i][j] = 0;
  }

} //.. Zero_Vars ..



//  << Initialise >>
function Initialise() {
  WScript.Echo("<Initialise ...>");
  ra = 0;
  rb = 0;
  global_i= 0;
  global_j = 0;
  global_k = 0;
  ai = 0;
  aj = 0;
  lb = 0;
  ci = 0;
  cj = 0;
  ccl = 0;
  eaol = 0;

  Zero_Vars();
  Get_Direction_Cosines();

} //.. Initialise ..



//  << Translate_Ndx >>
//  .. Restrained joint index
function Translate_Ndx(i) // Byte) // Integer
{
  //WScript.Echo("Translate_Ndx ...",i);
  return ( i - crl[i]);
} //End Function  //.. Translate_Ndx ..



//  << Equiv_Ndx >>
//  ..equivalent matrix configuration joint index numbers
function Equiv_Ndx(j) // Integer
{
  //WScript.Echo("Equiv_Ndx ...",j);
  return (rjl[j] * (nn + crl[j]) + (1 - rjl[j]) * Translate_Ndx(j));
} //End Function //.. Equiv_Ndx ..


//  << Get_Joint_Indices >>
//  ..  get equivalent matrix index numbers
function Get_Joint_Indices(nd) // Byte)
{
  WScript.Echo("Get_Joint_Indices ...",nd);
  j0 = (3 * nd)-1;
  j3 = Equiv_Ndx(j0);
  j2 = j3 - 1;
  j1 = j2 - 1;
  
  WScript.Echo(j0,j1,j2,j3);
  
} //.. Get_Joint_Indices ..


//  << Get_Direction_Cosines >>
function Get_Direction_Cosines() {
  var i; // Byte
  var tmp; // Byte
  var rel_tmp; // Byte
  var xm; // Double
  var ym; // Double


  WScript.Echo("Get_Direction_Cosines ...");
  for (i = baseIndex; i < structParam.nmb; i++) {
    //With con_grp[i]
    //WScript.Echo( i.toString() + ": " + con_grp[i].jj.toString() + " , " + con_grp[i].jk.toString())

    //Swap node subscripts so that near end subscript (jj) is smaller than far end subscript (jk)
    if (con_grp[i].jk < con_grp[i].jj) { //.. swap end1 with end2 if smaller !! ..
      tmp = con_grp[i].jj;
      con_grp[i].jj = con_grp[i].jk;
      con_grp[i].jk = tmp;

      rel_tmp = con_grp[i].rel_j;
      con_grp[i].rel_j = con_grp[i].rel_i;
      con_grp[i].rel_i = rel_tmp;
    } // End If

    //Calculate deltaX and deltaY
    xm = nod_grp[getArrayIndex(con_grp[i].jk)].x - nod_grp[getArrayIndex(con_grp[i].jj)].x;
    ym = nod_grp[getArrayIndex(con_grp[i].jk)].y - nod_grp[getArrayIndex(con_grp[i].jj)].y;
    //Calculate Length of Member
    mlen[i] = Math.sqrt(xm * xm + ym * ym);

    //WScript.Echo( i.toString() + ": mlen[i]: " + mlen[i].toString());

    //rot_mat[i] = new Array();
    //Determine Direction Cosines : Unit Direction Vector for member
    rot_mat[i][ndx1] = xm / mlen[i]; //.. Cos
    rot_mat[i][ndx2] = ym / mlen[i]; //.. Sin

    // EndWith
  } // next i

  WScript.Echo("... Get_Direction_Cosines");

} //.. Get_Direction_Cosines ..



//  << Total_Section_Mass >>
function Total_Section_Mass() {
  var i; // Integer

  WScript.Echo("Total_Section_Mass ...");
  for (i = baseIndex; i < structParam.nsg; i++) {
    //With mat_grp[sec_grp[i].mat]
    sec_grp[i].t_mass = sec_grp[i].ax * mat_grp[getArrayIndex(sec_grp[i].mat)].density * sec_grp[i].t_len;
    //WScript.Echo(getArrayIndex(sec_grp[i].mat));
    //WScript.Echo(mat_grp[getArrayIndex(sec_grp[i].mat)].density);
    //WScript.Echo(i.toString() + ": " + sec_grp[i].t_mass.toString());
    // EndWith
  } // next i
} //.. Total_Section_Mass ..



//  << Total_Section_Length >>
// Total length of all members of a given Section.
function Total_Section_Length() {
  var ndx;

  WScript.Echo("<Total_Section_Length>");
  for (global_i = baseIndex; global_i < structParam.nmb; global_i++) {
    //With con_grp[global_i]
    ndx=getArrayIndex(con_grp[global_i].sect);
    //WScript.Echo(ndx.toString() + ": " + mlen[global_i].toString());
    sec_grp[ndx].t_len = sec_grp[ndx].t_len + mlen[global_i];
    //WScript.Echo(sec_grp[ndx].t_len.toString());
    // EndWith
  } // next i
  Total_Section_Mass();
} //.. Total_Section_Length ..


//    << Get_Min_Max >>
//    ..find critical End forces ..
function Get_Min_Max() {


  WScript.Echo("<Get_Min_Max ...>");
  maxM = 0;
  MaxMJnt = 0;
  maxMmemb = 0;

  MinM = infinity;
  MinMJnt = 0;
  MinMmemb = 0;

  maxA = 0;
  MaxAJnt = 0;
  maxAmemb = 0;

  MinA = infinity;
  MinAJnt = 0;
  MinAmemb = 0;

  for (global_i = baseIndex; global_i < structParam.nmb; global_i++) {


    //With con_grp[global_i]

    //         .. End moments ..
    if (maxM < con_grp[global_i].jnt_jj.momnt) {
      maxM = con_grp[global_i].jnt_jj.momnt;
      MaxMJnt = con_grp[global_i].jj;
      maxMmemb = global_i;
    } // End If [

    if (maxM < con_grp[global_i].jnt_jk.momnt) {
      maxM = con_grp[global_i].jnt_jk.momnt;
      MaxMJnt = con_grp[global_i].jk;
      maxMmemb = global_i;
    } // End If [

    if (MinM > con_grp[global_i].jnt_jj.momnt) {
      MinM = con_grp[global_i].jnt_jj.momnt;
      MinMJnt = con_grp[global_i].jj;
      MinMmemb = global_i;
    } // End If [

    if (MinM > con_grp[global_i].jnt_jk.momnt) {
      MinM = con_grp[global_i].jnt_jk.momnt;
      MinMJnt = con_grp[global_i].jk;
      MinMmemb = global_i;
    } // End If [

    //         .. End axials ..
    if (maxA < con_grp[global_i].jnt_jj.axial) {
      maxA = con_grp[global_i].jnt_jj.axial;
      MaxAJnt = con_grp[global_i].jj;
      maxAmemb = global_i;
    } // End If [

    if (maxA < con_grp[global_i].jnt_jk.axial) {
      maxA = con_grp[global_i].jnt_jk.axial;
      MaxAJnt = con_grp[global_i].jk;
      maxAmemb = global_i;
    } // End If [

    if (MinA > con_grp[global_i].jnt_jj.axial) {
      MinA = con_grp[global_i].jnt_jj.axial;
      MinAJnt = con_grp[global_i].jj;
      MinAmemb = global_i;
    } // End If [

    if (MinA > con_grp[global_i].jnt_jk.axial) {
      MinA = con_grp[global_i].jnt_jk.axial;
      MinAJnt = con_grp[global_i].jk;
      MinAmemb = global_i;
    } // End If [

    //         .. End shears..
    if (maxQ < con_grp[global_i].jnt_jj.shear) {
      maxQ = con_grp[global_i].jnt_jj.shear;
      MaxQJnt = con_grp[global_i].jj;
      maxQmemb = global_i;
    } // End If [

    if (maxQ < con_grp[global_i].jnt_jk.shear) {
      maxQ = con_grp[global_i].jnt_jk.shear;
      MaxQJnt = con_grp[global_i].jk;
      maxQmemb = global_i;
    } // End If [

    if (MinQ > con_grp[global_i].jnt_jj.shear) {
      MinQ = con_grp[global_i].jnt_jj.shear;
      MinQJnt = con_grp[global_i].jj;
      MinQmemb = global_i;
    } // End If [

    if (MinQ > con_grp[global_i].jnt_jk.shear) {
      MinQ = con_grp[global_i].jnt_jk.shear;
      MinQJnt = con_grp[global_i].jk;
      MinQmemb = global_i;
    } // End If [

    // EndWith
  } // next i
} //{.. Get_Min_Max ..}


function TraceRotMat() {
  var stmp;
  var i,j;

  fpTracer.WriteLine("rot_mat[i][j] ... ");
  for(i=0;i<v_size;i++) {
    for (j=0;j<2;j++) {
      stmp = rot_mat[i][j];
      stmp = stmp.toFixed(4);
      fpTracer.Write(StrLPad(stmp.toString(),15));
    }
    fpTracer.WriteLine();
  }

}

function Trace_s() {
  var stmp;
  var i,j;

  fpTracer.WriteLine("s[i][j] ... ");
  for(i=df1;i<df6+1;i++) {
    for (j=df1;j<df6+1;j++) {
      stmp = s[i][j];
      stmp = stmp.toFixed(4);
      fpTracer.Write(StrLPad(stmp.toString(),15));
    }
    fpTracer.WriteLine();
  }


}

function Trace_sj() {
  var stmp;
  var i,j;

  WScript.Echo("Trace_sj ...");
  fpTracer.WriteLine("sj[i][j] ... ");
  for(i=startIndex;i<order;i++) {
    for (j=startIndex;j<v_size;j++) {

      stmp = sj[i][j];
      //WScript.Echo(i,j,"<" + stmp.toString() + ">");
      stmp = stmp.toFixed(4);
      fpTracer.Write(StrLPad(stmp.toString(),15));
    }
    fpTracer.WriteLine();
  }
  WScript.Echo("... Trace_sj");
}




//   << Analyse_Frame >>
function Analyse_Frame() {

  var i;

  //Get definition of the Plane Frame ; i<= Analyse

  //    Set MiWrkBk = ActiveWorkbook
  WScript.Echo(">>> Analysis of Frame Started <<<");
  //    Erase sec_grp
  //     Jotter
  //     GetData

//All Data required for analysis to be loaded into arrays
//before calling this procedure.

//Define Global/Public Variables and Initialise
  Initialise();

  //BEGIN PLANE FRAME ANALYSIS

  Fill_Restrained_Joints_Vector();
  fpTracer.WriteLine("rjl");
  fprintVector(rjl);

  fpTracer.WriteLine();
  fpTracer.WriteLine("crl");
  fprintVector(crl);

  Total_Section_Length();

  //Calculate Bandwidth
  Calc_Bandwidth();
  fpTracer.WriteLine();
  fpTracer.Write("hbw:");
  fpTracer.WriteLine(hbw.toString());
  fpTracer.Write("nn:");
  fpTracer.WriteLine(nn.toString());


  //Assemble Stiffness Matrix
  WScript.Echo();
  WScript.Echo(">>> Assemble_Global_Stiff_Matrix <<<");
  for (i = baseIndex; i < structParam.nmb; i++) {
    Assemble_Global_Stiff_Matrix(i);
    //Trace_s();
    fpTracer.Write("S[]: ");
    fpTracer.WriteLine(i.toString());
    fprintMatrix(s);
    
    WScript.Echo();
    Assemble_Struct_Stiff_Matrix(i);
    // Trace_sj();
    fpTracer.Write("SJ[]: ");
    fpTracer.WriteLine(i.toString());
    fprintMatrix(sj);
    WScript.Echo();


  } // next i



  //Trace Calculations
  //TraceRotMat();
  //END Trace



 //Decompose Stiffness Matrix
 fpTracer.WriteLine("Choleski_Decomposition ... ");
 Choleski_Decomposition(sj, nn, hbw);
 fpTracer.WriteLine("Result: SJ[]: ");
 fprintMatrix(sj);
 fpTracer.WriteLine();

 //Fixed End Forces & Combined Joint Loads
 Process_Loadcases();
 fpTracer.WriteLine("FC[]: Result: ");
 fprintVector(fc);
 fpTracer.WriteLine();
 
 fpTracer.WriteLine("AF[]: ");
 fprintMatrix(af);
 fpTracer.WriteLine();
 

 //Solve Joint Displacements
 Solve_Displacements();
 fpTracer.WriteLine("DD[]: ");
 fprintVector(dd);
 fpTracer.WriteLine();
 
 Calc_Joint_Displacements();
 fpTracer.WriteLine("DJ[]: ");
 fprintVector(dj);
 

 //Calculate Member Forces
 Calc_Member_Forces();
 
 //cprint();
 
 Get_Span_Moments();
 Get_Min_Max();

  //END OF PLANEFRAME ANALYSIS

  //Do something with the results of the analysis
  //    PrintResults();
  // TestDesignCADD2

  WScript.Echo("*** Analysis Completed *** ");

} //.. Analyse_Frame ..

//===========================================================================
//END    ''.. Main Module ..
//===========================================================================

//===========================================================================
