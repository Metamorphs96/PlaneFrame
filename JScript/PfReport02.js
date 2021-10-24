//
// Copyright (c)2014 S C Harrison
// Refer to License.txt for terms and conditions of use.
//


//-------------------------------------------------------------------------------------
//{###### Pf_Prt.PAS ######
// ... a module of Output routines for ( the Framework Program-
//     R G Harrison   --  Version 1.1  --  12/05/05  ...
//     Revision history as-
//        12/05/05 - implemented ..

//{<<< START CODE >>>>}
//===========================================================================
//    {
//    <<< ClearOutputSheet >>>
//   ...
function ClearOutputSheet(clrng) {
  WScript.Echo("ClearOutputSheet ");
  //MiWrkBk.Worksheets("Frm").Range(clrng).ClearContents
} //...ClearOutputSheet


//    <<< PrtDeltas >>>
function PrtDeltas(r, c) {
  var txt1, txt2, txt3, txt4;
  var idx1, idx2, idx3;
  
  WScript.Echo("PrtDeltas ...");
  fpRpt.WriteLine("PrtDeltas ...");
  for (global_i = baseIndex+1; global_i <= structParam.njt; global_i++) {
    txt1 = StrLPad(global_i.toString(),4);
    
    idx1 = 3 * global_i - 3;
    idx2 = 3 * global_i - 2;
    idx3 = 3 * global_i - 1;
      
    txt2 = StrLPad(-dj[idx1].toFixed(4),8);
    txt3 = StrLPad(-dj[idx2].toFixed(4),8);
    txt4 = StrLPad(-dj[idx3].toFixed(4),8);
    
    fpRpt.WriteLine(txt1 + " " + txt2 + " " + txt3 + " " + txt4);
    r = r + 1;
  } //next i
  
  fpRpt.WriteLine();
  WScript.Echo("... PrtDeltas");
} //...PrtDeltas

//   <<< PrtEndForces >>>
function PrtEndForces(r, c) {
  var txt0, txt1, txt2, txt3, txt4, txt5;
  var txt6, txt7, txt8, txt9, txt10,txt;
  var tmp;
  
  WScript.Echo("PrtEndForces ...");
  fpRpt.WriteLine("PrtEndForces ...");
  for (i = baseIndex; i < structParam.nmb; i++) {
    //With con_grp(i)
    txt0 = StrLPad(i.toString(),8);
    txt1 = StrLPad(mlen[i].toFixed(3),8);
    
    txt2 = StrLPad(con_grp[i].jj.toString(),8);
    txt3 = StrLPad(con_grp[i].jnt_jj.axial.toFixed(4),15);
    txt4 = StrLPad(con_grp[i].jnt_jj.shear.toFixed(4),15);
    txt5 = StrLPad(con_grp[i].jnt_jj.momnt.toFixed(4),15);
    
    txt6 = StrLPad(con_grp[i].jk.toString(),8);
    txt7 = StrLPad(con_grp[i].jnt_jk.axial.toFixed(4),15);
    txt8 = StrLPad(con_grp[i].jnt_jk.shear.toFixed(4),15);
    txt9 = StrLPad(con_grp[i].jnt_jk.momnt.toFixed(4),15);
    
    txt = txt0 + " " + txt1 + " " + txt2 + " " + txt3 + " " + txt4 + " " + txt5
    txt = txt + " " + txt6 + " " + txt7 + " " + txt8 + " " + txt9
    fpRpt.WriteLine(txt);
    // } With
    r = r + 1;
  } //next i
  
  fpRpt.WriteLine();
  WScript.Echo("... PrtEndForces");
} //...PrtEndForces

//    << Prt_Reaction_Sum >>
function Prt_Reaction_Sum(r, c) {
  var txt0, txt1;
  
  fpRpt.WriteLine("Prt_Reaction_Sum ...");
  txt0 = StrLPad(sumx.toFixed(4),15);
  txt1 = StrLPad(sumy.toFixed(4),15);
  fpRpt.WriteLine(txt0 + " " + txt1);
  fpRpt.WriteLine();
  
} //.. Prt_Reaction_Sum ..

//    <<< PrtReactions >>>
function PrtReactions(row1, col1) {
  var i, k, k3, c, r;
  var txt0, txt1, txt2;

  WScript.Echo("PrtReactions ...");
  fpRpt.WriteLine("PrtReactions ...");
  
  for (k = baseIndex; k<n3; k++) {
    if (rjl[k] == 1) {
      ar[k] = ar[k] - fc[Equiv_Ndx(k)];
    }
  } //next k
  sumx = 0;
  sumy = 0;

  r = row1;
  for (i = baseIndex; i<structParam.nrj; i++) {
    c = col1 + 1;
    //With sup_grp(i)
    txt0 = sup_grp[i].js;
    flag = 0;
    c = c + 1;
    k3 = 3 * sup_grp[i].js-1;
    for (k = k3 - 2; k <= k3; k++) {
      if ((k+1) % 3 == 0) {
        txt1 = StrLPad(ar[k].toFixed(4),15);	
	    fpRpt.Write(txt1);
      } else {
        txt2 = StrLPad(ar[k].toFixed(4),15);
	    fpRpt.Write(txt2);
        if (flag == 0) {
          sumx = sumx + ar[k];
        } else {
          sumy = sumy + ar[k];
        }
        flag = flag + 1;
      }
      c = c + 1;
    } //next k
    flag = 0;
    
    fpRpt.WriteLine();
    r = r + 1;
    // With
  } //next i

  Prt_Reaction_Sum(row1 - 5, col1 + 1);
  
  fpRpt.WriteLine();
  WScript.Echo("... PrtReactions");
  
} //...PrtReactions

//    << Prt_Controls >>
function Prt_Controls(r, c) {
  var txt0, txt1, txt2, txt3, txt4, txt5;
  var txt6, txt7, txt8, txt9, txt10, txt;
  
  fpRpt.WriteLine("Prt_Controls ...");
  txt1 = structParam.njt;
  txt2 = structParam.nmb;
  txt3 = structParam.nmg;
  txt4 = structParam.nsg;
  txt5 = structParam.nrj;
  txt6 = structParam.njl;
  txt7 = structParam.nml;
  txt8 = structParam.ngl;
  txt9 = structParam.nr;
  
  txt = txt1 + " " + txt2 + " " + txt3 + " " + txt4 + " " + txt5
  txt = txt + " " + txt6 + " " + txt7 + " " + txt8 + " " + txt9
  fpRpt.WriteLine(txt);
  fpRpt.WriteLine();
  
} //.. Prt_Controls ..

//    <<< Prt_Section_Details >>>
function Prt_Section_Details(r, c) {
  var txt0, txt1, txt2, txt3, txt4, txt5;
  var txt6, txt7, txt8, txt9, txt10,txt;

  WScript.Echo("Prt_Section_Details ...");
  fpRpt.WriteLine("Prt_Section_Details ...");
  for (i = baseIndex; i < structParam.nmg; i++) {
    
    WScript.Echo("Step:1");
    txt1 = StrLPad(i,8);
    txt2 = StrLPad(sec_grp[i].t_len,8);
    WScript.Echo("Step:2");
    //txt3 = StrLPad(sec_grp[i].t_mass,8);
    txt3 = "<>"
    WScript.Echo("Step:3");
    txt4 = StrLPad(sec_grp[i].Descr,8);
    
    txt = txt1 + " " + txt2 + " " + txt3 + " " + txt4
    fpRpt.WriteLine(txt);
  
    r = r + 1;
  } //next i
  
  fpRpt.WriteLine();
  WScript.Echo("... Prt_Section_Details");
} //...Prt_Section_Details

//   <<< PrtSpanMoments >>>
function PrtSpanMoments() {
  var r; // Integer
  var c; // Integer
  var seg; // Double
  var Prnge; // Range
  var tmp;

  var txt0, txt1, txt2, txt3, txt4, txt5;
  var txt6, txt7, txt8, txt9, txt10,txt;

  WScript.Echo("PrtSpanMoments ...");
  fpRpt.WriteLine("PrtSpanMoments ...");
  //  MiWrkBk.Worksheets("MSpan").Activate
  //  Set Prnge = MiWrkBk.Worksheets("MSpan").Range("A1:A1")
  r = 7;
  c = 1;

  for (i = baseIndex; i < structParam.nmb; i++) {
    seg = mlen[i] / n_segs;
    txt1 = StrLPad(i.toString(),8);
    r = r + 1;
    for (j = 0; j<=n_segs; j ++ ) {
      txt2 = StrLPad(j.toString(),8);
      
      tmp = j * seg;
      tmp = tmp.toFixed(3);
      txt3 = StrLPad(tmp.toString(),8);
      txt4 = StrLPad(mom_spn[i][j].toFixed(4),15);
      
      txt = txt1 + " " + txt2 + " " + txt3 + " " + txt4
      fpRpt.WriteLine(txt);
      
      r = r + 1;
    } //next j
    
    fpRpt.WriteLine();
    r = 7;
    c = c + 3;
  } //next i
  
  fpRpt.WriteLine();
  WScript.Echo("... PrtSpanMoments");
} //...PrtSpanMoments




//     << Output Results to Table >>
function PrintResults() {
  var Prtrnge; // Range

  WScript.Echo("PrintResults ...");
  //  MiWrkBk.Worksheets("Frm").Activate
  //  Set Prtrnge = MiWrkBk.Worksheets("Frm").Range("A1:A1")
  //--------------------------------------------------------------------
  //   ClearOutputSheet("b19:u35")
  Prt_Controls(4, 1);
  PrtDeltas(18, 1);
  PrtEndForces(18, 6);
  PrtReactions(18, 16);
  Prt_Section_Details(5, 6);
  PrtSpanMoments();
  WScript.Echo("... PrintResults");
  
} //..PrintResults
