{###### Pf_Vars.PAS ######
 ... a unit file of global variable declarations and initialisations
     for the Framework analysis program ...

    Windows 95 Delphi Version 3.0

    Version 5.0  --  21/05/02

    Written by:

    Roy Harrison,

     Revision history :-
        31/12/95 - implemented ..
        17/ 2/96 - changed to MicroSTRAN sign convention for output ..
        29/ 2/96 - member end releases added
         4/ 3/96 - main data structures made DYNAMIC
        30/ 3/96 - graphics routines standardised
}
UNIT Pf_Vars;
INTERFACE

CONST
     order  = 50;
     v_size = 64;
     (*
     i_size = 100;
     *)
     local    = 0;
     x_dir    = 1;
     y_dir    = 2;
     
     geometry = 0;
     loads    = 1;
     moments  = 2;
     shears   = 3;
     axial    = 4;
     delta    = 5;
     
     vn       = 7;
     blank    = ' '; 

TYPE
     Float_vector = ARRAY[1..v_size] OF double;
     Force_vector = ARRAY[0..vn] OF double;

     Float_matrix = ARRAY[1..order] OF Float_vector;
     Rot_matrix   = ARRAY[1..v_size,1..2] OF double;
     int_vector   = ARRAY[1..v_size] OF BYTE;
     Memb_Mom     = ARRAY[1..25] OF Force_vector;

     mat_ptr      = ^Float_matrix;
     rot_ptr      = ^Rot_matrix;
     vec_ptr      = ^Float_vector;
     ivec_ptr     = ^int_vector;
     mom_ptr      = ^Memb_Mom;
     string80     = string[80];
{
 ...Variable declarations...
}
CONST
(*
   progname    : string80 =  '  >>> FRAMEwork <<<  ';
*)
   numloads  = 80;
   max_mats  = 5;
   infinity  = 2e20;

TYPE
   material_rec  =  RECORD
                      density,    {.. density ..}
                      emod,       {.. elastic Modulus ..}
                      therm       {.. coeff of thermal expansion..}
                      : REAL;
                    END;
   force_rec  =  RECORD
                      axial,       {.. axial force ..}
                      shear,       {.. shear force ..}
                      moment       {.. end moment ..}
                      : REAL;
                    END;
   coord_rec  =  RECORD
                     x,           {.. x-coord of a joint ..}
                     y            {.. y-coord of a joint ..}
                     : REAL;
                 END;
   member_rec  =  RECORD
                    ax,      {.. member's cross sectional area ..}
                    iz,      {.. member's second moment of area ..}
                    t_len,   {.. TOTAL length of this member ..}
                    t_mass   {.. TOTAL mass of this member ..}
                    : REAL;
                    mat     {.. material of member ..}
                    : BYTE;
                    descr  : string80;
                  END;
   connect_rec  =  RECORD
                     jj,      {.. joint No. @ end "j" of a member ..}
                     jk,      {.. joint No. @ end "k" of a member ..}
                     sect,    {.. section group of member ..}
                     rel_i,   {.. end i release of member ..}
                     rel_j    {.. end j release of member ..}
                     : BYTE;
                     jnt_jj,
                     jnt_jk
                     :force_rec;
                   END;
   support_rec  =  RECORD
                     js : BYTE;
                     rx,    {.. joint X directional restraint ..}
                     ry,    {.. joint Y directional restraint ..}
                     rm     {.. joint Z rotational restraint ..}
                     : BYTE;
                   END;

   jnt_ld_rec  =  RECORD
                    jt : BYTE;
                    fx,           {.. horizontal load @ a joint ..}
                    fy,           {.. vertical   load @ a joint ..}
                    mz            {.. moment applied  @ a joint ..}
                    : REAL;
                  END;
   mem_ld_rec  =  RECORD          {.. lengths along a member ..}
                    mem_no,
                    lcode,
                    acode
                    : BYTE;
                    load,         {.. weight of a member load ..}
                    start,        {.. dist from end_1 to start/centroid of load ..}
                    cover         {.. dist that a load covers ..}
                    : REAL;
                  END;
   grv_ld_rec  =  RECORD          {.. lengths along a member ..}
                    acode
                    : BYTE;
                    load          {.. weight of a member load ..}
                    : REAL;
                  END;

   FileNameAndPath = string; {STRING[63];}

VAR
   mat_grp   : ARRAY[1..max_mats] OF material_rec;
   mem_grp   : ARRAY[1..25] OF member_rec;
   nod_grp   : ARRAY[1..25] OF coord_rec;
   con_grp   : ARRAY[1..25] OF connect_rec;
   sup_grp   : ARRAY[1..20] OF support_rec;
   jnt_lod   : ARRAY[1..numloads] OF jnt_ld_rec;
   mem_lod   : ARRAY[1..numloads] OF mem_ld_rec;
   grv_lod   : grv_ld_rec;

   i, kk,
   mag,     {.. Plot force Magnification ..}
   m,       {.. No. of members ..}
   no_jts,  {.. No. of joints ..}
   nmg,     {.. No. of material groups ..}
   nsg,     {.. No. of member section groups ..}
   nrj,     {.. No. of supported reaction joints ..}
   njl,     {.. No. of loaded joints ..}
   nml,     {.. No. of loaded members ..}
   ngl,     {.. No. of GRAVITY load cases ..}
   nr       {.. No. of restraints @ the supports ..}
   : BYTE;

   job,loadname,jobno,
   author,run_no,projno
   : string80;

   data_updated,data_loaded,
   analysed, designed                :  BOOLEAN;

   l,       {.. member length ..}
   ad,      {.. member end forces not including fixed end forces ..}
   fc,      {.. combined joint loads ..}
   ar,      {.. support reactions ..}
   dj,      {.. joint displacements @ ALL the nodes ..}
   dd       {.. joint displacements @ free nodes ..}
   : vec_ptr;

   cx, cy,  {.. member's direction cosines ..}
   c2, s2, cs : double;

   r                     {.. member rotation  matrix ..}
   : rot_ptr;
   af,                   {.. member fixed end forces ..}
   sj,                   {.. joint  stiffness matrix ..}
   s                     {.. member stiffness matrix ..}
   : mat_ptr;
   span_mom              {.. member span moments ..}
   : mom_ptr;

   crl,      {.. cumulative joint restraint list ..}
   rl        {.. restrained joint list ..}
   : ivec_ptr;

{
   inf, outf : textfile;
   inf, outf : TEXT;
}

{
===========================================================================
}
IMPLEMENTATION
BEGIN
  data_updated := FALSE;
  analysed     := FALSE;
  designed     := FALSE;
  data_loaded  := FALSE;
END.    {.. UNIT Pf_Vars..}
