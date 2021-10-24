//
// Copyright (c)2016 S C Harrison
// Refer to License.txt for terms and conditions of use.
//
using System;
using System.Collections.Generic;
using System.Text;
using System.IO;
using System.Text.RegularExpressions;

namespace w7cpframe
{
    class planeframe02
    {

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
        //int jobData; //(5); // String

        public StreamReader fpText;
        public StreamWriter fpRpt;
        public StreamWriter fpTracer;

        public clsGeomModel GModel = new clsGeomModel();

        public bool data_loaded; // Boolean

        static double sumx; // Double
        static double sumy; // Double



        //------------------------------------------------------------------------------
        //IMPLEMENTATION
        //------------------------------------------------------------------------------

        //.. enumeration constants ..
        const int ndx0 = 0;
        const int ndx1 = 0;
        const int ndx2 = 1;

        const int startIndex = 0;
        const int startZero = 0;
        const int StartCounter = 1;

        const int df1 = 0; //degree of freedom 1
        const int df2 = 1;
        const int df3 = 2;
        const int df4 = 3;
        const int df5 = 4;
        const int df6 = 5;

        //... Constant declarations ...

        const int baseIndex = 0;
        const int numloads = 80;   // Integer = 80
        const int order = 50;      // Integer = 50
        const int v_size = 50;     // Integer = 50
        const int max_grps = 25;   // Integer = 25
        const int max_mats = 10;   // Integer = 10
        const int n_segs = 10;     // Byte = 10

        //Scalars
        static double cosa; // Double               //   .. member's direction cosines ..
        static double sina; // Double               //   .. member's direction cosines ..
        static double c2; // Double                 //   .. Cos^2
        static double s2; // Double                 //   .. Sin^2
        static double cs; // Double                 //   .. Cos x Sin
        static double fi; // Double                 //   .. fixed end moment @ end "i" of a member ..
        static double fj; // Double                 //   .. fixed end moment @ end "j" of a member ..
        static double a_i; // Double                //   .. fixed end axial force @ end "i" ..
        static double a_j; // Double                //   .. fixed end axial force @ end "j" ..
        static double ri; // Double                 //   .. fixed end shear @ end "i" ..
        static double rj; // Double                 //   .. fixed end shear @ end "j" ..
        static double dii; // Double                //   .. slope public void @ end "i" ..
        static double djj; // Double                //   .. slope public void @ end "j" ..
        static double ao2; // Double

        static int ldc; // Integer               //   .. load type

        static double x1; // Double                 //   .. start position ..
        static double la; // Double                 //   .. dist from end "i" to centroid of load ..
        static double lb; // Double                 //   .. dist from end "j" to centroid of load ..
        static double udl; // Double                //   .. uniform load
        static double wm1; // Double                //   .. load magnitude 1
        static double wm2; // Double                //   .. load magnitude 2
        static double cvr; // Double                //   .. length covered by load
        static double w1; // Double
        static double ra; // Double                 //   .. reaction @ end A
        static double rb; // Double                 //   .. reaction @ end B
        static double w_nrm; // Double              //   .. total load normal to member ..
        static double w_axi; // Double              //   .. total load axial to member ..
        static double wchk; // Double               //   .. check reaction sum on span
        static double nrm_comp; // Double           //   .. load normal to member
        static double axi_comp; // Double           //   .. load axial to member
        static double poa; // Double                //   .. point of application ..
        static double stn; // Double
        static double seg; // Double


        static int hbw; // Integer               //   .. upper band width of the joint stiffness matrix ..
        static int nn;  // Integer               //   .. No. of degrees of freedom @ the joints ..
        static int n3; // Integer                //   .. No. of joints x 3 ..

        static double eaol; // Double               //   .. elements of the member stiffness matrix .. EA/L
        static double trl; // Double                //   .. true length of a member ..
        static double gam; // Double                //   .. gamma =  cover/length

        static double ci; // Double
        static double cj; // Double
        static double ccl; // Double
        static double ai; // Double
        static double aj; // Double

        static int global_i; // Byte
        static int global_j; // Integer
        static int global_k; // Integer

        //Index Variables
        static int j0; // Integer
        static int j1; // Integer
        static int j2; // Integer
        static int j3; // Integer

        //Index Variables
        static int k0; // Integer
        static int k1; // Integer
        static int k2; // Integer
        static int k3; // Integer

        static int diff; // Integer
        static int flag; // Byte

        //static int sect; // Byte
        //static int rel; // Byte


        static bool poslope; // Boolean

        static double maxM; // Double,
        static double MinM; // Double

        static int MaxMJnt; // Byte,
        static int maxMmemb; // Byte,
        static int MinMJnt; // Byte,
        static int MinMmemb; // Byte

        static double maxA; // Double,
        static double MinA; // Double

        static int MaxAJnt; // Byte,
        static int maxAmemb; // Byte,
        static int MinAJnt; // Byte,
        static int MinAmemb; // Byte

        static double maxQ; // Double
        static double MinQ; // Double

        static int MaxQJnt; // Byte,
        static int maxQmemb; // Byte
        static int MinQJnt;
        static int MinQmemb; // Byte


        //------------------
        //Array Variables
        //------------------

        //Vectors and Matrices
        //Vectors
        static double[] mlen = new double[v_size];                                    //.. member length ..
        static int[] rjl = new int[v_size];                                            //.. restrained joint list ..
        static int[] crl = new int[v_size];                                            //.. cumulative joint restraint list ..

        static double[] fc = new double[v_size];                                       //.. combined joint loads ..

        static double[] dd = new double[v_size];                                       //.. joint displacements @ free nodes ..
        static double[] dj = new double[v_size];                                       //.. joint displacements @ ALL the nodes ..
        static double[] ad = new double[v_size];                                       ///.. member end forces not including fixed end forces ..
        static double[] ar = new double[v_size];                                       //.. support reactions ..

        //Matrices
        static double[,] rot_mat = new double[v_size, 2];                              //.. member rotation  matrix ..
        static double[,] s = new double[order, v_size];                                        //.. member stiffness matrix ..
        static double[,] sj = new double[order, v_size];                                       //.. joint  stiffness matrix ..

        static double[,] af = new double[order, v_size];                                // Double      //.. member fixed end forces ..
        static double[,] mom_spn = new double[max_grps, n_segs + 1];                        //.. member span moments ..


        public void fprintVector(int[] a)
        {
            int i, n;
            n = a.Length;

            for (i = 0; i < n; i++)
            {
                fpTracer.Write("{0,15:0}", a[i]);
            }
            fpTracer.WriteLine();
        }

        public void fprintVector(double[] a)
        {
            int i, n;
            n = a.Length;

            for (i = 0; i < n; i++)
            {
                fpTracer.Write("{0,15:0.0000}", a[i]);
            }
            fpTracer.WriteLine();
        }


        public void fprintMatrix(double[,] a)
        {
            int i, j, n1, n2;
            n1 = a.GetLength(0);
            n2 = a.GetLength(1);

            for (i = 0; i < n1; i++)
            {
                fpTracer.Write("[i: {0,4:0}]", i);
                for (j = 0; j < n2; j++)
                {
                    fpTracer.Write("{0,15:0.0000}", a[i, j]);
                }
                fpTracer.WriteLine();
            }

        }





        //{###### Pf_Solve.PAS ######
        // ... a module of Bandsolver routines for ( the Framework Program-
        //     R G Harrison   --  Version 1.1  --  12/05/05  ...
        //     Revision history //-
        //        12/05/05 - implemented ..
        //{<<< START CODE >>>>}
        //===========================================================================


        public int getArrayIndex(int key)
        {
            int tmp;

            //One option unreachable as baseIndex is a constant not a variable
            switch (baseIndex)
            {
                case 0:
                    tmp = (key - 1);
                    break;

                case 1:
                    tmp = key;
                    break;

            }

            return tmp;
        }



        //  << Choleski_Decomposition >>
        //  ..  matrix decomposition by the Choleski method..
        public void Choleski_Decomposition(double[,] sj, int ndof, int hbw)
        {
            int p, q;  //Integer;
            double su = 0.0;
            double te = 0.0; // Double;

            int indx1, indx2, indx3;
            //    WrMat["Decompose IN sj ..", sj, ndof, hbw]
            //    PrintMat["Choleski_Decomposition  IN sj[] ..", sj[], dd[], ndof, hbw]


            System.Console.WriteLine("<Choleski_Decomposition ...>");
            System.Console.WriteLine("ndof, hbw {0} {1}", ndof, hbw);
            for (global_i = baseIndex; global_i < ndof; global_i++)
            {
                System.Console.WriteLine("global_i= {0}", global_i);
                p = ndof - global_i - 1;

                if (p > hbw - 1)
                {
                    p = hbw - 1;
                }

                for (global_j = baseIndex; global_j < (p + 1); global_j++)
                {
                    q = (hbw - 2) - global_j;
                    if (q > global_i - 1)
                    {
                        q = global_i - 1;
                    }

                    su = sj[global_i, global_j];

                    if (q >= 0)
                    {
                        for (global_k = baseIndex; global_k < q + 1; global_k++)
                        {
                            if (global_i > global_k)
                            {
                                //su = su - sj[global_i - global_k,global_k + 1] * sj[global_i - global_k,global_k + global_j];
                                indx1 = global_i - global_k - 1;
                                indx2 = global_k + 1;
                                indx3 = global_k + global_j + 1;
                                su = su - sj[indx1, indx2] * sj[indx1, indx3];
                            } // End If [
                        } // next k
                    } // End If [

                    if (global_j != 0)
                    {
                        sj[global_i, global_j] = su * te;
                    }
                    else
                    {
                        if (su <= 0)
                        {
                            System.Console.WriteLine("matrix -ve TERM Terminated ???");
                            //End

                        }
                        else
                        {
                            // BEGIN
                            te = 1 / Math.Sqrt(su);
                            sj[global_i, global_j] = te;
                        } // End If [
                    } // End If [
                } // next j

                System.Console.WriteLine("SJ[]: {0}", global_i);
                fpTracer.WriteLine("SJ[]: " + global_i.ToString());
                fprintMatrix(sj);


            } // next i

            //   PrintMat["Choleski_Decomposition  OUT sj[] ..", sj[], dd[], ndof, hbw]

        } //.. Choleski_Decomposition ..


        //  << Solve_Displacements >>
        //  .. perform forward and backward substitution ; i<= solve the system ..
        public void Solve_Displacements()
        {
            double su;
            int i, j;
            int idx1, idx2;

            System.Console.WriteLine();
            System.Console.WriteLine("<Solve_Displacements ...>");
            for (i = baseIndex; i < nn; i++)
            {
                j = i + 1 - hbw;
                if (j < 0)
                {
                    j = 0;
                }
                su = fc[i];
                if (j - i + 1 <= 0)
                {
                    for (global_k = j; global_k < i; global_k++)
                    {
                        if (i - global_k + 1 > 0)
                        {
                            idx1 = i - global_k;
                            su = su - sj[global_k, idx1] * dd[global_k];
                        } // End If [
                    } // next k
                } // End If [
                dd[i] = su * sj[i, df1];
            } // next i

            for (i = nn - 1; i >= baseIndex; i--)
            {
                j = i + hbw - 1;
                if (j > nn - 1)
                {
                    j = nn - 1;
                }

                su = dd[i];
                if (i + 1 <= j)
                {
                    for (global_k = i + 1; global_k <= j; global_k++)
                    {
                        if (global_k + 1 > i)
                        {
                            idx2 = global_k - i;
                            su = su - sj[i, idx2] * dd[global_k];
                        } // End If [
                    } // next k
                } // End If [

                dd[i] = su * sj[i, df1];
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
        public void Fill_Restrained_Joints_Vector()
        {

            System.Console.WriteLine("structParam.njt : {0}", GModel.structParam.njt);
            System.Console.WriteLine("structParam.nr : {0}", GModel.structParam.nr);
            n3 = 3 * GModel.structParam.njt;                                          //From Number of Joints
            nn = n3 - GModel.structParam.nr;                                          //From Number of Restraints


            //System.Console.WriteLine("<Fill_Restrained_Joints_Vector ...>");
            for (global_i = baseIndex; global_i < GModel.structParam.nrj; global_i++)
            {
                //With sup_grp[global_i]
                j3 = (3 * GModel.sup_grp[global_i].js) - 1;
                rjl[j3 - 2] = GModel.sup_grp[global_i].rx;
                rjl[j3 - 1] = GModel.sup_grp[global_i].ry;
                rjl[j3] = GModel.sup_grp[global_i].rm;
                //System.Console.WriteLine( j3.ToString() + ": rjl.. " +  rjl[j3 - 2] + "," + rjl[j3 - 1] + "," + rjl[j3]);
                // EndWith
            } // next i


            crl[ndx1] = rjl[ndx1];
            //System.Console.WriteLine( ndx1.ToString() + ": crl.. ", crl[ndx1]);
            for (global_i = ndx1 + 1; global_i < n3; global_i++)
            {
                crl[global_i] = crl[global_i - 1] + rjl[global_i];
                //System.Console.WriteLine( global_i.ToString() + ": crl.. ", crl[global_i]);
            } // next i

            //System.Console.WriteLine("Fill_Restrained_Joints_Vector n3, nn, nr .. ", n3, nn, structParam.nr);

        } //.. Fill_Restrained_Joints_Vector ..


        //-----------------------------------------------------------------------------
        //  << Check_J >>
        public bool End_J() // Boolean
        {
            bool tmp;

            //System.Console.WriteLine("End_J ...");
            tmp = false;
            global_j = j1;
            if (rjl[global_j] == 1)
            {
                global_j = j2;
                if (rjl[global_j] == 1)
                {
                    global_j = j3;
                    if (rjl[global_j] == 1)
                    {
                        diff = Translate_Ndx(k3) - Translate_Ndx(k1) + 1;
                        tmp = true;
                    } // End If [
                } // End If [
            } // End If [

            return tmp;

        } //End public void  //.. End_J ..


        //  << End_K >>
        public bool End_K() // Boolean
        {
            bool tmp;

            //System.Console.WriteLine("End_K ...");
            tmp = false;
            global_k = k3;
            if (rjl[global_k] == 1)
            {
                global_k = k2;
                if (rjl[global_k] == 1)
                {
                    global_k = k1;
                    if (rjl[global_k] == 1)
                    {
                        diff = Translate_Ndx(j3) - Translate_Ndx(j1) + 1;
                        tmp = true;
                    } // End If [
                } // End If [
            } // End If [

            return tmp;

        } //End public void  //.. End_K ..


        //  << Calc_Bandwidth >>
        public void Calc_Bandwidth()
        {

            System.Console.WriteLine("<Calc_Bandwidth ...>");
            hbw = 0;
            diff = 0;
            for (global_i = baseIndex; global_i < GModel.structParam.nmb; global_i++)
            {
                //With con_grp[global_i]
                j3 = (3 * GModel.con_grp[global_i].jj) - 1;
                j2 = j3 - 1;
                j1 = j2 - 1;

                k3 = (3 * GModel.con_grp[global_i].jk) - 1;
                k2 = k3 - 1;
                k1 = k2 - 1;

                if (!End_J())
                {
                    //System.Console.WriteLine("BandWidth: Step:1");
                    if (!End_K())
                    {
                        //System.Console.WriteLine("BandWidth: Step:2");
                        diff = Translate_Ndx(global_k) - Translate_Ndx(global_j) + 1;
                        //System.Console.WriteLine("BandWidth: Step:3 : " + diff.ToString());
                    } // End If [
                } // End If [

                if (diff > hbw)
                {
                    //System.Console.WriteLine("BandWidth: Step:4");
                    hbw = diff;
                    //System.Console.WriteLine("BandWidth: Step:5 : " + hbw.ToString());
                } // End If [

                // EndWith
            } // next i

            //System.Console.WriteLine("Calc_Bandwidth hbw, nn .. ", hbw, nn);

        } //.. Calc_Bandwidth ..
        //-----------------------------------------------------------------------------


        //  << Get_Stiff_Elements >>
        // Calculate the Stiffness of Structural Element
        public void Get_Stiff_Elements(int i) // Byte)
        {
            int flag; // Byte
            int msect; // Byte
            int mnum; // Byte
            double eiol; // Double EI/L


            System.Console.WriteLine("Get_Stiff_Elements ...");
            //With con_grp[i]
            msect = getArrayIndex(GModel.con_grp[i].sect);                            //Section ID/key converted to array index
            mnum = getArrayIndex(GModel.sec_grp[msect].mat);                          //Material ID/key converted to array index

            flag = GModel.con_grp[i].rel_i + GModel.con_grp[i].rel_j;                        //Sum releases each end of member
            eiol = GModel.mat_grp[mnum].emod * GModel.sec_grp[msect].iz / mlen[i];           //Calculate EI/L

            // System.Console.WriteLine("eiol: " + eiol.ToString());
            // System.Console.WriteLine("mlen[i]: " + mlen[i].ToString());


            //        .. initialise temp variables ..
            ai = 0;
            aj = ai;
            ao2 = ai / 2;

            switch (flag)
            {
                case 0:
                    ai = 4 * eiol;
                    aj = ai;
                    ao2 = ai / 2;
                    break;

                case 1:
                    if (GModel.con_grp[i].rel_i == 0)
                    {
                        ai = 3 * eiol;
                    }
                    else
                    {
                        aj = 3 * eiol;
                    } // End If
                    break;

            } // End Select

            ci = (ai + ao2) / mlen[i];
            cj = (aj + ao2) / mlen[i];
            ccl = (ci + cj) / mlen[i];
            eaol = GModel.mat_grp[mnum].emod * GModel.sec_grp[msect].ax / mlen[i];

            // EndWith

            cosa = rot_mat[i, ndx1];
            sina = rot_mat[i, ndx2];
        } //.. Get_Stiff_Elements ..


        //  << Assemble_Stiff_Mat >>
        // Assemble
        public void Assemble_Stiff_Mat(int i) // Byte
        {

            System.Console.WriteLine("Assemble_Stiff_Mat ...");
            Get_Stiff_Elements(i);

            System.Console.WriteLine("eaol: " + eaol.ToString());
            System.Console.WriteLine("cosa: " + cosa.ToString());
            System.Console.WriteLine("sina: " + sina.ToString());
            System.Console.WriteLine("ccl: " + ccl.ToString());
            System.Console.WriteLine("ci: " + ci.ToString());
            System.Console.WriteLine("cj: " + cj.ToString());
            System.Console.WriteLine("ai: " + ai.ToString());
            System.Console.WriteLine("ao2: " + ao2.ToString());
            System.Console.WriteLine("aj: " + aj.ToString());

            s[df1, df1] = eaol * cosa;
            s[df1, df2] = eaol * sina;
            s[df1, df3] = 0;
            s[df1, df4] = -s[df1, df1];
            s[df1, df5] = -s[df1, df2];
            s[df1, df6] = 0;

            s[df2, df1] = -ccl * sina;
            s[df2, df2] = ccl * cosa;
            s[df2, df3] = ci;
            s[df2, df4] = -s[df2, df1];
            s[df2, df5] = -s[df2, df2];
            s[df2, df6] = cj;

            s[df3, df1] = -ci * sina;
            s[df3, df2] = ci * cosa;
            s[df3, df3] = ai;
            s[df3, df4] = -s[df3, df1];
            s[df3, df5] = -s[df3, df2];
            s[df3, df6] = ao2;

            s[df4, df1] = s[df1, df4];
            s[df4, df2] = s[df1, df5];
            s[df4, df3] = 0;
            s[df4, df4] = s[df1, df1];
            s[df4, df5] = s[df1, df2];
            s[df4, df6] = 0;

            s[df5, df1] = s[df2, df4];
            s[df5, df2] = s[df2, df5];
            s[df5, df3] = -ci;
            s[df5, df4] = s[df2, df1];
            s[df5, df5] = s[df2, df2];
            s[df5, df6] = -cj;

            s[df6, df1] = -cj * sina;
            s[df6, df2] = cj * cosa;
            s[df6, df3] = ao2;
            s[df6, df4] = -s[df6, df1];
            s[df6, df5] = -s[df6, df2];
            s[df6, df6] = aj;

            //  //   PrintMat("Assemble_Stiff_Mat   s () ..", s, dd(), 6, 6)
        } //.. Assemble_Stiff_Mat ..


        //  << Assemble_Global_Stiff_Matrix >>
        //Assemble Member Stiffness Matrix
        public void Assemble_Global_Stiff_Matrix(int i) // Byte)
        {

            System.Console.WriteLine("<Assemble_Global_Stiff_Matrix ...>");

            Get_Stiff_Elements(i);

            c2 = cosa * cosa;
            s2 = sina * sina;
            cs = cosa * sina;

            // System.Console.WriteLine("eaol :" + eaol.ToString());
            // System.Console.WriteLine("cosa :" + cosa.ToString());
            // System.Console.WriteLine("sina :" + sina.ToString());

            // System.Console.WriteLine("c2 :" + c2.ToString());
            // System.Console.WriteLine("s2 :" + s2.ToString());
            // System.Console.WriteLine("cs :" + cs.ToString());
            // System.Console.WriteLine("ccl :" + ccl.ToString());
            // System.Console.WriteLine("ci :" + ci.ToString());
            // System.Console.WriteLine("cj :" + cj.ToString());
            // System.Console.WriteLine("ai :" + ai.ToString());
            // System.Console.WriteLine("ao2 :" + ao2.ToString());
            // System.Console.WriteLine("aj :" + aj.ToString());
            // System.Console.WriteLine("-----------------------");

            s[df1, df1] = eaol * c2 + ccl * s2;
            s[df1, df2] = eaol * cs - ccl * cs;
            s[df1, df3] = -ci * sina;
            s[df1, df4] = -s[df1, df1];
            s[df1, df5] = -s[df1, df2];
            s[df1, df6] = -cj * sina;

            s[df2, df2] = eaol * s2 + ccl * c2;
            s[df2, df3] = ci * cosa;
            s[df2, df4] = s[df1, df5];
            s[df2, df5] = -s[df2, df2];
            s[df2, df6] = cj * cosa;

            s[df3, df3] = ai;
            s[df3, df4] = -s[df1, df3];
            s[df3, df5] = -s[df2, df3];
            s[df3, df6] = ao2;

            s[df4, df4] = -s[df1, df4];
            s[df4, df5] = -s[df1, df5];
            s[df4, df6] = -s[df1, df6];

            s[df5, df5] = s[df2, df2];
            s[df5, df6] = -s[df2, df6];

            s[df6, df6] = aj;

            System.Console.WriteLine("<... Assemble_Global_Stiff_Matrix >");

            //  //   PrintMat("Assemble_Global_Stiff_Matrix   s () ..", s, dd(), 6, 6)
        } //.. Assemble_Global_Stiff_Matrix ..



        //-----------------------------------------------------------------------------

        //  << Load_Sj >>
        public void Load_Sj(int j, int kk, double stiffval)
        {

            System.Console.WriteLine(">> Load_Sj ... {0} {1} {2}", j, kk, stiffval);
            global_k = Translate_Ndx(kk) - j;

            System.Console.WriteLine("IN:sj[,]: {0} {1} {2}", j, global_k, sj[j, global_k]);
            sj[j, global_k] = sj[j, global_k] + stiffval;
            System.Console.WriteLine("OUT:sj[,]: {0} {1} {2}", j, global_k, sj[j, global_k]);
            System.Console.WriteLine();

        } //.. Load_Sj ..


        //  << Process_DOF_J1 >>
        public void Process_DOF_J1()
        {

            System.Console.WriteLine("Process_DOF_J1 ... {0}", j1);

            //Process J1
            global_j = Translate_Ndx(j1);
            sj[global_j, df1] = sj[global_j, df1] + s[df1, df1];
            System.Console.WriteLine("OUT:sj[,]: {0} {1} {2}", global_j, df1, sj[global_j, df1]);


            //Cascade Influence of J1 down through J2,J3,K1,K2,K3
            if (rjl[j2] == 0)
            {
                sj[global_j, df2] = sj[global_j, df2] + s[df1, df2];
                System.Console.WriteLine("OUT:sj[,]: {0} {1} {2} ", global_j, df2, sj[global_j, df2]);
            }

            if (rjl[j3] == 0)
            {
                Load_Sj(global_j, j3, s[df1, df3]);
            }
            if (rjl[k1] == 0)
            {
                Load_Sj(global_j, k1, s[df1, df4]);
            }
            if (rjl[k2] == 0)
            {
                Load_Sj(global_j, k2, s[df1, df5]);
            }
            if (rjl[k3] == 0)
            {
                Load_Sj(global_j, k3, s[df1, df6]);
            }
        } //.. Process_DOF_J1 ..


        //  << Process_DOF_J2 >>
        public void Process_DOF_J2()
        {

            System.Console.WriteLine("Process_DOF_J2 ... {0}", j2);

            // Process J2 
            global_j = Translate_Ndx(j2);
            sj[global_j, df1] = sj[global_j, df1] + s[df2, df2];
            System.Console.WriteLine("OUT:sj[,]: {0} {1} {2}", global_j, df1, sj[global_j, df1]);

            //Cascade influence of J2 through J3, K1, K2, K3 
            if (rjl[j3] == 0)
            {
                sj[global_j, df2] = sj[global_j, df2] + s[df2, df3];
                System.Console.WriteLine("OUT:sj[,]: {0} {1} {2} ", global_j, df2, sj[global_j, df2]);
            }

            if (rjl[k1] == 0)
            {
                Load_Sj(global_j, k1, s[df2, df4]);
            }
            if (rjl[k2] == 0)
            {
                Load_Sj(global_j, k2, s[df2, df5]);
            }
            if (rjl[k3] == 0)
            {
                Load_Sj(global_j, k3, s[df2, df6]);
            }
        } //.. Process_DOF_J2 ..


        //  << Process_DOF_J3 >>
        public void Process_DOF_J3()
        {

            System.Console.WriteLine("Process_DOF_J3 ... {0}", j3);

            //Process J3 
            global_j = Translate_Ndx(j3);
            sj[global_j, df1] = sj[global_j, df1] + s[df3, df3];
            System.Console.WriteLine("OUT:sj[,]: {0} {1} {2}", global_j, df1, sj[global_j, df1]);


            //Cascade influence J3 through K1, K2, K3 
            if (rjl[k1] == 0)
            {
                Load_Sj(global_j, k1, s[df3, df4]);
            }
            if (rjl[k2] == 0)
            {
                Load_Sj(global_j, k2, s[df3, df5]);
            }
            if (rjl[k3] == 0)
            {
                Load_Sj(global_j, k3, s[df3, df6]);
            }
        } //.. Process_DOF_J3 ..


        //  << Process_DOF_K1 >>
        public void Process_DOF_K1()
        {

            System.Console.WriteLine("Process_DOF_K1 ... {0}", k1);

            //Process K1
            global_j = Translate_Ndx(k1);
            sj[global_j, df1] = sj[global_j, df1] + s[df4, df4];
            System.Console.WriteLine("OUT:sj[,]: {0} {1} {2}", global_j, df1, sj[global_j, df1]);


            //Cascade influence K1 through K2, K3 
            if (rjl[k2] == 0)
            {

                System.Console.WriteLine("IN:sj[,]: {0} {1} {2} ", global_j, df2, sj[global_j, df2]);
                System.Console.WriteLine("IN:s[,]: {0} {1} {2} ", df4, df5, s[df4, df5]);

                sj[global_j, df2] = sj[global_j, df2] + s[df4, df5];

                System.Console.WriteLine("OUT:sj[,]: {0} {1} {2}", global_j, df2, sj[global_j, df2]);
            }

            if (rjl[k3] == 0)
            {
                Load_Sj(global_j, k3, s[df4, df6]);
            }
        } //.. Process_DOF_K1 ..


        //  << Process_DOF_K2 >>
        public void Process_DOF_K2()
        {

            System.Console.WriteLine("Process_DOF_K2 ... {0}", k2);

            //Process K2
            global_j = Translate_Ndx(k2);
            sj[global_j, df1] = sj[global_j, df1] + s[df5, df5];

            System.Console.WriteLine("OUT:sj[,]: {0} {1} {2} ", global_j, df1, sj[global_j, df1]);

            //Cascade influence K2 through K3
            if (rjl[k3] == 0)
            {

                System.Console.WriteLine("IN:sj[,]: {0} {1} {2} ", global_j, df2, sj[global_j, df2]);
                System.Console.WriteLine("IN:s[,]: {0} {1} {2} ", df5, df6, s[df5, df6]);

                sj[global_j, df2] = sj[global_j, df2] + s[df5, df6];

                System.Console.WriteLine("OUT:sj[,]: {0} {1} {2} ", global_j, df2, sj[global_j, df2]);
            }
        } //.. Process_DOF_K2 ..


        //  << Process_DOF_K3 >>
        public void Process_DOF_K3()
        {
            System.Console.WriteLine("Process_DOF_K3 ... {0}", k3);
            global_j = Translate_Ndx(k3);

            //Process K3
            System.Console.WriteLine("IN:sj[,]: {0} {1} {2} ", global_j, df1, sj[global_j, df1]);
            System.Console.WriteLine("IN:s[,]: {0} {1} {2} ", df6, df6, s[df6, df6]);

            sj[global_j, df1] = sj[global_j, df1] + s[df6, df6];

            System.Console.WriteLine("OUT:sj[,]: {0} {1} {2} ", global_j, df1, sj[global_j, df1]);
            System.Console.WriteLine();


        } //.. Process_DOF_K3 ..


        //  << Assemble_Struct_Stiff_Matrix >>
        public void Assemble_Struct_Stiff_Matrix(int i) // Byte)
        {
            //        .. initialise temp variables ..


            System.Console.WriteLine("<Assemble_Struct_Stiff_Matrix ...> {0}", i);
            j3 = (3 * GModel.con_grp[i].jj) - 1;
            j2 = j3 - 1;
            j1 = j2 - 1;

            k3 = (3 * GModel.con_grp[i].jk) - 1;
            k2 = k3 - 1;
            k1 = k2 - 1;

            System.Console.WriteLine("J: {0} {1} {2}", j3.ToString(), j2.ToString(), j1.ToString());
            System.Console.WriteLine("K: {0} {1} {2}", k3.ToString(), k2.ToString(), k1.ToString());

            //Process End A

            if (rjl[j3] == 0)
            {
                Process_DOF_J3();
            } //.. do j3 ..

            if (rjl[j2] == 0)
            {
                Process_DOF_J2();
            } //.. do j2 ..

            if (rjl[j1] == 0)
            {
                Process_DOF_J1();
            } //.. do j1 ..

            //Process End B

            if (rjl[k3] == 0)
            {
                Process_DOF_K3();
            } //.. do k3 ..

            if (rjl[k2] == 0)
            {
                Process_DOF_K2();
            } //.. do k2 ..

            if (rjl[k1] == 0)
            {
                Process_DOF_K1();
            } //.. do k1 ..

            System.Console.WriteLine("<... Assemble_Struct_Stiff_Matrix > {0}", i);


        } //.. Assemble_Struct_Stiff_Matrix ..

        //-----------------------------------------------------------------------------


        //  << Calc_Member_Forces >>
        public void Calc_Member_Forces()
        {
            for (global_i = baseIndex; global_i < GModel.structParam.nmb; global_i++)
            {
                //With con_grp[global_i]

                System.Console.WriteLine("<Calc_Member_Forces ...> {0}", global_i);
                Assemble_Stiff_Mat(global_i);

                //        .. initialise temporary end restraint indices ..
                j3 = 3 * GModel.con_grp[global_i].jj - 1;
                j2 = j3 - 1;
                j1 = j2 - 1;

                k3 = 3 * GModel.con_grp[global_i].jk - 1;
                k2 = k3 - 1;
                k1 = k2 - 1;

                for (global_j = baseIndex; global_j <= df6; global_j++)
                {
                    ad[global_j] = s[global_j, df1] * dj[j1] + s[global_j, df2] * dj[j2] + s[global_j, df3] * dj[j3];
                    ad[global_j] = ad[global_j] + s[global_j, df4] * dj[k1] + s[global_j, df5] * dj[k2] + s[global_j, df6] * dj[k3];
                } // next j

                //.. Store End forces ..
                System.Console.WriteLine(global_i.ToString());
                GModel.con_grp[global_i].jnt_jj.axial = -(af[global_i, df1] + ad[df1]);
                GModel.con_grp[global_i].jnt_jj.shear = -(af[global_i, df2] + ad[df2]);
                GModel.con_grp[global_i].jnt_jj.momnt = -(af[global_i, df3] + ad[df3]);

                GModel.con_grp[global_i].jnt_jk.axial = af[global_i, df4] + ad[df4];
                GModel.con_grp[global_i].jnt_jk.shear = af[global_i, df5] + ad[df5];
                GModel.con_grp[global_i].jnt_jk.momnt = af[global_i, df6] + ad[df6];

                //.. Member Joint j End forces
                if (rjl[j1] != 0)
                {
                    ar[j1] = ar[j1] + ad[df1] * cosa - ad[df2] * sina;
                } //.. Fx
                if (rjl[j2] != 0)
                {
                    ar[j2] = ar[j2] + ad[df1] * sina + ad[df2] * cosa;
                } //.. Fy
                if (rjl[j3] != 0)
                {
                    ar[j3] = ar[j3] + ad[df3];
                } //.. Mz

                //.. Member Joint k End forces
                if (rjl[k1] != 0)
                {
                    ar[k1] = ar[k1] + ad[df4] * cosa - ad[df5] * sina;
                } //.. Fx
                if (rjl[k2] != 0)
                {
                    ar[k2] = ar[k2] + ad[df4] * sina + ad[df5] * cosa;
                } //.. Fy
                if (rjl[k3] != 0)
                {
                    ar[k3] = ar[k3] + ad[df6];
                } //.. Mz


                // EndWith
            } // next i
        } //.. Calc_Member_Forces ..


        //  << Calc_Joint_Displacements >>
        public void Calc_Joint_Displacements()
        {

            System.Console.WriteLine("<Calc_Joint_Displacements ...>");
            for (global_i = baseIndex; global_i < n3; global_i++)
            {
                if (rjl[global_i] == 0)
                {
                    dj[global_i] = dd[Translate_Ndx(global_i)];
                }
            } // next i
        } //.. Calc_Joint_Displacements ..


        //  << Get_Span_Moments >>
        public void Get_Span_Moments()
        {
            double seg, stn; // Double
            double rx; // Double
            double mx; // Double
            int i, j; // Byte

            System.Console.WriteLine("<Get_Span_Moments ...>");
            //.. Get_Span_Moments ..
            for (i = baseIndex; i < GModel.structParam.nmb; i++)
            {
                seg = mlen[i] / n_segs;
                if (poslope)
                {
                    rx = GModel.con_grp[i].jnt_jj.shear;
                    mx = GModel.con_grp[i].jnt_jj.momnt;
                }
                else
                {
                    rx = GModel.con_grp[i].jnt_jk.shear;
                    mx = GModel.con_grp[i].jnt_jk.momnt;
                } // End If [

                //With con_grp[i]
                for (j = startZero; j <= n_segs; j++)
                {
                    stn = j * seg;
                    //System.Console.WriteLine(i,j,stn, mem_lod[i].mem_no);
                    //With mem_lod[i]

                    // if ((mem_lod[i].lcode == 2) && (stn >= mem_lod[i].start) && (stn - mem_lod[i].start < seg)) {
                    // stn = mem_lod[i].start;
                    // } // End If [

                    if (poslope)
                    {
                        mom_spn[i, j] = mom_spn[i, j] + rx * stn - mx;
                    }
                    else
                    {
                        mom_spn[i, j] = mom_spn[i, j] + rx * (stn - mlen[i]) - mx;
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
        public bool In_Cover(double x1, double x2, double mlen) // Boolean
        {
            System.Console.WriteLine("In_Cover ...");
            System.Console.WriteLine("{0} {1} {2}", x1, x2, mlen);
            if ((x2 == mlen) || (x2 > mlen))
            {
                return true;
            }
            else
            {
                return ((stn >= x1) && (stn <= x2));
            } // End If [
        } //End public void //...In_Cover...


        //  << Calc_Moments >>
        //  .. RGH   12/4/92
        //  .. calc moments ..
        public void Calc_Moments(int mn, double mlen, double wtot, double x1, double la, double cv, int wty, double lslope)
        {
            double x; // Double
            double x2; // Double
            double Lx; // Double
            int idx1; // Integer


            System.Console.WriteLine("Calc_Moments ... {0}", mn);

            idx1 = mn - 1;
            x2 = x1 + cv;

            seg = mlen / n_segs;

            if (cv != 0)
            {
                w1 = wtot / cv;
            }

            for (global_j = startZero; global_j <= n_segs; global_j++)
            {
                stn = global_j * seg;

                if (poslope)
                {
                    x = stn - x1; //.. dist ; i<= sect from stn X-X..
                    Lx = stn - la;
                }
                else
                {
                    x = x2 - stn;
                    Lx = la - stn;
                } // End If [

                if (In_Cover(x1, x2, mlen))
                {
                    switch (wty) //.. calc moments if ( inside load cover..
                    {
                        case clsGeomModel.udl_ld:
                            //   Uniform Load
                            mom_spn[idx1, global_j] = mom_spn[idx1, global_j] - w1 * x * x / 2;
                            break;

                        case clsGeomModel.tri_ld:
                            //   Triangular Loads
                            mom_spn[idx1, global_j] = mom_spn[idx1, global_j] - (w1 * x * x / cv) * x / 3;
                            break;

                    } // End Select

                }
                else
                {
                    if (x <= 0)
                    {
                        Lx = 0;
                    } // End If [

                    mom_spn[idx1, global_j] = mom_spn[idx1, global_j] - wtot * Lx;

                } // End If [

            } // next j
        } //.. Calc_Moments ..

        //    << Combine_Joint_Loads >>
        public void Combine_Joint_Loads(int kMember) // Byte)
        {
            int k;

            k = kMember - 1;

            System.Console.WriteLine("Combine_Joint_Loads ... {0}", kMember);
            cosa = rot_mat[k, ndx1];
            sina = rot_mat[k, ndx2];
            System.Console.WriteLine("cosa: {0}", cosa);
            System.Console.WriteLine("sina: {0}", sina);


            //   ... Process end A
            Get_Joint_Indices(GModel.con_grp[k].jj);
            System.Console.WriteLine("fc[]: {0} {1} {2}", fc[j1], fc[j2], fc[j3]);
            fc[j1] = fc[j1] - a_i * cosa + ri * sina; //.. Fx
            fc[j2] = fc[j2] - a_i * sina - ri * cosa; //.. Fy
            fc[j3] = fc[j3] - fi; //.. Mz
            System.Console.WriteLine("fc[]: {0} {1} {2} ", fc[j1], fc[j2], fc[j3]);

            //   ... Process end B
            Get_Joint_Indices(GModel.con_grp[k].jk);
            System.Console.WriteLine("fc[]: {0} {1} {2} ", fc[j1], fc[j2], fc[j3]);
            fc[j1] = fc[j1] - a_j * cosa + rj * sina; //.. Fx
            fc[j2] = fc[j2] - a_j * sina - rj * cosa; //.. Fy
            fc[j3] = fc[j3] - fj; //.. Mz
            System.Console.WriteLine("fc[]: {0} {1} {2} ", fc[j1], fc[j2], fc[j3]);

        } //.. Combine_Joint_Loads ..


        //  << Calc_FE_Forces >>
        public void Calc_FE_Forces(int kMember, double la, double lb)
        {
            int k;

            k = kMember - 1;
            System.Console.WriteLine("Calc_FE_Forces ... {0}", k);
            //System.Console.WriteLine(k);

            System.Console.WriteLine("trl: {0}", trl);
            System.Console.WriteLine("djj: {0}", djj);
            System.Console.WriteLine("dii: {0}", dii);

            //.. both ends fixed
            fi = (2 * djj - 4 * dii) / trl;
            fj = (4 * djj - 2 * dii) / trl;

            //With con_grp[k]
            flag = GModel.con_grp[k].rel_i + GModel.con_grp[k].rel_j;
            System.Console.WriteLine("Flag: {0}", flag);

            if (flag == 2)
            { //.. both ends pinned
                fi = 0;
                fj = 0;
            } // End If [

            if (flag == 1)
            { //.. propped cantilever
                if ((GModel.con_grp[k].rel_i == 0))
                { //.. end i pinned
                    fi = fi - fj / 2;
                    fj = 0;
                }
                else
                { //.. end j pinned
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
        public void Accumulate_FE_Actions(int kMemberNum) // Byte)
        {
            int k;
            k = kMemberNum - 1;

            System.Console.WriteLine("Accumulate_FE_Actions ... {0}", kMemberNum);
            af[k, df1] = af[k, df1] + a_i;
            af[k, df2] = af[k, df2] + ri;
            af[k, df3] = af[k, df3] + fi;
            af[k, df4] = af[k, df4] + a_j;
            af[k, df5] = af[k, df5] + rj;
            af[k, df6] = af[k, df6] + fj;
        } //.. Accumulate_FE_Actions ..


        //<< Process_FE_Actions >>
        public void Process_FE_Actions(int kMemberNum, double la, double lb)
        {
            System.Console.WriteLine("Process_FE_Actions ... {0}", kMemberNum);
            Accumulate_FE_Actions(kMemberNum);
            Combine_Joint_Loads(kMemberNum);
        } //.. Process_FE_Actions ..


        //    << Do_Global_Load >>
        public void Do_Global_Load(int mem, int acd, double w0, double start)
        {
            System.Console.WriteLine("Do_Global_Load ...");
            switch (acd)
            {
                case clsGeomModel.global_x:
                    // .. global X components
                    nrm_comp = w0 * sina;
                    axi_comp = w0 * cosa;
                    break;
                case clsGeomModel.global_y:
                    // .. global Y components
                    nrm_comp = w0 * cosa;
                    axi_comp = w0 * sina;
                    break;
            } // End Select

        } //.. Do_Global_Load ..


        //<< Do_Axial_Load >>
        //.. Load type = "v" => #3
        public void Do_Axial_Load(int mno, double wu, double x1)
        {
            System.Console.WriteLine("Do_Axial_Load ...");
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
        public void Do_Self_Weight(int mem) // Byte)
        {
            int msect; // Byte,
            int mat; // Byte
            int idxMem, idxMsect, idxMat;

            System.Console.WriteLine("Do_Self_Weight ...");

            //Convert Member Number to Array Index
            idxMem = mem - 1;

            //Convert Section Number to Array Index
            msect = GModel.con_grp[idxMem].sect;
            idxMsect = msect - 1;

            //Convert Material Number to Array Index
            mat = GModel.sec_grp[idxMsect].mat;
            idxMat = mat - 1;

            udl = udl * GModel.mat_grp[idxMat].density * GModel.sec_grp[idxMsect].ax / clsGeomModel.kilo;
        } //.. Do_Self_Weight ..


        //  << UDL_Slope >>
        public double UDL_Slope(double w0, double v, double c) // Double
        {
            System.Console.WriteLine("UDL_Slope ...");
            return (w0 * v * (4 * (trl * trl - v * v) - c * c) / (24 * trl));
        } //End public void //.. UDL_Slope ..


        //<< Do_Part_UDL >>
        //.. Load type = "u" => #1
        public void Do_Part_UDL(int mno, double wu, double x1, double cv, int wact)
        {
            double la;
            double lb; // Double

            la = x1 + cv / 2;
            lb = trl - la;

            System.Console.WriteLine("Do_Part_UDL ... {0}", mno);
            if (wact != clsGeomModel.local_act)
            {
                Do_Global_Load(mno, wact, wu, x1);
                w_axi = axi_comp * cv;
                Do_Axial_Load(mno, w_axi, la);
            }
            else
            {
                nrm_comp = wu;
                axi_comp = 0;
            } // End If [

            w_nrm = nrm_comp * cv;
            dii = UDL_Slope(w_nrm, lb, cv);
            djj = UDL_Slope(w_nrm, la, cv);

            Calc_Moments(mno, trl, w_nrm, x1, la, cv, clsGeomModel.udl_ld, clsGeomModel.pos_slope); //.. Calculate the span moments
            Calc_FE_Forces(mno, la, lb);
            Process_FE_Actions(mno, la, lb);

            System.Console.WriteLine("... Do_Part_UDL");

        } //.. Do_Part_UDL ..


        //<< PL_Slope >>
        public double PL_Slope(double v) // Double) // Double
        {
            System.Console.WriteLine("PL_Slope ...");
            return (w_nrm * v * (trl * trl - v * v) / (6 * trl));
        } //End public void //.. PL_Slope ..


        //<< Do_Point_load >>
        //.. Load type = "p" => #2
        public void Do_Point_load(int mno, double wu, double x1, int wact)
        {

            System.Console.WriteLine("Do_Point_load ...");
            la = x1;
            lb = trl - la;

            if (wact != clsGeomModel.local_act)
            {
                Do_Global_Load(mno, wact, wu, x1);
                w_axi = axi_comp;
                Do_Axial_Load(mno, w_axi, la);
            }
            else
            {
                nrm_comp = wu;
                axi_comp = 0;
            } // End If [

            w_nrm = nrm_comp;

            dii = PL_Slope(lb);
            djj = PL_Slope(la);

            Calc_Moments(mno, trl, w_nrm, x1, la, 0, clsGeomModel.pnt_ld, clsGeomModel.pos_slope); //.. Calculate the span moments
            Calc_FE_Forces(mno, la, lb);
            Process_FE_Actions(mno, la, lb);

        } //.. Do_Point_load ..


        //<< Tri_Slope >>
        public double Tri_Slope(double v, double w_nrm, double cv, double sl_switch) // Double
        {
            System.Console.WriteLine("Tri_Slope ...");
            gam = cv / trl;
            v = v / trl;
            return (w_nrm * trl * trl * (270 * (v - v * v * v) - gam * gam * (45 * v + sl_switch * 2 * gam)) / 1620);
        } //End public void //.. Tri_Slope ..

        //<< Do_Triangle >>
        //.. Load type =
        public void Do_Triangle(int mno, double w0, double la, double x1, double cv, int wact, int slopedir)
        {
            double lb; // Double


            System.Console.WriteLine("Do_Triangle ...");
            lb = trl - la;

            if (wact != clsGeomModel.local_act)
            {
                Do_Global_Load(mno, wact, w0, x1);
                w_axi = axi_comp * cv / 2;
                Do_Axial_Load(mno, w_axi, la);
            }
            else
            {
                nrm_comp = w0;
                axi_comp = 0;
            } // End If [

            w_nrm = nrm_comp * cv / 2;

            dii = Tri_Slope(lb, w_nrm, cv, clsGeomModel.pos_slope * slopedir); //.. /!  => +ve when +ve slope
            djj = Tri_Slope(la, w_nrm, cv, clsGeomModel.neg_slope * slopedir); //.. !\  => +ve when -ve slope

            Calc_Moments(mno, trl, w_nrm, x1, la, cv, clsGeomModel.tri_ld, slopedir); //.. Calculate the span moments
            Calc_FE_Forces(mno, la, lb);
            Process_FE_Actions(mno, la, lb);

        } //.. Do_Triangle ..



        //<< Do_Distributed_load >>
        //.. Load type = "v" => #1
        public void Do_Distributed_load(int mno, double wm1, double wm2, double x1, double cv, int lact)
        {
            double wudl; // Double,
            double wtri; // Double,
            int slope; // Double,
            double ltri; // Double

            System.Console.WriteLine("Do_Distributed_load ... {0}", mno);

            if (wm1 == wm2)
            { //..  load is a UDL
                Do_Part_UDL(mno, wm1, x1, cv, lact);
            }
            else
            {
                if (Math.Abs(wm1) < Math.Abs(wm2))
                { //..  positive slope ie sloping upwards / left ; i<= right
                    wudl = wm1;
                    wtri = wm2 - wudl;
                    slope = clsGeomModel.pos_slope;
                    ltri = x1 + 2 * cv / 3;
                }
                else
                { //..  negative slope ie sloping upwards \ right ; i<= left
                    wudl = wm2;
                    wtri = wm1 - wudl;
                    slope = clsGeomModel.neg_slope;
                    ltri = x1 + cv / 3;
                } // End If [

                poslope = (slope == clsGeomModel.pos_slope);

                if (wudl != 0)
                {
                    Do_Part_UDL(mno, wudl, x1, cv, lact);
                } // End If [

                if (wtri != 0)
                {
                    Do_Triangle(mno, wtri, ltri, x1, cv, lact, slope);
                } // End If [

            } // End If [

            System.Console.WriteLine("... Do_Distributed_load");

        } //.. Do_Distributed_load ..



        //    << Get_FE_Forces >>
        public void Get_FE_Forces(int kMemberNum, int ldty, double wm1, double wm2, double x1, double cvr, int lact)
        {


            System.Console.WriteLine("Get_FE_Forces ... {0}", kMemberNum);
            switch (ldty) //.. Get_FE_Forces ..
            {
                case clsGeomModel.dst_ld:
                    //..  "v" = #1
                    Do_Distributed_load(kMemberNum, wm1, wm2, x1, cvr, lact);
                    break;
                case clsGeomModel.pnt_ld:
                    //..  "p" = #2
                    Do_Point_load(kMemberNum, wm1, x1, lact);
                    break;
                case clsGeomModel.axi_ld:
                    //..  "a" = #3
                    Do_Axial_Load(kMemberNum, wm1, x1);
                    break;

            } // End Select

        } //.. Get_FE_Forces ..


        //  << Process_Loadcases >>
        public void Process_Loadcases()
        {
            int idxMem;
            System.Console.WriteLine();
            System.Console.WriteLine("<Process_Loadcases ...>");
            if (GModel.structParam.njl != 0)
            {
                System.Console.WriteLine("[Joint Loads]");
                System.Console.WriteLine("nml = {0} {0}", GModel.structParam.njl.ToString());
                for (global_i = baseIndex; global_i < GModel.structParam.njl; global_i++)
                {
                    //With jnt_lod[global_i]
                    Get_Joint_Indices(GModel.jnt_lod[global_i].jt);

                    fc[j1] = GModel.jnt_lod[global_i].fx;
                    fc[j2] = GModel.jnt_lod[global_i].fy;
                    fc[j3] = GModel.jnt_lod[global_i].mz;
                    // EndWith
                } // next i
            } // End If [

            if (GModel.structParam.nml != 0)
            {
                System.Console.WriteLine("[Member Loads]");
                System.Console.WriteLine("nml = {0} {0}", GModel.structParam.nml.ToString());
                for (global_i = baseIndex; global_i < GModel.structParam.nml; global_i++)
                {
                    //With mem_lod[global_i]
                    System.Console.WriteLine("i= {0}", global_i);
                    idxMem = GModel.mem_lod[global_i].mem_no - 1;
                    System.Console.WriteLine("mem_no= {0}", GModel.mem_lod[global_i].mem_no);
                    trl = mlen[idxMem];
                    cosa = rot_mat[idxMem, ndx1]; //.. Cos
                    sina = rot_mat[idxMem, ndx2]; //.. Sin
                    ldc = GModel.mem_lod[global_i].lcode;
                    wm1 = GModel.mem_lod[global_i].ld_mag1;
                    wm2 = GModel.mem_lod[global_i].ld_mag2;
                    cvr = GModel.mem_lod[global_i].cover;
                    x1 = GModel.mem_lod[global_i].start;
                    if ((ldc == clsGeomModel.dst_ld) && (cvr == 0))
                    {
                        x1 = 0;
                        cvr = trl;
                    } // End If [
                    //Pass Member Numbers, Convert to Index internally
                    Get_FE_Forces(GModel.mem_lod[global_i].mem_no, ldc, wm1, wm2, GModel.mem_lod[global_i].start, cvr, GModel.mem_lod[global_i].f_action);
                    fpTracer.WriteLine("FC[]: " + global_i.ToString());
                    fprintVector(fc);
                    fpTracer.WriteLine();
                    // EndWith
                    System.Console.WriteLine();

                } // next i
            } // End If [

            if (GModel.structParam.ngl != 0)
            {
                System.Console.WriteLine("[Gravity Loads]");
                System.Console.WriteLine("ngl = {0}", GModel.structParam.ngl.ToString());
                for (global_i = baseIndex; global_i < GModel.structParam.nmb; global_i++)
                {
                    //With grv_lod
                    x1 = 0;
                    trl = mlen[global_i];
                    cvr = trl;
                    cosa = rot_mat[global_i, ndx1];
                    sina = rot_mat[global_i, ndx2];
                    udl = GModel.grv_lod.load;
                    ldc = clsGeomModel.dst_ld; // ud_ld        //.. 1
                    Do_Self_Weight(global_i);
                    nrm_comp = udl;
                    if (GModel.grv_lod.f_action != clsGeomModel.local_act)
                    {
                        Do_Global_Load(global_i, GModel.grv_lod.f_action, udl, 0);
                    } // End If [
                    Get_FE_Forces(global_i, clsGeomModel.dst_ld, nrm_comp, nrm_comp, x1, cvr, GModel.grv_lod.f_action);
                    // EndWith
                } // next i
            } // End If [
        } //.. Process_Loadcases ..

        //End    ////.. DoLoads Module ..
        //===========================================================================




        //  << Zero_Vars >>
        public void Zero_Vars()
        {
            int i;

            System.Console.WriteLine("Zero_Vars ...");

            //GModel.initialise();  

            //Erase mlen;  // Each element set ; i<= 0.
            for (i = 0; i < v_size; i++)
            {
                mlen[i] = 0;
            }

            //Erase ad;
            for (i = 0; i < v_size; i++)
            {
                ad[i] = 0;
            }

            //Erase fc;
            for (i = 0; i < v_size; i++)
            {
                fc[i] = 0;
            }

            //Erase ar;
            for (i = 0; i < v_size; i++)
            {
                ar[i] = 0;
            }

            //Erase dj;
            for (i = 0; i < v_size; i++)
            {
                dj[i] = 0;
            }

            //Erase dd;
            for (i = 0; i < v_size; i++)
            {
                dd[i] = 0;
            }

            //Erase rjl;
            for (i = 0; i < v_size; i++)
            {
                rjl[i] = 0;
            }

            //Erase crl;
            for (i = 0; i < v_size; i++)
            {
                crl[i] = 0;
            }

            //Erase rot_mat;
            rot_mat.Initialize();

            af.Initialize();
            sj.Initialize();
            s.Initialize();
            mom_spn.Initialize();

        } //.. Zero_Vars ..



        //  << Initialise >>
        public void Initialise()
        {
            System.Console.WriteLine("<Initialise ...>");
            ra = 0;
            rb = 0;
            global_i = 0;
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
        public int Translate_Ndx(int i) // Byte) // Integer
        {
            //System.Console.WriteLine("Translate_Ndx ...",i);
            return (i - crl[i]);
        } //End public void  //.. Translate_Ndx ..



        //  << Equiv_Ndx >>
        //  ..equivalent matrix configuration joint index numbers
        public int Equiv_Ndx(int j) // Integer
        {
            //System.Console.WriteLine("Equiv_Ndx ...",j);
            return (rjl[j] * (nn + crl[j]) + (1 - rjl[j]) * Translate_Ndx(j));
        } //End public void //.. Equiv_Ndx ..


        //  << Get_Joint_Indices >>
        //  ..  get equivalent matrix index numbers
        public void Get_Joint_Indices(int nd) // Byte)
        {
            System.Console.WriteLine("Get_Joint_Indices ... {0}", nd);
            j0 = (3 * nd) - 1;
            j3 = Equiv_Ndx(j0);
            j2 = j3 - 1;
            j1 = j2 - 1;

            System.Console.WriteLine("{0} {1} {2} {3}", j0, j1, j2, j3);

        } //.. Get_Joint_Indices ..


        //  << Get_Direction_Cosines >>
        public void Get_Direction_Cosines()
        {
            int i; // Byte
            int tmp; // Byte
            int rel_tmp; // Byte
            double xm; // Double
            double ym; // Double


            System.Console.WriteLine("Get_Direction_Cosines ...");
            for (i = baseIndex; i < GModel.structParam.nmb; i++)
            {
                //With con_grp[i]
                //System.Console.WriteLine( i.ToString() + ": " + con_grp[i].jj.ToString() + " , " + con_grp[i].jk.ToString())

                //Swap node subscripts so that near end subscript (jj) is smaller than far end subscript (jk)
                if (GModel.con_grp[i].jk < GModel.con_grp[i].jj)
                { //.. swap end1 with end2 if smaller !! ..
                    tmp = GModel.con_grp[i].jj;
                    GModel.con_grp[i].jj = GModel.con_grp[i].jk;
                    GModel.con_grp[i].jk = tmp;

                    rel_tmp = GModel.con_grp[i].rel_j;
                    GModel.con_grp[i].rel_j = GModel.con_grp[i].rel_i;
                    GModel.con_grp[i].rel_i = rel_tmp;
                } // End If

                //Calculate deltaX and deltaY
                xm = GModel.nod_grp[getArrayIndex(GModel.con_grp[i].jk)].x - GModel.nod_grp[getArrayIndex(GModel.con_grp[i].jj)].x;
                ym = GModel.nod_grp[getArrayIndex(GModel.con_grp[i].jk)].y - GModel.nod_grp[getArrayIndex(GModel.con_grp[i].jj)].y;
                //Calculate Length of Member
                mlen[i] = Math.Sqrt(xm * xm + ym * ym);

                //System.Console.WriteLine( i.ToString() + ": mlen[i]: " + mlen[i].ToString());

                //rot_mat[i] = new Array();
                //Determine Direction Cosines : Unit Direction Vector for member
                rot_mat[i, ndx1] = xm / mlen[i]; //.. Cos
                rot_mat[i, ndx2] = ym / mlen[i]; //.. Sin

                // EndWith
            } // next i

            System.Console.WriteLine("... Get_Direction_Cosines");

        } //.. Get_Direction_Cosines ..



        //  << Total_Section_Mass >>
        public void Total_Section_Mass()
        {
            int i; // Integer

            System.Console.WriteLine("Total_Section_Mass ...");
            for (i = baseIndex; i < GModel.structParam.nsg; i++)
            {
                //With mat_grp[sec_grp[i].mat]
                GModel.sec_grp[i].t_mass = GModel.sec_grp[i].ax * GModel.mat_grp[getArrayIndex(GModel.sec_grp[i].mat)].density * GModel.sec_grp[i].t_len;
                //System.Console.WriteLine(getArrayIndex(sec_grp[i].mat));
                //System.Console.WriteLine(mat_grp[getArrayIndex(sec_grp[i].mat)].density);
                //System.Console.WriteLine(i.ToString() + ": " + sec_grp[i].t_mass.ToString());
                // EndWith
            } // next i
        } //.. Total_Section_Mass ..



        //  << Total_Section_Length >>
        // Total length of all members of a given Section.
        public void Total_Section_Length()
        {
            int ndx;

            System.Console.WriteLine("<Total_Section_Length>");
            for (global_i = baseIndex; global_i < GModel.structParam.nmb; global_i++)
            {
                //With con_grp[global_i]
                ndx = getArrayIndex(GModel.con_grp[global_i].sect);
                //System.Console.WriteLine(ndx.ToString() + ": " + mlen[global_i].ToString());
                GModel.sec_grp[ndx].t_len = GModel.sec_grp[ndx].t_len + mlen[global_i];
                //System.Console.WriteLine(sec_grp[ndx].t_len.ToString());
                // EndWith
            } // next i
            Total_Section_Mass();
        } //.. Total_Section_Length ..


        //    << Get_Min_Max >>
        //    ..find critical End forces ..
        public void Get_Min_Max()
        {


            System.Console.WriteLine("<Get_Min_Max ...>");
            maxM = 0;
            MaxMJnt = 0;
            maxMmemb = 0;

            MinM = clsGeomModel.infinity;
            MinMJnt = 0;
            MinMmemb = 0;

            maxA = 0;
            MaxAJnt = 0;
            maxAmemb = 0;

            MinA = clsGeomModel.infinity;
            MinAJnt = 0;
            MinAmemb = 0;

            for (global_i = baseIndex; global_i < GModel.structParam.nmb; global_i++)
            {


                //With con_grp[global_i]

                //         .. End moments ..
                if (maxM < GModel.con_grp[global_i].jnt_jj.momnt)
                {
                    maxM = GModel.con_grp[global_i].jnt_jj.momnt;
                    MaxMJnt = GModel.con_grp[global_i].jj;
                    maxMmemb = global_i;
                } // End If [

                if (maxM < GModel.con_grp[global_i].jnt_jk.momnt)
                {
                    maxM = GModel.con_grp[global_i].jnt_jk.momnt;
                    MaxMJnt = GModel.con_grp[global_i].jk;
                    maxMmemb = global_i;
                } // End If [

                if (MinM > GModel.con_grp[global_i].jnt_jj.momnt)
                {
                    MinM = GModel.con_grp[global_i].jnt_jj.momnt;
                    MinMJnt = GModel.con_grp[global_i].jj;
                    MinMmemb = global_i;
                } // End If [

                if (MinM > GModel.con_grp[global_i].jnt_jk.momnt)
                {
                    MinM = GModel.con_grp[global_i].jnt_jk.momnt;
                    MinMJnt = GModel.con_grp[global_i].jk;
                    MinMmemb = global_i;
                } // End If [

                //         .. End axials ..
                if (maxA < GModel.con_grp[global_i].jnt_jj.axial)
                {
                    maxA = GModel.con_grp[global_i].jnt_jj.axial;
                    MaxAJnt = GModel.con_grp[global_i].jj;
                    maxAmemb = global_i;
                } // End If [

                if (maxA < GModel.con_grp[global_i].jnt_jk.axial)
                {
                    maxA = GModel.con_grp[global_i].jnt_jk.axial;
                    MaxAJnt = GModel.con_grp[global_i].jk;
                    maxAmemb = global_i;
                } // End If [

                if (MinA > GModel.con_grp[global_i].jnt_jj.axial)
                {
                    MinA = GModel.con_grp[global_i].jnt_jj.axial;
                    MinAJnt = GModel.con_grp[global_i].jj;
                    MinAmemb = global_i;
                } // End If [

                if (MinA > GModel.con_grp[global_i].jnt_jk.axial)
                {
                    MinA = GModel.con_grp[global_i].jnt_jk.axial;
                    MinAJnt = GModel.con_grp[global_i].jk;
                    MinAmemb = global_i;
                } // End If [

                //         .. End shears..
                if (maxQ < GModel.con_grp[global_i].jnt_jj.shear)
                {
                    maxQ = GModel.con_grp[global_i].jnt_jj.shear;
                    MaxQJnt = GModel.con_grp[global_i].jj;
                    maxQmemb = global_i;
                } // End If [

                if (maxQ < GModel.con_grp[global_i].jnt_jk.shear)
                {
                    maxQ = GModel.con_grp[global_i].jnt_jk.shear;
                    MaxQJnt = GModel.con_grp[global_i].jk;
                    maxQmemb = global_i;
                } // End If [

                if (MinQ > GModel.con_grp[global_i].jnt_jj.shear)
                {
                    MinQ = GModel.con_grp[global_i].jnt_jj.shear;
                    MinQJnt = GModel.con_grp[global_i].jj;
                    MinQmemb = global_i;
                } // End If [

                if (MinQ > GModel.con_grp[global_i].jnt_jk.shear)
                {
                    MinQ = GModel.con_grp[global_i].jnt_jk.shear;
                    MinQJnt = GModel.con_grp[global_i].jk;
                    MinQmemb = global_i;
                } // End If [

                // EndWith
            } // next i
        } //{.. Get_Min_Max ..}


        public void TraceRotMat()
        {
            double stmp;
            int i, j;

            fpTracer.WriteLine("rot_mat[i,j] ... ");
            for (i = 0; i < v_size; i++)
            {
                for (j = 0; j < 2; j++)
                {
                    stmp = rot_mat[i, j];
                    fpTracer.Write(stmp.ToString().PadLeft(15));
                }
                fpTracer.WriteLine();
            }

        }

        public void Trace_s()
        {
            double stmp;
            int i, j;

            fpTracer.WriteLine("s[i,j] ... ");
            for (i = df1; i < df6 + 1; i++)
            {
                for (j = df1; j < df6 + 1; j++)
                {
                    stmp = s[i, j];
                    fpTracer.Write(stmp.ToString().PadLeft(15));
                }
                fpTracer.WriteLine();
            }


        }

        public void Trace_sj()
        {
            double stmp;
            int i, j;

            System.Console.WriteLine("Trace_sj ...");
            fpTracer.WriteLine("sj[i,j] ... ");
            for (i = startIndex; i < order; i++)
            {
                for (j = startIndex; j < v_size; j++)
                {

                    stmp = sj[i, j];
                    fpTracer.Write(stmp.ToString().PadLeft(15));
                }
                fpTracer.WriteLine();
            }
            System.Console.WriteLine("... Trace_sj");
        }




        //   << Analyse_Frame >>
        public void Analyse_Frame()
        {

            int i;

            //Get definition of the Plane Frame ; i<= Analyse

            //    Set MiWrkBk = ActiveWorkbook
            System.Console.WriteLine(">>> Analysis of Frame Started <<<");
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
            fpTracer.WriteLine("hbw: {0}", hbw);
            fpTracer.WriteLine("nn: {0}", nn);


            //Assemble Stiffness Matrix
            System.Console.WriteLine();
            System.Console.WriteLine(">>> Assemble_Global_Stiff_Matrix <<<");
            for (i = baseIndex; i < GModel.structParam.nmb; i++)
            {
                Assemble_Global_Stiff_Matrix(i);
                //Trace_s();
                fpTracer.Write("S[]: ");
                fpTracer.WriteLine(i.ToString());
                fprintMatrix(s);

                System.Console.WriteLine();
                Assemble_Struct_Stiff_Matrix(i);
                // Trace_sj();
                fpTracer.Write("SJ[]: ");
                fpTracer.WriteLine(i.ToString());
                fprintMatrix(sj);
                System.Console.WriteLine();


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

            System.Console.WriteLine("*** Analysis Completed *** ");

        } //.. Analyse_Frame ..


        //===========================================================================
        //REPORTING
        //===========================================================================

        //    <<< PrtDeltas >>>
        public void fprintDeltas(int r, int c)
        {
            string txt1, txt2, txt3, txt4;
            int idx1, idx2, idx3;

            System.Console.WriteLine("fprintDeltas ...");
            fpRpt.WriteLine("fprintDeltas ...");
            for (global_i = baseIndex + 1; global_i <= GModel.structParam.njt; global_i++)
            {
                txt1 = global_i.ToString().PadLeft(4);

                idx1 = 3 * global_i - 3;
                idx2 = 3 * global_i - 2;
                idx3 = 3 * global_i - 1;

                txt2 = (-dj[idx1]).ToString("0.0000").PadLeft(8);
                txt3 = (-dj[idx2]).ToString("0.0000").PadLeft(8);
                txt4 = (-dj[idx3]).ToString("0.00000").PadLeft(8);

                //fpRpt.WriteLine(txt1 + " " + txt2 + " " + txt3 + " " + txt4);

                fpRpt.WriteLine("{0,4:0} {1,8:0.0000} {2,8:0.0000} {3,8:0.00000}", global_i, -dj[idx1], -dj[idx2], -dj[idx3]);

                r = r + 1;
            } //next i

            fpRpt.WriteLine();
            System.Console.WriteLine("... fprintDeltas");
        } //...PrtDeltas

        //   <<< PrtEndForces >>>
        public void fprintEndForces(int r, int c)
        {
            string txt0, txt1, txt2, txt3, txt4, txt5;
            string txt6, txt7, txt8, txt9, txt10, txt;
            string tmp;
            int i;

            System.Console.WriteLine("fprintEndForces ...");
            fpRpt.WriteLine("fprintEndForces ...");
            for (i = baseIndex; i < GModel.structParam.nmb; i++)
            {
                //With con_grp(i)
                txt0 = i.ToString().PadLeft(8);
                txt1 = mlen[i].ToString("0.000").PadLeft(8);

                txt2 = GModel.con_grp[i].jj.ToString().PadLeft(8);
                txt3 = GModel.con_grp[i].jnt_jj.axial.ToString("0.000").PadLeft(15);
                txt4 = GModel.con_grp[i].jnt_jj.shear.ToString("0.000").PadLeft(15);
                txt5 = GModel.con_grp[i].jnt_jj.momnt.ToString("0.000").PadLeft(15);

                txt6 = GModel.con_grp[i].jk.ToString().PadLeft(8);
                txt7 = GModel.con_grp[i].jnt_jk.axial.ToString("0.000").PadLeft(15);
                txt8 = GModel.con_grp[i].jnt_jk.shear.ToString("0.000").PadLeft(15);
                txt9 = GModel.con_grp[i].jnt_jk.momnt.ToString("0.000").PadLeft(15);

                txt = txt0 + " " + txt1 + " " + txt2 + " " + txt3 + " " + txt4 + " " + txt5;
                txt = txt + " " + txt6 + " " + txt7 + " " + txt8 + " " + txt9;
                fpRpt.WriteLine(txt);
                // } With
                r = r + 1;
            } //next i

            fpRpt.WriteLine();
            System.Console.WriteLine("... fprintEndForces");
        } //...PrtEndForces

        //    << Prt_Reaction_Sum >>
        public void fprintReaction_Sum(int r, int c)
        {
            string txt0, txt1;

            fpRpt.WriteLine("fprintReaction_Sum ...");
            txt0 = sumx.ToString("0.000").PadLeft(15);
            txt1 = sumy.ToString("0.000").PadLeft(15);
            fpRpt.WriteLine(txt0 + " " + txt1);
            fpRpt.WriteLine();

        } //.. Prt_Reaction_Sum ..

        //    <<< PrtReactions >>>
        public void fprintReactions(int row1, int col1)
        {
            int i, k, k3, c, r;
            string txt0, txt1, txt2;

            System.Console.WriteLine("fprintReactions ...");
            fpRpt.WriteLine("fprintReactions ...");

            for (k = baseIndex; k < n3; k++)
            {
                if (rjl[k] == 1)
                {
                    ar[k] = ar[k] - fc[Equiv_Ndx(k)];
                }
            } //next k
            sumx = 0;
            sumy = 0;

            r = row1;
            for (i = baseIndex; i < GModel.structParam.nrj; i++)
            {
                c = col1 + 1;
                //With sup_grp(i)
                txt0 = GModel.sup_grp[i].js.ToString();
                flag = 0;
                c = c + 1;
                k3 = 3 * GModel.sup_grp[i].js - 1;
                for (k = k3 - 2; k <= k3; k++)
                {
                    if ((k + 1) % 3 == 0)
                    {
                        txt1 = ar[k].ToString("0.000").PadLeft(15);
                        fpRpt.Write(txt1);
                    }
                    else
                    {
                        txt2 = ar[k].ToString("0.000").PadLeft(15);
                        fpRpt.Write(txt2);
                        if (flag == 0)
                        {
                            sumx = sumx + ar[k];
                        }
                        else
                        {
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

            fprintReaction_Sum(row1 - 5, col1 + 1);

            fpRpt.WriteLine();
            System.Console.WriteLine("... fprintReactions");

        } //...PrtReactions

        //    << Prt_Controls >>
        public void fprintControls(int r, int c)
        {
            string txt0, txt1, txt2, txt3, txt4, txt5;
            string txt6, txt7, txt8, txt9, txt10, txt;
            int i;

            System.Console.WriteLine("fprintControls ...");
            fpRpt.WriteLine("fprintControls ...");
            txt1 = GModel.structParam.njt.ToString().PadLeft(6);
            txt2 = GModel.structParam.nmb.ToString().PadLeft(6);
            txt3 = GModel.structParam.nmg.ToString().PadLeft(6);
            txt4 = GModel.structParam.nsg.ToString().PadLeft(6);
            txt5 = GModel.structParam.nrj.ToString().PadLeft(6);
            txt6 = GModel.structParam.njl.ToString().PadLeft(6);
            txt7 = GModel.structParam.nml.ToString().PadLeft(6);
            txt8 = GModel.structParam.ngl.ToString().PadLeft(6);
            txt9 = GModel.structParam.nr.ToString().PadLeft(6);

            txt = txt1 + " " + txt2 + " " + txt3 + " " + txt4 + " " + txt5;
            txt = txt + " " + txt6 + " " + txt7 + " " + txt8 + " " + txt9;
            fpRpt.WriteLine(txt);
            fpRpt.WriteLine();

        } //.. Prt_Controls ..

        //    <<< Prt_Section_Details >>>
        public void fprintSection_Details(int r, int c)
        {
            string txt0, txt1, txt2, txt3, txt4, txt5;
            string txt6, txt7, txt8, txt9, txt10, txt;
            int i;

            System.Console.WriteLine("fprintSection_Details ...");
            fpRpt.WriteLine("fprintSection_Details ...");
            for (i = baseIndex; i < GModel.structParam.nmg; i++)
            {


                txt1 = i.ToString().PadLeft(8);
                txt2 = GModel.sec_grp[i].t_len.ToString("0.000").PadLeft(8);

                //txt3 = StrLPad(sec_grp[i].t_mass,8);
                txt3 = "<>";

                txt4 = GModel.sec_grp[i].Descr.ToString().PadLeft(8);

                txt = txt1 + " " + txt2 + " " + txt3 + " " + txt4;
                fpRpt.WriteLine(txt);

                r = r + 1;
            } //next i

            fpRpt.WriteLine();
            System.Console.WriteLine("... fprintSection_Details");
        } //...Prt_Section_Details

        //   <<< PrtSpanMoments >>>
        public void fprintSpanMoments()
        {
            int r; // Integer
            int c; // Integer
            double seg; // Double
            double tmp;
            string tmpStr;
            int i, j;

            string txt0, txt1, txt2, txt3, txt4, txt5;
            string txt6, txt7, txt8, txt9, txt10, txt;

            System.Console.WriteLine("fprintSpanMoments ...");
            fpRpt.WriteLine("fprintSpanMoments ...");
            //  MiWrkBk.Worksheets("MSpan").Activate
            //  Set Prnge = MiWrkBk.Worksheets("MSpan").Range("A1:A1")
            r = 7;
            c = 1;

            for (i = baseIndex; i < GModel.structParam.nmb; i++)
            {
                seg = mlen[i] / n_segs;
                txt1 = i.ToString().PadLeft(8);
                r = r + 1;
                for (j = 0; j <= n_segs; j++)
                {
                    txt2 = j.ToString().PadLeft(8);

                    tmp = j * seg;
                    txt3 = tmp.ToString("0.000").PadLeft(8);
                    txt4 = mom_spn[i, j].ToString("0.00").PadLeft(15);

                    txt = txt1 + " " + txt2 + " " + txt3 + " " + txt4;
                    fpRpt.WriteLine(txt);

                    r = r + 1;
                } //next j

                fpRpt.WriteLine();
                r = 7;
                c = c + 3;
            } //next i

            fpRpt.WriteLine();
            System.Console.WriteLine("... fprintSpanMoments");
        } //...PrtSpanMoments




        //     << Output Results to Table >>
        public void fprintResults()
        {

            System.Console.WriteLine("fprintResults ...");

            fprintControls(4, 1);
            fprintDeltas(18, 1);
            fprintEndForces(18, 6);
            fprintReactions(18, 16);
            fprintSection_Details(5, 6);
            fprintSpanMoments();

            System.Console.WriteLine("... fprintResults");

        } //..PrintResults







        //===========================================================================
        //END    ''.. Main Module ..
        //===========================================================================

        //===========================================================================

    } //class
} // name space
