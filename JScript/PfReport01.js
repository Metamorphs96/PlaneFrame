//
// Copyright (c)2014 S C Harrison
// Refer to License.txt for terms and conditions of use.
//


//###### Pf_Prt.PAS ######
// ... a unit file of output printer routines for ( the Framework analysis program ...
//     R G Harrison   --  Version 5.2  --  30/ 3/96  ...
//
//     Revision history :-
//        31/12/95 - implemented ..
//        17/ 2/96 - changed ; MicroSTRAN sign convention for ( output ..
//        29/ 2/96 - member } releases added
//         4/ 3/96 - main data structures made DYNAMIC
//        30/ 3/96 - graphics routines standardised
//
//
//UNIT Pf_Prt;
//INTERFACE
//USES
//      Pf_Anal,
//      Pf_vars,
//      Files000;          /*.. Application variables ..*/
//
//   function Output_Results;
//
//
//===========================================================================
//
//IMPLEMENTATION


var lm = 10;
var page_len = 66;
var line_tol = 2;

var pageno, title_len;
var count;
var k; // INTEGER;
var firstpage; // BOOLEAN;




//var maxM, MinM, maxQ, MinQ, maxA, MinA; // double;
//var MaxMJnt, maxMmemb, MinMJnt, MinMmemb;
//var MaxQJnt, maxQmemb, MinQJnt, MinQmemb;
//var MaxAJnt, maxAmemb, MinAJnt, MinAmemb; // BYTE;

var  maxM = 0;
var  MaxMJnt = 0;
var  maxMmemb = 0;
var  MinM = infinity;
var  MinMJnt = 0;
var  MinMmemb = 0;
var  maxQ = 0;
var  MaxQJnt = 0;
var  maxQmemb = 0;

var  MinQ = infinity;
var  MinQJnt = 0;
var  MinQmemb = 0;
var  maxA = 0;
var  MaxAJnt = 0;
var  maxAmemb = 0;
var  MinA = infinity;
var  MinAJnt = 0;
var  MinAmemb = 0;

var sumx, sumy; // double;


//  <<< UnderLine >>>
//   ...   commence
//   ...   RGH   23/5/95
function sprintUnderLine() {
  return "-------------------------------------------------------------------------"
}

function UnderLine() {
  WScript.Echo("UnderLine ...");
  fpRpt.WriteLine(StrNset("", lm) + sprintUnderLine());
} /*...UnderLine ..*/


//  <<< HeadLine >>>
//  " ...   commence
//  " ...   RGH   23/5/95
function HeadLine() {
  var tmp_str, date_str; // String80;
  
  WScript.Echo("HeadLine ...");
  UnderLine();
  fpRpt.WriteLine(StrNset("", lm) + ">>> FRAMEwork <<< (Version 5.1 Mar 96)");
} /*...HeadLine  */


/*
//  << Prt_Titles >>
//  .. function based on ref#? p?
//     algorithm
//     Modified RGH :-
//     6/2/92 - implemented ..
  */
function Prt_Titles(title, title_len) {
  var txt;
  
  WScript.Echo("Prt_Titles ...");
  fpRpt.WriteLine();
  switch (title) {
    case 1:
      {
        fpRpt.WriteLine(StrNset("", lm) + "Structure Data");
        UnderLine();
        break;
      }


    case 2:
      {
        fpRpt.WriteLine(StrNset("", lm) + "Joint Coordinates");
        UnderLine();
        fpRpt.WriteLine("JOINT" + StrNset("", 6 + lm) + StrLPad("X(m)", 10) + StrLPad("Y(m)", 10));
        break;
      }


    case 3:
      {
        fpRpt.WriteLine(StrNset("", lm) + "Member Connectivity");
        UnderLine();
        txt = "MEMBER" + StrNset("", 7 + lm) + StrLPad("Node", 6) + StrLPad("Node", 6) + StrLPad("Section", 8);
        txt = txt + StrLPad("Zi", 6) + StrLPad("Zj", 3), StrLPad("Length", 10);
        fpRpt.WriteLine(txt);
        break;
      }


    case 4:
      {
        fpRpt.WriteLine(StrNset("", lm) + "Support Restraints ");
        UnderLine();
        fpRpt.WriteLine("SUPPORT" + StrNset("", 8 + lm) + StrLPad("X", 8) + StrLPad("Y", 2) + StrLPad("Z", 2));
        break;
      }


    case 5:
      {
        fpRpt.WriteLine(StrNset("", lm) + "Member Section Properties ");
        UnderLine();
        fpRpt.WriteLine("SECTION" + StrNset("", 8 + lm) + StrLPad("A", 13) + StrLPad("I", 13) + StrLPad("Material", 10) + StrLPad("Description", 20));
        fpRpt.WriteLine(StrNset("", 8 + lm) + StrLPad("[mý]", 13) + StrLPad("[m4]", 13));
        break;
      }


    case 6:
      {
        fpRpt.WriteLine(StrNset("", lm) + "Material Properties ");
        UnderLine();
        fpRpt.WriteLine("Material" + StrNset("", 9 + lm) + StrLPad("Density", 10) + StrLPad(" -E- ", 11) + StrLPad(" - u - ", 14));
        break;
      }


    case 7:
      {
        fpRpt.WriteLine(StrNset("", lm) + "Framework Quantities ");
        UnderLine();
        fpRpt.WriteLine("SECTION" + StrNset("", 8 + lm) + StrLPad("TOTAL", 12) + StrLPad("TOTAL", 12) + StrLPad("Description", 20));
        fpRpt.WriteLine(StrNset("", 8 + lm) + StrLPad("Length", 12) + StrLPad("Mass", 12));
        break;
      }


    case 8:
      {
        fpRpt.WriteLine(StrNset("", lm) + "Applied Member Loads");
        UnderLine();
        fpRpt.Write("Memb" + StrNset("", 8 + lm) + StrLPad("Type", 8) + StrLPad("Action", 8) + StrLPad("Load", 12));
        fpRpt.WriteLine(StrLPad("start", 12) + StrLPad("Cover", 12))
        break;
      } /*.. Prt_Member_Loads_Header ..*/


    case 9:
      {
        fpRpt.WriteLine(StrNset("", lm) + "Applied Joint Loads");
        UnderLine();
        fpRpt.WriteLine("Joint" + StrNset("", 8 + lm) + StrLPad("X", 12) + StrLPad("Y", 12) + StrLPad("Z", 12));
        break;
      } /*.. Prt_Joint_Loads_Header ..*/


    case 10:
      {
        fpRpt.WriteLine(StrNset("", lm) + "Joint displacements {.. Global Co-ords ..}");
        UnderLine();
        fpRpt.WriteLine("Node" + StrNset("", 8 + lm) + StrLPad("  X  ", 10) + StrLPad("  Y  ", 10) + StrLPad("  Rot ", 10));
        fpRpt.WriteLine(" [m]" + StrNset("", 18 + lm) + StrLPad(" [m]", 10) + StrLPad("[rads]", 10));
        break;
      } /*.. Prt_Joint_Disp_Head ..*/


    case 11:
      {
        fpRpt.WriteLine(StrNset("", lm) + "Support Reactions   {.. Global Co-ords ..}");
        UnderLine();
        fpRpt.WriteLine("Node" + StrNset("", 8 + lm) + StrLPad("  X  ", 12) + StrLPad("  Y  ", 12) + StrLPad("   M  ", 12));
        fpRpt.WriteLine(" [kN]" + StrNset("", 20 + lm) + StrLPad(" [kN]", 12) + StrLPad(" [kNm]", 12));
        break;
      } /*.. Supp_React_Head ..*/


    case 12:
      {
        fpRpt.WriteLine(StrNset("", lm) + "Member forces       {*.. Local Co-ords ..} ");
        UnderLine();
        fpRpt.WriteLine("Memb" + StrNset("", 8 + lm) + StrLPad("Node", 8) + StrLPad("Shear", 12) + StrLPad("Axial", 12) + StrLPad("Moment", 12));
        fpRpt.WriteLine(" [kN]" + StrNset("", 28 + lm) + StrLPad(" [kN]", 12) + StrLPad(" [kNm]", 12));
        break;
      } /*.. Prt_Member_forces_Head ..*/


    case 13:
      {
        fpRpt.WriteLine(StrNset("", lm) + "Member Maximum/Minimum End forces");
        UnderLine();
        fpRpt.Write(StrNset("", lm) + StrLPad("Maximum End forces", 30));
        //fpRpt.WriteLine("Minimum End forces",30);
        fpRpt.Write(StrNset("", lm) + StrLPad("Memb", 16) + StrLPad("Node", 8) + StrLPad("force", 12));
        fpRpt.WriteLine("Memb" + StrNset("", 10) + StrLPad("Node", 8) + StrLPad("force", 12));
        break;
      }


    case 14:
      {
        fpRpt.WriteLine(StrNset("", lm) + StrLPad("Gravity Loads"));
        UnderLine();
        fpRpt.WriteLine("Load" + StrNset("", 8 + lm) + StrLPad("Gravity", 12));
        fpRpt.WriteLine("Action" + StrNset("", 8 + lm) + StrLPad("[m/sý]", 12));
        break;
      } 


    case 15:
      {
        fpRpt.WriteLine(StrNset("", lm) + "Span Moments");
        UnderLine();
        fpRpt.WriteLine("Member" + StrNset("", 8 + lm) + StrLPad("segment", 10) + StrLPad("station", 10) + StrLPad("Moment", 10));
        fpRpt.WriteLine(StrNset("", 18 + lm) + StrLPad(" [m]", 10) + StrLPad("[kNm]", 10));
        break
      } 



    default:
      {
        count = count - 1;
        break;
      }

  } /*.. Case ..*/
  count = count + title_len + 1;
} /*.. Prt_Titles ..*/



//  <<< Prt_Page_Header >>>
//   ...   commence
//   ...   RGH   23/5/95
function Prt_Page_Header(title, title_len) {
  var str_w; // BYTE;

  WScript.Echo("Prt_Page_Header ...");


  fpRpt.WriteLine();

  HeadLine;

  UnderLine();
  str_w = 42;
//  fpRpt.Write(StrNset("", lm) + "Author : " + StrLPad(ProjectData.Author, str_w));
//  fpRpt.WriteLine("Job No.: " + StrLPad(ProjectData.ProjectID, 12));
//  fpRpt.WriteLine(StrNset("", lm) + "Job    : ", StrLPad(ProjectData.ProjectID, str_w));
//  fpRpt.Write(StrNset("", lm) + "Load   : ", StrLPad(ProjectData.LOadCase, str_w));
//  fpRpt.WriteLine("PAGE   : " + StrLPad(pageno, 12));

  UnderLine();
  pageno = pageno + 1;
  count = 9;
  firstpage = false;

  Prt_Titles(title, title_len);
} /*...Prt_Page_Header*/


//  << Chk_Output_Length >>
//  .. function based on ref#? p?
//     algorithm
//     Modified RGH :-
//     6/2/92 - implemented ..
function Chk_Output_Length(title, title_len, datacont) {
  
  WScript.Echo("Chk_Output_Length ...");
  if (count > page_len) {
    if (datacont == true) {
      fpRpt.WriteLine(StrNset(" ", lm + 65), "(Cont.)");
    }
    if (!firstpage) {
      fpRpt.WriteLine("");
    }
    Prt_Page_Header(title, title_len);
  }
  WScript.Echo("... Chk_Output_Length");
  
} /*.. Chk_Output_Length ..*/



//  << Chk_Title_Position >>
//  .. function based on ref#? p?
//     algorithm
//     Modified RGH :-
//     6/2/92 - implemented ..
function Chk_Title_Position(title, title_len) {
  
  WScript.Echo("Chk_Title_Position ...");
  if ((count + title_len + line_tol) > page_len) {

    count = count + title_len + line_tol;
    Chk_Output_Length(title, title_len, false);

  } else {
    Prt_Titles(title, title_len);
  }
} /*.. Chk_Title_Position ..*/



//  << Incr_Chk_Count >>
//  .. function based on ref#? p?
//     algorithm
//     Modified RGH :-
//     6/2/92 - implemented ..
function Incr_Chk_Count(title, title_len) {
  
  WScript.Echo("Incr_Chk_Count ...");
  count = count + 1;
  Chk_Output_Length(title, title_len, true);
} /*.. Incr_Chk_Count ..*/




//  << Prt_Parameters >>
//  .. function based on ref#? p?
//     algorithm
//     Modified RGH :-
//     6/2/92 - implemented ..
function Prt_Parameters() {
  
  WScript.Echo("Prt_Parameters ...");
  Chk_Title_Position(1, 2);
  fpRpt.WriteLine(StrNset("", lm) + "   Number of Joints........" + StrLPad(structParam.njt, 6));
  fpRpt.WriteLine(StrNset("", lm) + "   Number of Members......." + StrLPad(structParam.nmb, 6));
  fpRpt.WriteLine(StrNset("", lm) + "   Number of Supports......" + StrLPad(structParam.nrj, 6));
  fpRpt.WriteLine(StrNset("", lm) + "   Number of Materials....." + StrLPad(structParam.nmg, 6));
  fpRpt.WriteLine(StrNset("", lm) + "   Number of Sections......" + StrLPad(structParam.nsg, 6));
  fpRpt.WriteLine(StrNset("", lm) + "   Number of Joints Loads.." + StrLPad(structParam.njl, 6));
  fpRpt.WriteLine(StrNset("", lm) + "   Number of Member Loads.." + StrLPad(structParam.nml, 6));
  count = count + 10;
} /*.. Prt_Parameters ..*/




//  << Prt_Joint_Coords >>
//  .. function based on ref#? p?
//     algorithm
//     Modified RGH :-
//     6/2/92 - implemented ..
function Prt_Joint_Coords() {
  var i; // integer;

  WScript.Echo("Prt_Joint_Coords ...");
  Chk_Title_Position(2, 3);
  for (i = baseIndex; i < nod_grp.length; i++) {
    // WITH nod_grp[i] ;
    {
      Incr_Chk_Count(2, 3);
      fpRpt.WriteLine(StrLPad(i.toString(), 6 + lm) + StrLPad(nod_grp[i].x.toString(), 10) + StrLPad(nod_grp[i].y.toString(), 10));
    }
  }
} /*.. Prt_Joint_Coords ..*/




//  << Prt_Connectivity >>
//  .. function based on ref#? p?
//     algorithm
//     Modified RGH :-
//     6/2/92 - implemented ..
function Prt_Connectivity() {
  var i, txt; // integer;
  
  WScript.Echo("Prt_Connectivity ...");
  Chk_Title_Position(3, 3);
  for (i = baseIndex; i < con_grp.length; i++) {
    // WITH con_grp[i] ;
    {
      Incr_Chk_Count(3, 3);
      txt = StrLPad(i, 7 + lm) + StrLPad(con_grp[i].jj.toString(), 6) + StrLPad(con_grp[i].jk.toString(), 6)
      txt = txt + StrLPad(con_grp[i].sect.toString(), 8) + StrLPad(con_grp[i].rel_i.toString(), 6)
      txt = txt + StrLPad(con_grp[i].rel_j.toString(), 3) + StrLPad(l[i].toString(), 10)
      fpRpt.WriteLine(txt);
    }
  }
} /*.. Prt_Connectivity ..*/




//  << Prt_Supports >>
//  .. function based on ref#? p?
//     algorithm
//     Modified RGH :-
//     6/2/92 - implemented ..
function Prt_Supports() {
  var i, txt; // integer;

  WScript.Echo("Prt_Supports ...");
  Chk_Title_Position(4, 3);
  for (i = baseIndex; i < sup_grp.length; i++) {
    // WITH sup_grp[i] ;
    {
      Incr_Chk_Count(4, 3);
      txt = StrLPad(sup_grp[i].js.toString(), 8 + lm) + StrLPad(sup_grp[i].rx.toString(), 8)
      txt = txt + StrLPad(sup_grp[i].ry.toString(), 2) + StrLPad(sup_grp[i].rm.toString(), 2)
      fpRpt.WriteLine(txt);
    }
  }
} /*.. Prt_Supports ..*/





//  << Prt_Section_Props >>
//  .. function based on ref#? p?
//     algorithm
//     Modified RGH :-
//     6/2/92 - implemented ..
function Prt_Section_Props() {
  var i, txt; // integer;
  
  WScript.Echo("Prt_Section_Props ...");
  Chk_Title_Position(5, 4);
  for (i = baseIndex; i < mem_grp.length; i++) {
    // WITH mem_grp[i] ;
    {
      Incr_Chk_Count(5, 4);
      txt = StrLPad(i, 8 + lm) + StrLPad("", 3) + StrLPad(mem_grp[i].ax.toString(), 10)
      txt = txt + StrLPad("", 3) + StrLPad(mem_grp[i].iz.toString(), 10)
      txt = txt + StrLPad(mem_grp[i].mat.toString(), 10) + StrLPad(mem_grp[i].descr.toString(), 28)
      fpRpt.WriteLine(txt);
    }
  }
} /*.. Prt_Section_Props ..*/




//  << Prt_Material_Props >>
//  .. function based on ref#? p?
//     algorithm
//     Modified RGH :-
//     6/2/92 - implemented ..
function Prt_Material_Props() {
  var i, txt; // integer;


  WScript.Echo("Prt_Material_Props ...");
  Chk_Title_Position(6, 3);
  for (i = baseIndex; i < mat_grp.length; i++) {
    // WITH mat_grp[i] ;
    {
      Incr_Chk_Count(6, 3);
      txt = StrLPad(i.toString(), lm + 9), StrLPad(mat_grp[i].density.toString(), 10)
      txt = txt + StrLPad("", 3) + StrLPad(mat_grp[i].emod.toString(), 10)
      txt = txt + StrLPad("", 3, mat_grp[i].therm.toString(), 10)
      fpRpt.WriteLine(txt);
    }
  }
} /*.. Prt_Material_Props ..*/
//------------------------------------------------------------------------------








//------------------------------------------------------------------------------

//    << Prt_Sum_Quants >>
//    ..
function Prt_Sum_Quants() {
  
  WScript.Echo("Prt_Sum_Quants ...");
  Incr_Chk_Count(7, 4);
  UnderLine();
  Incr_Chk_Count(7, 4);
  fpRpt.Write(StrLPad("SUM", 8 + lm));
  fpRpt.Write(StrLPad(sum_len.toString(), 12));
  fpRpt.Write(StrLPad(sum_mass.toString(), 12));
  fpRpt.WriteLine();
  count = count + 2;
} /*.. Prt_Sum_Quants..*/



//  << Prt_Quantities >>
//  .. function based on ref#? p?
//     algorithm
//     Modified RGH :-
//     6/2/92 - implemented ..
function Prt_Quantities() {
  var sum_len, sum_mass; // double;
  var i, txt; // integer;

  WScript.Echo("Prt_Quantities ...");
  sum_len = 0;
  sum_mass = 0;
  Chk_Title_Position(7, 4);
  for (i = baseIndex; i < mem_grp.length; i++) {
    // WITH mem_grp[i] ;
    {
      Incr_Chk_Count(7, 4);

      txt = StrLPad(i.toString(), 8 + lm) + StrLPad(mem_grp[i].t_len.toString(), 12)
      txt = txt + StrLPad(mem_grp[i].t_mass.toString(), 12) + StrLPad(mem_grp[i].descr.toString())
      fpRpt.WriteLine(txt);
      sum_len = sum_len + t_len;
      sum_mass = sum_mass + t_mass;
    }
  }
  Prt_Sum_Quants;
} /*.. Prt_Quantities ..*/




//  <<<  Echo_Input  >>>
//   ...   commence
//   ...   RGH   23/5/95
function Echo_Input() {
  WScript.Echo("Echo_Input ...");
  Prt_Parameters();
  Prt_Joint_Coords();
  Prt_Connectivity();
  Prt_Supports();
  Prt_Section_Props();
  Prt_Material_Props();
  Prt_Quantities();
  WScript.Echo("... Echo_Input");
} /*...Echo_Input ..*/



//  << Prt_Gravity_Loads >>
//  .. function based on ref#? p?
//     algorithm
//     Modified RGH :-
//     6/2/92 - implemented ..
function Prt_Gravity_Loads() {
  
  WScript.Echo("Prt_Gravity_Loads ...");
  Chk_Title_Position(14, 4);
  // WITH grv_lod ;
  {
    Incr_Chk_Count(14, 4);
    fpRpt.WriteLine(StrLPad(acode, 8 + lm) + StrLPad(grv_lod.load.toString(), 12));
  }
} /*.. Prt_Gravity_Loads ..*/




//  << Prt_Member_Loads >>
//  .. function based on ref#? p?
//     algorithm
//     Modified RGH :-
//     6/2/92 - implemented ..
function Prt_Member_Loads() {
  var i, txt; // integer;
  
  WScript.Echo("Prt_Member_Loads ...");
  Chk_Title_Position(8, 3);
  for (i = baseIndex; i < mem_lod.length; i++) {
    // WITH mem_lod[i] ;

    Incr_Chk_Count(8, 3);
    txt = StrLPad(mem_no.toString(), 8 + lm) + StrLPad(mem_lod[i].lcode.toString(), 8)
    txt = txt + StrLPad(mem_lod[i].f_action.toString(), 8) + StrLPad(mem_lod[i].ld_mag1.toString(), 12)
    fpRpt.Write(" ");
    if ((start + cover) != 0) {
      fpRpt.Write(StrLPad(start.toString(), 12));
      if (cover != 0) {
        fpRpt.Write(StrLPad(cover.toString(), 12));
      }
    }
    fpRpt.WriteLine();
  }
} /*.. Prt_Member_Loads ..*/




//  << Prt_Joint_Loads >>
//  .. function based on ref#? p?
//     algorithm
//     Modified RGH :-
//     6/2/92 - implemented ..
function Prt_Joint_Loads() {
  var i, txt; // integer;


  WScript.Echo("Prt_Joint_Loads ...");
  Chk_Title_Position(9, 3);
  for (i = baseIndex; i < jnt_lod.length; i++)
  // WITH jnt_lod[i] ;
  {
    Incr_Chk_Count(9, 3);
    txt = StrLPad(jt.toString(), 8 + lm) + StrLPad(jnt_lod[i].fx.toString(), 12)
    txt = txt + StrLPad(jnt_lod[i].fy.toString(), 12) + StrLPad(jnt_lod[i].mz.toString(), 12)
    fpRpt.WriteLine();
  }
} /*.. Prt_Joint_Loads ..*/

//------------------------------------------------------------------------------





//  << Prt_Joint_Displacements >>
//  ..
function Prt_Joint_Displacements() {

  var i, txt; // integer;
  var ndx;
  var refNdx;
  var startCounter=1;

  WScript.Echo("Prt_Joint_Displacements ...");
  /*WriteXY("Joint Displacements #",1,1);*/
  Chk_Title_Position(10, 4);

  for (i = startCounter; i < structParam.njt; i++) {
    Incr_Chk_Count(10, 4);
    /*WriteXY(WordToString(i,4+lm),22,1);*/
    WScript.Echo(i);
    fpRpt.Write(StrLPad(i, 8 + lm));
    
    refNdx = 3*i;
    txt = StrLPad(dj[refNdx - 3].toString(), 10) + StrLPad(dj[refNdx - 2].toString(), 10) + StrLPad(dj[refNdx-1].toString(), 10)
    fpRpt.WriteLine(txt);
  }
  WScript.Echo("... Prt_Joint_Displacements");
} /*.. Prt_Joint_Displacements ..*/




//    << Prt_Reaction_Sum >>
//    ..
function Prt_Reaction_Sum() {
  
  WScript.Echo("Prt_Reaction_Sum ...");
  Incr_Chk_Count(11, 4);
  UnderLine();
  Incr_Chk_Count(11, 4);
  fpRpt.Write(StrLPad("SUM", 8 + lm));
  fpRpt.Write(StrLPad(sumx.toString(), 12));
  fpRpt.Write(StrLPad(sumy.toString(), 12));
  fpRpt.WriteLine(StrLPad("(All nodes)", 15));
  count = count + 2;
  WScript.Echo("... Prt_Reaction_Sum");
} /*.. Prt_Reaction_Sum ..*/





//  << Prt_Support_Reactions >>
//  .. function based on ref#? p?
//     algorithm
//     Modified RGH :-
//     31/12/95 - implemented ..
//     23/8/96  - for ( routine changed ; directly address support nodes.
function Prt_Support_Reactions() {
  var step = 3;
  var i, limit, jnt_r, kk, k, flag; // : INTEGER;

  WScript.Echo("Prt_Support_Reactions ...");
  
  sumx = 0;
  sumy = 0;
  /*WriteXY("Support Reaction # ",1,3);*/
  Chk_Title_Position(11, 4);
  
  WScript.Echo("Step:1");
  for (k = baseIndex; k < n3; k++) {
    if (rjl[k] == 1) {
      ar[k] = ar[k] - fc[Equiv_Ndx(k)];
    }
  }
  
  WScript.Echo("Step:2");
  
  for (i = baseIndex; i < sup_grp.length; i++)
  // WITH sup_grp[i] ;
  {
    
    WScript.Echo("Step:3");
    Incr_Chk_Count(11, 4);
    k = 3 * sup_grp[i].js;
    flag = 0;
    fpRpt.Write(StrLPad(sup_grp[i].js, 8 + lm));
    for (kk = k - 2; kk < k; kk++) {
      WScript.Echo("Step:4 " + kk.toString());
      if ((kk % 3) == 0) {
        WScript.Echo("Step:5");
        fpRpt.Write(StrLPad(ar[kk], 12));
        WScript.Echo("Step:6");
      } else {

        fpRpt.Write(StrLPad(ar[kk], 12));
        if (flag == 0) {
          sumx = sumx + ar[kk]
        } else {
          sumy = sumy + ar[kk];
          flag = flag + 1;
        }
        fpRpt.WriteLine();
        flag = 0;
      }
      WScript.Echo("Step:7");
      
    }
  }
  WScript.Echo("Step:10");
  Prt_Reaction_Sum();

  WScript.Echo("... Prt_Support_Reactions");

} /*.. Prt_Support_Reactions ..*/



/*
  << Prt_Member_for (ces >>
  ..
  */
function Prt_Member_forces() {
  var i, j, j1, j2, j3, k, k1, k2, k3; // INTEGER;
  var tmp; // double;

  WScript.Echo("Prt_Member_forces ...");
  /*WriteXY("Member for (ces # ",1,2);*/
  Chk_Title_Position(12, 4);
  for (i = baseIndex; i < con_grp.length; i++)
  // WITH con_grp[i] ;
  {
    /*WriteXY(WordToString(i,4),22,2);*/

    Incr_Chk_Count(12, 4);
    
    //WScript.Echo("Step:1");
    fpRpt.Write(StrLPad(i.toString(), 8 + lm));
    //WScript.Echo("Step:2");
    
    fpRpt.Write(StrLPad(con_grp[i].jj, 8));
    fpRpt.Write(StrLPad(con_grp[i].jnt_jj.shear, 12));
    fpRpt.Write(StrLPad(con_grp[i].jnt_jj.axial, 12));
    fpRpt.Write(StrLPad(con_grp[i].jnt_jj.momnt, 12));
    //WScript.Echo("Step:3");
    fpRpt.WriteLine();

    Incr_Chk_Count(12, 4);
    
    
    fpRpt.Write(StrLPad(" ", 8 + lm));
    //WScript.Echo("Step:4");

    fpRpt.Write(StrLPad(con_grp[i].jk, 8));
    fpRpt.Write(StrLPad(con_grp[i].jnt_jk.shear, 12));
    fpRpt.Write(StrLPad(con_grp[i].jnt_jk.axial, 12));
    fpRpt.Write(StrLPad(con_grp[i].jnt_jk.momnt, 12));
    fpRpt.WriteLine();

  }
  UnderLine();
  WScript.Echo("... Prt_Member_forces");
} /*.. Prt_Member_for (ces ..*/



/*
    << Get_Min_Max >>
    ..
    */
function Get_Min_Max()

{
  var i; // integer;


  WScript.Echo("Get_Min_Max ...");
  for (i = baseIndex; i < con_grp.length; i++) {
    /*WriteXY(WordToString(i,4),22,2);*/

    /*.. store } for (ces ..*/
    // WITH con_grp[i] ;
    {
      if (maxA < con_grp[i].jnt_jj.axial) {

        maxA = con_grp[i].jnt_jj.axial;
        MaxAJnt = con_grp[i].jj;
        maxAmemb = i;
      }

      if (maxQ < con_grp[i].jnt_jj.shear) {

        maxQ =con_grp[i]. jnt_jj.shear;
        MaxQJnt = con_grp[i].jj;
        maxQmemb = i;
      }

      if (maxM < con_grp[i].jnt_jj.moment) {

        maxM = con_grp[i].jnt_jj.moment;
        MaxMJnt = con_grp[i].jj;
        maxMmemb = i;
      }

      if (maxA < con_grp[i].jnt_jk.axial) {

        maxA = con_grp[i].jnt_jk.axial;
        MaxAJnt = con_grp[i].jk;
        maxAmemb = i;
      }

      if (maxQ < con_grp[i].jnt_jk.shear) {

        maxQ = con_grp[i].jnt_jk.shear;
        MaxQJnt = con_grp[i].jk;
        maxQmemb = i;
      }

      if (maxM < con_grp[i].jnt_jk.moment) {

        maxM =con_grp[i]. jnt_jk.moment;
        MaxMJnt = con_grp[i].jk;
        maxMmemb = i;
      }

      if (MinA > con_grp[i]. jnt_jj.axial) {

        MinA = con_grp[i].jnt_jj.axial;
        MinAJnt = con_grp[i].jj;
        MinAmemb = i;
      }

      if (MinQ > con_grp[i].jnt_jj.shear) {

        MinQ = con_grp[i].jnt_jj.shear;
        MinQJnt = con_grp[i].jj;
        MinQmemb = i;
      }

      if (MinM > con_grp[i].jnt_jj.moment) {

        MinM = con_grp[i].jnt_jj.moment;
        MinMJnt =con_grp[i]. jj;
        MinMmemb = i;
      }

      if (MinA > con_grp[i].jnt_jk.axial) {

        MinA = con_grp[i].jnt_jk.axial;
        MinAJnt = con_grp[i].jk;
        MinAmemb = i;
      }

      if (MinQ > con_grp[i].jnt_jk.shear) {

        MinQ = con_grp[i].jnt_jk.shear;
        MinQJnt = con_grp[i].jk;
        MinQmemb = i;
      }

      if (MinM > con_grp[i].jnt_jk.moment) {

        MinM = con_grp[i].jnt_jk.moment;
        MinMJnt = con_grp[i].jk;
        MinMmemb = i;
      }
    }
  }
} /*.. Get_Min_Max ..*/








/*
  << Prt_Max_for (ces >>
  .. function based on ref#? p?
     algorithm
     Modified RGH :-
     6/2/92 - implemented ..
  */
function Prt_Max_forces() {


  WScript.Echo("Prt_Max_forces ...");
  Get_Min_Max();

  Chk_Title_Position(13, 4);
  Incr_Chk_Count(13, 4);

  fpRpt.Write(StrLPad("Axial", 8 + lm));
  fpRpt.Write(StrLPad(maxAmemb, 8));
  fpRpt.Write(StrLPad(MaxAJnt, 8));
  fpRpt.Write(StrLPad(maxA, 12));
  fpRpt.Write(StrLPad(MinAmemb, 8));
  fpRpt.Write(StrLPad(MinAJnt, 10));
  fpRpt.Write(StrLPad(MinA, 12));
  fpRpt.WriteLine();

  Incr_Chk_Count(13, 4);
  fpRpt.Write(StrLPad("Shear", 8 + lm));
  fpRpt.Write(StrLPad(maxQmemb, 8));
  fpRpt.Write(StrLPad(MaxQJnt, 8));
  fpRpt.Write(StrLPad(maxQ, 12));
  fpRpt.Write(StrLPad(MinQmemb, 8));
  fpRpt.Write(StrLPad(MinQJnt, 10));
  fpRpt.Write(StrLPad(MinQ, 12));
  fpRpt.WriteLine();

  Incr_Chk_Count(13, 4);
  fpRpt.Write(StrLPad("Moment", 8 + lm));
  fpRpt.Write(StrLPad(maxMmemb, 8));
  fpRpt.Write(StrLPad(MaxMJnt, 8));
  fpRpt.Write(StrLPad(maxM, 12));
  fpRpt.Write(StrLPad(MinMmemb, 8));
  fpRpt.Write(StrLPad(MinMJnt, 10));
  fpRpt.Write(StrLPad(MinM, 12));
  fpRpt.WriteLine();
  UnderLine();
  
  WScript.Echo("... Prt_Max_forces");

} /*.. Prt_Max_for (ces ..*/


/*
  << Prt_Span_Moments >>
  ..
  */
function Prt_Span_Moments()

{
  var i, j; // INTEGER;
  var station, segment; // : double;    
  var txt;


  WScript.Echo("Prt_Span_Moments ...");
  count = page_len+1;
  /*WriteXY("Span Moments # ",1,2);*/
  Chk_Title_Position(15, 4);
  for (i = baseIndex; i < con_grp.length; i++) {
    segment = l[i] / vn;
    Incr_Chk_Count(15, 5);
    fpRpt.WriteLine(StrLPad(i, 8 + lm));
    /*WriteXY(WordToString(i,4),22,2);*/
    // WITH con_grp[i] ;
    for (j = 0; j < vn; j++) {
      station = j * segment;
      Incr_Chk_Count(15, 4);
      txt = StrLPad(j, 18 + lm) + StrLPad(station, 10) + StrLPad(span_mom[i, j].toString(), 10)
      fpRpt.WriteLine(txt);
    }
  }
  UnderLine();
  WScript.Echo("... Prt_Span_Moments");
} /*.. Prt_Span_Moments ..*/




//  << Output_Results >>
//  .. function based on ref#? p?
//     algorithm
//     Modified RGH :-
//     6/2/92 - implemented ..
function Output_Results() {

  WScript.Echo(sprintUnderLine());
  WScript.Echo("Output_Results ...");
  /*OpenOutFiles;*/
  firstpage = true;

  pageno = 1;
  count = page_len - 1;

  WScript.Echo("Print Loading ...");
  if (structParam.nml != 0) {
    Prt_Member_Loads();
  } else {
    WScript.Echo("No Member Loads: " + structParam.nml.toString() );
  }
  
  if (structParam.njl != 0) {
    Prt_Joint_Loads();
  }else {
    WScript.Echo("No Joint Loads: " + structParam.njl.toString() );
  }
  
  if (structParam.ngl != 0) {
    Prt_Gravity_Loads();
  }else {
    WScript.Echo("No Gravity Loads: " + structParam.ngl.toString() );
  }
  
  
  WScript.Echo("... Print Loading");
  WScript.Echo(sprintUnderLine());
  
  Prt_Joint_Displacements();
  Prt_Member_forces();
  Prt_Support_Reactions();
  Prt_Max_forces();

  Prt_Span_Moments();
  WScript.Echo("... Output_Results");
  
} /*.. Output_Results ..*/
