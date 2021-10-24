//
// Copyright (c)2016 S C Harrison
// Refer to License.txt for terms and conditions of use.
//
import java.io.*;

class planeframe02 {

	// Need to convert to zero based arrays.
	// But also retain some of logic: for example 6 degrees of freedom NOT zero
	// to 5.
	// Can ignore the zeroth indexed elements in some situations.
	// But ignoring the elements is wasteful of memory
	// In JavaScript need to initialise and create the zeroth element before
	// avoid using: not really any different than other language.
	// Could use constants or functions for the array indices: though may make
	// less readable {too wordy}
	// All table data read in, assumes a starting index of 1: this cannot be
	// used to directly index the arrays.
	// Probably shouldn't have been in first place.

	// Plan: replace indices with constants/descriptors

	//
	// ------------------------------------------------------------------------------
	// INTERFACE
	// ------------------------------------------------------------------------------
	//
	// Define Global/Public Variables
	// ==============================================================================
	// int jobData; //(5); // String

	public BufferedReader fpText;
	public BufferedWriter fpRpt;
	public BufferedWriter fpTracer;

	public clsGeomModel GModel = new clsGeomModel();

	public boolean data_loaded; // boolean

	static double sumx; // Double
	static double sumy; // Double

	// ------------------------------------------------------------------------------
	// IMPLEMENTATION
	// ------------------------------------------------------------------------------

	// .. enumeration constants ..
	final int ndx0 = 0;
	final int ndx1 = 0;
	final int ndx2 = 1;

	final int startIndex = 0;
	final int startZero = 0;
	final int StartCounter = 1;

	final int df1 = 0; // degree of freedom 1
	final int df2 = 1;
	final int df3 = 2;
	final int df4 = 3;
	final int df5 = 4;
	final int df6 = 5;

	// ... Constant declarations ...

	static int baseIndex = 0;
	static int numloads = 80; // Integer = 80
	static int order = 50; // Integer = 50
	static int v_size = 50; // Integer = 50
	static int max_grps = 25; // Integer = 25
	static int max_mats = 10; // Integer = 10
	static int n_segs = 7; // Byte = 10

	// Scalars
	static double cosa; // Double // .. member's direction cosines ..
	static double sina; // Double // .. member's direction cosines ..
	static double c2; // Double // .. Cos^2
	static double s2; // Double // .. Sin^2
	static double cs; // Double // .. Cos x Sin
	static double fi; // Double // .. fixed end moment @ end "i" of a member ..
	static double fj; // Double // .. fixed end moment @ end "j" of a member ..
	static double a_i; // Double // .. fixed end axial force @ end "i" ..
	static double a_j; // Double // .. fixed end axial force @ end "j" ..
	static double ri; // Double // .. fixed end shear @ end "i" ..
	static double rj; // Double // .. fixed end shear @ end "j" ..
	static double dii; // Double // .. slope public void @ end "i" ..
	static double djj; // Double // .. slope public void @ end "j" ..
	static double ao2; // Double

	static int ldc; // Integer // .. load type

	static double x1; // Double // .. start position ..
	static double la; // Double // .. dist from end "i" to centroid of load ..
	static double lb; // Double // .. dist from end "j" to centroid of load ..
	static double udl; // Double // .. uniform load
	static double wm1; // Double // .. load magnitude 1
	static double wm2; // Double // .. load magnitude 2
	static double cvr; // Double // .. length covered by load
	static double w1; // Double
	static double ra; // Double // .. reaction @ end A
	static double rb; // Double // .. reaction @ end B
	static double w_nrm; // Double // .. total load normal to member ..
	static double w_axi; // Double // .. total load axial to member ..
	static double wchk; // Double // .. check reaction sum on span
	static double nrm_comp; // Double // .. load normal to member
	static double axi_comp; // Double // .. load axial to member
	static double poa; // Double // .. point of application ..
	static double stn; // Double
	static double seg; // Double

	static int hbw; // Integer // .. upper band width of the joint stiffness
					// matrix ..
	static int nn; // Integer // .. No. of degrees of freedom @ the joints ..
	static int n3; // Integer // .. No. of joints x 3 ..

	static double eaol; // Double // .. elements of the member stiffness matrix
						// .. EA/L
	static double trl; // Double // .. true length of a member ..
	static double gam; // Double // .. gamma = cover/length

	static double ci; // Double
	static double cj; // Double
	static double ccl; // Double
	static double ai; // Double
	static double aj; // Double

	static int global_i; // Byte
	static int global_j; // Integer
	static int global_k; // Integer

	// Index Variables
	static int j0; // Integer
	static int j1; // Integer
	static int j2; // Integer
	static int j3; // Integer

	// Index Variables
	static int k0; // Integer
	static int k1; // Integer
	static int k2; // Integer
	static int k3; // Integer

	static int diff; // Integer
	static int flag; // Byte

	// static int sect; // Byte
	// static int rel; // Byte

	static boolean poslope; // boolean

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

	// ------------------
	// Array Variables
	// ------------------

	// Vectors and Matrices
	// Vectors
	static double[] mlen = new double[v_size]; // .. member length ..
	static int[] rjl = new int[v_size]; // .. restrained joint list ..
	static int[] crl = new int[v_size]; // .. cumulative joint restraint list ..

	static double[] fc = new double[v_size]; // .. combined joint loads ..

	static double[] dd = new double[v_size]; // .. joint displacements @ free
												// nodes ..
	static double[] dj = new double[v_size]; // .. joint displacements @ ALL the
												// nodes ..
	static double[] ad = new double[v_size]; // /.. member end forces not
												// including fixed end forces ..
	static double[] ar = new double[v_size]; // .. support reactions ..

	// Matrices
	static double[][] rot_mat = new double[v_size][2]; // .. member rotation
														// matrix ..
	static double[][] s = new double[order][v_size]; // .. member stiffness
														// matrix ..
	static double[][] sj = new double[order][v_size]; // .. joint stiffness
														// matrix ..

	static double[][] af = new double[order][v_size]; // Double //.. member
														// fixed end forces ..
	static double[][] mom_spn = new double[max_grps][n_segs + 1]; // .. member
																	// span
																	// moments
																	// ..

	public void fprintVector(int[] a) {
		int i, n;
		n = a.length;

		try {
			for (i = 0; i < n; i++) {
				fpTracer.write(String.format("%15d}", a[i]));
			}

			fpTracer.newLine();
		} catch (IOException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		}
	}

	public void fprintVector(double[] a) {
		int i, n;
		n = a.length;

		try {
			for (i = 0; i < n; i++) {
				fpTracer.write(String.format("%15.4f}", a[i]));
			}

			fpTracer.newLine();
		} catch (IOException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		}
	}

	public void fprintMatrix(double[][] a) {
		int i, j;

		try {
			for (i = 0; i < a.length; i++) {
				fpTracer.write(String.format("%4d", i));
				for (j = 0; j < a[i].length; j++) {
					fpTracer.write(String.format("%15.4f", a[i][j]));
				}
				fpTracer.newLine();
			}

		} catch (IOException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		}
	}

	// {###### Pf_Solve.PAS ######
	// ... a module of Bandsolver routines for ( the Framework Program-
	// R G Harrison -- Version 1.1 -- 12/05/05 ...
	// Revision history //-
	// 12/05/05 - implemented ..
	// {<<< START CODE >>>>}
	// ===========================================================================

	public int getArrayIndex(int key) {
		int tmp = 0;

		// One option unreachable as baseIndex is a constant not a variable
		switch (baseIndex) {
		case 0:
			tmp = (key - 1);
			break;

		case 1:
			tmp = key;
			break;

		}

		return tmp;
	}

	// << Choleski_Decomposition >>
	// .. matrix decomposition by the Choleski method..
	public void Choleski_Decomposition(double[][] sj, int ndof, int hbw) {
		int p, q; // Integer;
		double su = 0.0;
		double te = 0.0; // Double;

		int indx1, indx2, indx3;
		// WrMat["Decompose IN sj ..", sj, ndof, hbw]
		// PrintMat["Choleski_Decomposition  IN sj[] ..", sj[], dd[], ndof, hbw]

		System.out.println("<Choleski_Decomposition ...>");
		System.out.format("ndof, hbw %d %d%n", ndof, hbw);
		for (global_i = baseIndex; global_i < ndof; global_i++) {
			System.out.format("global_i= %d%n", global_i);
			p = ndof - global_i - 1;

			if (p > hbw - 1) {
				p = hbw - 1;
			}

			for (global_j = baseIndex; global_j < (p + 1); global_j++) {
				q = (hbw - 2) - global_j;
				if (q > global_i - 1) {
					q = global_i - 1;
				}

				su = sj[global_i][global_j];

				if (q >= 0) {
					for (global_k = baseIndex; global_k < q + 1; global_k++) {
						if (global_i > global_k) {
							// su = su - sj[global_i - global_k][global_k + 1] *
							// sj[global_i - global_k][global_k + global_j];
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
						System.out.println("matrix -ve TERM Terminated ???");
						// End

					} else {
						// BEGIN
						te = 1 / Math.sqrt(su);
						sj[global_i][global_j] = te;
					} // End If [
				} // End If [
			} // next j

			System.out.format("SJ[]: %d%n", global_i);
			try {
				fpTracer.write("SJ[]: " + String.format("%d", global_i));
				fpTracer.newLine();
			} catch (IOException e) {
				// TODO Auto-generated catch block
				e.printStackTrace();
			}
			fprintMatrix(sj);

		} // next i

		// PrintMat["Choleski_Decomposition  OUT sj[] ..", sj[], dd[], ndof,
		// hbw]

	} // .. Choleski_Decomposition ..

	// << Solve_Displacements >>
	// .. perform forward and backward substitution ; i<= solve the system ..
	public void Solve_Displacements() {
		double su;
		int i, j;
		int idx1, idx2;

		System.out.println();
		System.out.println("<Solve_Displacements ...>");
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

		for (i = nn - 1; i >= baseIndex; i--) {
			j = i + hbw - 1;
			if (j > nn - 1) {
				j = nn - 1;
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
			// WrFVector["Solve Displacements  dd..  ", dd[], nn]
	} // .. Solve_Displacements ..

	// End ////.. CholeskiDecomp Module ..
	// ===========================================================================

	// {###### Pf_Anal.PAS ######
	// ... a module of Analysis Routines for ( the Framework Program -
	// R G Harrison -- Version 1.1 -- 12/05/05 ...
	// Revision history //-
	// 12/05/05 - implemented ..

	// {<<< START CODE >>>>}
	// ===========================================================================

	// << Fill_Restrained_Joints_Vector >>
	public void Fill_Restrained_Joints_Vector() {

		System.out.format("structParam.njt : %d%n", GModel.structParam.njt);
		System.out.format("structParam.nr : %d%n", GModel.structParam.nr);
		n3 = 3 * GModel.structParam.njt; // From Number of Joints
		nn = n3 - GModel.structParam.nr; // From Number of Restraints

		// System.out.println("<Fill_Restrained_Joints_Vector ...>");
		for (global_i = baseIndex; global_i < GModel.structParam.nrj; global_i++) {
			// With sup_grp[global_i]
			j3 = (3 * GModel.sup_grp[global_i].js) - 1;
			rjl[j3 - 2] = GModel.sup_grp[global_i].rx;
			rjl[j3 - 1] = GModel.sup_grp[global_i].ry;
			rjl[j3] = GModel.sup_grp[global_i].rm;
			// System.out.println( j3.ToString() + ": rjl.. " + rjl[j3 - 2] +
			// "," + rjl[j3 - 1] + "," + rjl[j3]);
			// EndWith
		} // next i

		crl[ndx1] = rjl[ndx1];
		// System.out.println( ndx1.ToString() + ": crl.. ", crl[ndx1]);
		for (global_i = ndx1 + 1; global_i < n3; global_i++) {
			crl[global_i] = crl[global_i - 1] + rjl[global_i];
			// System.out.println( global_i.ToString() + ": crl.. ",
			// crl[global_i]);
		} // next i

		// System.out.println("Fill_Restrained_Joints_Vector n3, nn, nr .. ",
		// n3, nn, structParam.nr);

	} // .. Fill_Restrained_Joints_Vector ..

	// -----------------------------------------------------------------------------
	// << Check_J >>
	public boolean End_J() // boolean
	{
		boolean tmp;

		// System.out.println("End_J ...");
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

	} // End public void //.. End_J ..

	// << End_K >>
	public boolean End_K() // boolean
	{
		boolean tmp;

		// System.out.println("End_K ...");
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

	} // End public void //.. End_K ..

	// << Calc_Bandwidth >>
	public void Calc_Bandwidth() {

		System.out.println("<Calc_Bandwidth ...>");
		hbw = 0;
		diff = 0;
		for (global_i = baseIndex; global_i < GModel.structParam.nmb; global_i++) {
			// With con_grp[global_i]
			j3 = (3 * GModel.con_grp[global_i].jj) - 1;
			j2 = j3 - 1;
			j1 = j2 - 1;

			k3 = (3 * GModel.con_grp[global_i].jk) - 1;
			k2 = k3 - 1;
			k1 = k2 - 1;

			if (!End_J()) {
				// System.out.println("BandWidth: Step:1");
				if (!End_K()) {
					// System.out.println("BandWidth: Step:2");
					diff = Translate_Ndx(global_k) - Translate_Ndx(global_j)
							+ 1;
					// System.out.println("BandWidth: Step:3 : " +
					// diff.ToString());
				} // End If [
			} // End If [

			if (diff > hbw) {
				// System.out.println("BandWidth: Step:4");
				hbw = diff;
				// System.out.println("BandWidth: Step:5 : " + hbw.ToString());
			} // End If [

			// EndWith
		} // next i

		// System.out.println("Calc_Bandwidth hbw, nn .. ", hbw, nn);

	} // .. Calc_Bandwidth ..
		// -----------------------------------------------------------------------------

	// << Get_Stiff_Elements >>
	// Calculate the Stiffness of Structural Element
	public void Get_Stiff_Elements(int i) // Byte)
	{
		int flag; // Byte
		int msect; // Byte
		int mnum; // Byte
		double eiol; // Double EI/L

		System.out.println("Get_Stiff_Elements ...");
		// With con_grp[i]
		msect = getArrayIndex(GModel.con_grp[i].sect); // Section ID/key
														// converted to array
														// index
		mnum = getArrayIndex(GModel.sec_grp[msect].mat); // Material ID/key
															// converted to
															// array index

		flag = GModel.con_grp[i].rel_i + GModel.con_grp[i].rel_j; // Sum
																	// releases
																	// each end
																	// of member
		eiol = GModel.mat_grp[mnum].emod * GModel.sec_grp[msect].iz / mlen[i]; // Calculate
																				// EI/L

		// System.out.println("eiol: " + eiol.ToString());
		// System.out.println("mlen[i]: " + mlen[i].ToString());

		// .. initialise temp variables ..
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
			if (GModel.con_grp[i].rel_i == 0) {
				ai = 3 * eiol;
			} else {
				aj = 3 * eiol;
			} // End If
			break;

		} // End Select

		ci = (ai + ao2) / mlen[i];
		cj = (aj + ao2) / mlen[i];
		ccl = (ci + cj) / mlen[i];
		eaol = GModel.mat_grp[mnum].emod * GModel.sec_grp[msect].ax / mlen[i];

		// EndWith

		cosa = rot_mat[i][ndx1];
		sina = rot_mat[i][ndx2];
	} // .. Get_Stiff_Elements ..

	// << Assemble_Stiff_Mat >>
	// Assemble
	public void Assemble_Stiff_Mat(int i) // Byte
	{

		System.out.println("Assemble_Stiff_Mat ...");
		Get_Stiff_Elements(i);

		System.out.format("eaol: %15.4f%n", eaol);
		System.out.format("cosa: %15.4f%n", cosa);
		System.out.format("sina: %15.4f%n", sina);
		System.out.format("ccl: %15.4f%n", ccl);
		System.out.format("ci: %15.4f%n", ci);
		System.out.format("cj: %15.4f%n", cj);
		System.out.format("ai: %15.4f%n", ai);
		System.out.format("ao2: %15.4f%n", ao2);
		System.out.format("aj: %15.4f%n", aj);

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

		// // PrintMat("Assemble_Stiff_Mat   s () ..", s, dd(), 6, 6)
	} // .. Assemble_Stiff_Mat ..

	// << Assemble_Global_Stiff_Matrix >>
	// Assemble Member Stiffness Matrix
	public void Assemble_Global_Stiff_Matrix(int i) // Byte)
	{

		System.out.println("<Assemble_Global_Stiff_Matrix ...>");

		Get_Stiff_Elements(i);

		c2 = cosa * cosa;
		s2 = sina * sina;
		cs = cosa * sina;

		// System.out.println("eaol :" + eaol.ToString());
		// System.out.println("cosa :" + cosa.ToString());
		// System.out.println("sina :" + sina.ToString());

		// System.out.println("c2 :" + c2.ToString());
		// System.out.println("s2 :" + s2.ToString());
		// System.out.println("cs :" + cs.ToString());
		// System.out.println("ccl :" + ccl.ToString());
		// System.out.println("ci :" + ci.ToString());
		// System.out.println("cj :" + cj.ToString());
		// System.out.println("ai :" + ai.ToString());
		// System.out.println("ao2 :" + ao2.ToString());
		// System.out.println("aj :" + aj.ToString());
		// System.out.println("-----------------------");

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

		System.out.println("<... Assemble_Global_Stiff_Matrix >");

		// // PrintMat("Assemble_Global_Stiff_Matrix   s () ..", s, dd(), 6, 6)
	} // .. Assemble_Global_Stiff_Matrix ..

	// -----------------------------------------------------------------------------

	// << Load_Sj >>
	public void Load_Sj(int j, int kk, double stiffval) {

		System.out.format(">> Load_Sj ... %d %d %12.4f%n", j, kk, stiffval);
		global_k = Translate_Ndx(kk) - j;

		System.out.format("IN:sj[][]: %d %d %f%n", j, global_k, sj[j][global_k]);
		sj[j][global_k] = sj[j][global_k] + stiffval;
		System.out.format("OUT:sj[][]: %d %d %12.4f%n", j, global_k,
				sj[j][global_k]);
		System.out.println();

	} // .. Load_Sj ..

	// << Process_DOF_J1 >>
	public void Process_DOF_J1() {

		System.out.format("Process_DOF_J1 ... %d%n", j1);

		// Process J1
		global_j = Translate_Ndx(j1);
		sj[global_j][df1] = sj[global_j][df1] + s[df1][df1];
		System.out.format("OUT:sj[][]: %d %d %12.4f%n", global_j, df1,
				sj[global_j][df1]);

		// Cascade Influence of J1 down through J2,J3,K1,K2,K3
		if (rjl[j2] == 0) {
			sj[global_j][df2] = sj[global_j][df2] + s[df1][df2];
			System.out.format("OUT:sj[][]: %d %d %12.4f%n", global_j, df2,
					sj[global_j][df2]);
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
	} // .. Process_DOF_J1 ..

	// << Process_DOF_J2 >>
	public void Process_DOF_J2() {

		System.out.format("Process_DOF_J2 ... %d%n", j2);

		// Process J2
		global_j = Translate_Ndx(j2);
		sj[global_j][df1] = sj[global_j][df1] + s[df2][df2];
		System.out.format("OUT:sj[][]: %d %d %12.4f%n", global_j, df1,
				sj[global_j][df1]);

		// Cascade influence of J2 through J3, K1, K2, K3
		if (rjl[j3] == 0) {
			sj[global_j][df2] = sj[global_j][df2] + s[df2][df3];
			System.out.format("OUT:sj[][]: %d %d %15.4f%n", global_j, df2,
					sj[global_j][df2]);
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
	} // .. Process_DOF_J2 ..

	// << Process_DOF_J3 >>
	public void Process_DOF_J3() {

		System.out.format("Process_DOF_J3 ... %d%n", j3);

		// Process J3
		global_j = Translate_Ndx(j3);
		sj[global_j][df1] = sj[global_j][df1] + s[df3][df3];
		System.out.format("OUT:sj[][]: %d %d %12.4f%n", global_j, df1,
				sj[global_j][df1]);

		// Cascade influence J3 through K1, K2, K3
		if (rjl[k1] == 0) {
			Load_Sj(global_j, k1, s[df3][df4]);
		}
		if (rjl[k2] == 0) {
			Load_Sj(global_j, k2, s[df3][df5]);
		}
		if (rjl[k3] == 0) {
			Load_Sj(global_j, k3, s[df3][df6]);
		}
	} // .. Process_DOF_J3 ..

	// << Process_DOF_K1 >>
	public void Process_DOF_K1() {

		System.out.format("Process_DOF_K1 ... %d%n", k1);

		// Process K1
		global_j = Translate_Ndx(k1);
		sj[global_j][df1] = sj[global_j][df1] + s[df4][df4];
		System.out.format("OUT:sj[][]: %d %d %12.4f%n", global_j, df1,
				sj[global_j][df1]);

		// Cascade influence K1 through K2, K3
		if (rjl[k2] == 0) {

			System.out.format("IN:sj[][]: %d %d %15.3f%n", global_j, df2,
					sj[global_j][df2]);
			System.out.format("IN:s[][]: %d %d %15.4f%n", df4, df5, s[df4][df5]);

			sj[global_j][df2] = sj[global_j][df2] + s[df4][df5];

			System.out.format("OUT:sj[][]: %d %d %15.4f%n", global_j, df2,
					sj[global_j][df2]);
		}

		if (rjl[k3] == 0) {
			Load_Sj(global_j, k3, s[df4][df6]);
		}
	} // .. Process_DOF_K1 ..

	// << Process_DOF_K2 >>
	public void Process_DOF_K2() {

		System.out.format("Process_DOF_K2 ... %d%n", k2);

		// Process K2
		global_j = Translate_Ndx(k2);
		sj[global_j][df1] = sj[global_j][df1] + s[df5][df5];

		System.out.format("OUT:sj[][]: %d %d $15.4f%n", global_j, df1,
				sj[global_j][df1]);

		// Cascade influence K2 through K3
		if (rjl[k3] == 0) {

			System.out.format("IN:sj[][]:  %d %d $15.4f%n", global_j, df2,
					sj[global_j][df2]);
			System.out.format("IN:s[][]:  %d %d $15.4f%n", df5, df6, s[df5][df6]);

			sj[global_j][df2] = sj[global_j][df2] + s[df5][df6];

			System.out.format("OUT:sj[][]: %d %d $15.4f%n", global_j, df2,
					sj[global_j][df2]);
		}
	} // .. Process_DOF_K2 ..

	// << Process_DOF_K3 >>
	public void Process_DOF_K3() {
		System.out.format("Process_DOF_K3 ... %d%n", k3);
		global_j = Translate_Ndx(k3);

		// Process K3
		System.out.format("IN:sj[][]:  %d %d $15.4f%n", global_j, df1,
				sj[global_j][df1]);
		System.out.format("IN:s[][]:  %d %d $15.4f%n", df6, df6, s[df6][df6]);

		sj[global_j][df1] = sj[global_j][df1] + s[df6][df6];

		System.out.format("OUT:sj[][]:  %d %d $15.4f%n", global_j, df1,
				sj[global_j][df1]);
		System.out.println();

	} // .. Process_DOF_K3 ..

	// << Assemble_Struct_Stiff_Matrix >>
	public void Assemble_Struct_Stiff_Matrix(int i) // Byte)
	{
		// .. initialise temp variables ..

		System.out.format("<Assemble_Struct_Stiff_Matrix ...> %d%n", i);
		j3 = (3 * GModel.con_grp[i].jj) - 1;
		j2 = j3 - 1;
		j1 = j2 - 1;

		k3 = (3 * GModel.con_grp[i].jk) - 1;
		k2 = k3 - 1;
		k1 = k2 - 1;

		System.out.format("J: %d %d %d%n", j3, j2, j1);
		System.out.format("K: %d %d %d%n", k3, k2, k1);

		// Process End A

		if (rjl[j3] == 0) {
			Process_DOF_J3();
		} // .. do j3 ..

		if (rjl[j2] == 0) {
			Process_DOF_J2();
		} // .. do j2 ..

		if (rjl[j1] == 0) {
			Process_DOF_J1();
		} // .. do j1 ..

		// Process End B

		if (rjl[k3] == 0) {
			Process_DOF_K3();
		} // .. do k3 ..

		if (rjl[k2] == 0) {
			Process_DOF_K2();
		} // .. do k2 ..

		if (rjl[k1] == 0) {
			Process_DOF_K1();
		} // .. do k1 ..

		System.out.format("<... Assemble_Struct_Stiff_Matrix > %d%n", i);

	} // .. Assemble_Struct_Stiff_Matrix ..

	// -----------------------------------------------------------------------------

	// << Calc_Member_Forces >>
	public void Calc_Member_Forces() {
		for (global_i = baseIndex; global_i < GModel.structParam.nmb; global_i++) {
			// With con_grp[global_i]

			System.out.format("<Calc_Member_Forces ...> %d%n", global_i);
			Assemble_Stiff_Mat(global_i);

			// .. initialise temporary end restraint indices ..
			j3 = 3 * GModel.con_grp[global_i].jj - 1;
			j2 = j3 - 1;
			j1 = j2 - 1;

			k3 = 3 * GModel.con_grp[global_i].jk - 1;
			k2 = k3 - 1;
			k1 = k2 - 1;

			for (global_j = baseIndex; global_j <= df6; global_j++) {
				ad[global_j] = s[global_j][df1] * dj[j1] + s[global_j][df2]
						* dj[j2] + s[global_j][df3] * dj[j3];
				ad[global_j] = ad[global_j] + s[global_j][df4] * dj[k1]
						+ s[global_j][df5] * dj[k2] + s[global_j][df6] * dj[k3];
			} // next j

			// .. Store End forces ..
			System.out.format("%d%n", global_i);
			GModel.con_grp[global_i].jnt_jj.axial = -(af[global_i][df1] + ad[df1]);
			GModel.con_grp[global_i].jnt_jj.shear = -(af[global_i][df2] + ad[df2]);
			GModel.con_grp[global_i].jnt_jj.momnt = -(af[global_i][df3] + ad[df3]);

			GModel.con_grp[global_i].jnt_jk.axial = af[global_i][df4] + ad[df4];
			GModel.con_grp[global_i].jnt_jk.shear = af[global_i][df5] + ad[df5];
			GModel.con_grp[global_i].jnt_jk.momnt = af[global_i][df6] + ad[df6];

			// .. Member Joint j End forces
			if (rjl[j1] != 0) {
				ar[j1] = ar[j1] + ad[df1] * cosa - ad[df2] * sina;
			} // .. Fx
			if (rjl[j2] != 0) {
				ar[j2] = ar[j2] + ad[df1] * sina + ad[df2] * cosa;
			} // .. Fy
			if (rjl[j3] != 0) {
				ar[j3] = ar[j3] + ad[df3];
			} // .. Mz

			// .. Member Joint k End forces
			if (rjl[k1] != 0) {
				ar[k1] = ar[k1] + ad[df4] * cosa - ad[df5] * sina;
			} // .. Fx
			if (rjl[k2] != 0) {
				ar[k2] = ar[k2] + ad[df4] * sina + ad[df5] * cosa;
			} // .. Fy
			if (rjl[k3] != 0) {
				ar[k3] = ar[k3] + ad[df6];
			} // .. Mz

			// EndWith
		} // next i
	} // .. Calc_Member_Forces ..

	// << Calc_Joint_Displacements >>
	public void Calc_Joint_Displacements() {

		System.out.println("<Calc_Joint_Displacements ...>");
		for (global_i = baseIndex; global_i < n3; global_i++) {
			if (rjl[global_i] == 0) {
				dj[global_i] = dd[Translate_Ndx(global_i)];
			}
		} // next i
	} // .. Calc_Joint_Displacements ..

	// << Get_Span_Moments >>
	public void Get_Span_Moments() {
		double seg, stn; // Double
		double rx; // Double
		double mx; // Double
		int i, j; // Byte

		System.out.println("<Get_Span_Moments ...>");
		// .. Get_Span_Moments ..
		for (i = baseIndex; i < GModel.structParam.nmb; i++) {
			seg = mlen[i] / n_segs;
			if (poslope) {
				rx = GModel.con_grp[i].jnt_jj.shear;
				mx = GModel.con_grp[i].jnt_jj.momnt;
			} else {
				rx = GModel.con_grp[i].jnt_jk.shear;
				mx = GModel.con_grp[i].jnt_jk.momnt;
			} // End If [

			// With con_grp[i]
			for (j = startZero; j <= n_segs; j++) {
				stn = j * seg;
				// System.out.println(i,j,stn, mem_lod[i].mem_no);
				// With mem_lod[i]

				// if ((mem_lod[i].lcode == 2) && (stn >= mem_lod[i].start) &&
				// (stn - mem_lod[i].start < seg)) {
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
	} // .. Get_Span_Moments ..

	// End ////.. DoAnalysis Module ..
	// ===========================================================================

	// ===========================================================================
	// {###### Pf_Load.PAS ######
	// ... a unit file of load analysis routines for ( the Framework Program-
	// R G Harrison -- Version 5.2 -- 30/ 3/96 ...
	// Revision history //-
	// 29/7/90 - implemented ..
	// ===========================================================================

	
	
	// <<< In_Cover >>>
	public boolean In_Cover(double x1, double x2, double mlen) // boolean
	{
		System.out.println("In_Cover ...");
		System.out.format("%f %f %f%n", x1, x2, mlen);
		if ((x2 == mlen) || (x2 > mlen)) {
			return true;
		} else {
			return ((stn >= x1) && (stn <= x2));
		} // End If [
	} // End public void //...In_Cover...

	// << Calc_Moments >>
	// .. RGH 12/4/92
	// .. calc moments ..
	public void Calc_Moments(int mn, double mlen, double wtot, double x1,
			double la, double cv, int wty, double lslope) {
		double x; // Double
		double x2; // Double
		double Lx; // Double
		int idx1; // Integer

		System.out.format("Calc_Moments ... %d%n", mn);

		idx1 = mn - 1;
		x2 = x1 + cv;

		seg = mlen / n_segs;

		if (cv != 0) {
			w1 = wtot / cv;
		}

		for (global_j = startZero; global_j <= n_segs; global_j++) {
			stn = global_j * seg;

			if (poslope) {
				x = stn - x1; // .. dist ; i<= sect from stn X-X..
				Lx = stn - la;
			} else {
				x = x2 - stn;
				Lx = la - stn;
			} // End If [

			if (In_Cover(x1, x2, mlen)) {
				switch (wty) // .. calc moments if ( inside load cover..
				{
				case clsGeomModel.udl_ld:
					// Uniform Load
					mom_spn[idx1][global_j] = mom_spn[idx1][global_j] - w1 * x
							* x / 2;
					break;

				case clsGeomModel.tri_ld:
					// Triangular Loads
					mom_spn[idx1][global_j] = mom_spn[idx1][global_j]
							- (w1 * x * x / cv) * x / 3;
					break;

				} // End Select

			} else {
				if (x <= 0) {
					Lx = 0;
				} // End If [

				mom_spn[idx1][global_j] = mom_spn[idx1][global_j] - wtot * Lx;

			} // End If [

		} // next j
	} // .. Calc_Moments ..

	// << Combine_Joint_Loads >>
	public void Combine_Joint_Loads(int kMember) // Byte)
	{
		int k;

		k = kMember - 1;

		System.out.format("Combine_Joint_Loads ... %d%n", kMember);
		cosa = rot_mat[k][ndx1];
		sina = rot_mat[k][ndx2];
		System.out.format("cosa: %f%n", cosa);
		System.out.format("sina: %f%n", sina);

		// ... Process end A
		Get_Joint_Indices(GModel.con_grp[k].jj);
		System.out.format("fc[]: %f %f %f%n", fc[j1], fc[j2], fc[j3]);
		fc[j1] = fc[j1] - a_i * cosa + ri * sina; // .. Fx
		fc[j2] = fc[j2] - a_i * sina - ri * cosa; // .. Fy
		fc[j3] = fc[j3] - fi; // .. Mz
		System.out.format("fc[]: %f %f %f%n", fc[j1], fc[j2], fc[j3]);

		// ... Process end B
		Get_Joint_Indices(GModel.con_grp[k].jk);
		System.out.format("fc[]: %f %f %f%n", fc[j1], fc[j2], fc[j3]);
		fc[j1] = fc[j1] - a_j * cosa + rj * sina; // .. Fx
		fc[j2] = fc[j2] - a_j * sina - rj * cosa; // .. Fy
		fc[j3] = fc[j3] - fj; // .. Mz
		System.out.format("fc[]: %f %f %f%n", fc[j1], fc[j2], fc[j3]);

	} // .. Combine_Joint_Loads ..

	// << Calc_FE_Forces >>
	public void Calc_FE_Forces(int kMember, double la, double lb) {
		int k;

		k = kMember - 1;
		System.out.format("Calc_FE_Forces ... %d %n", k);
		// System.out.println(k);

		System.out.format("trl: %f%n", trl);
		System.out.format("djj: %f%n", djj);
		System.out.format("dii: %f%n", dii);

		// .. both ends fixed
		fi = (2 * djj - 4 * dii) / trl;
		fj = (4 * djj - 2 * dii) / trl;

		// With con_grp[k]
		flag = GModel.con_grp[k].rel_i + GModel.con_grp[k].rel_j;
		System.out.format("Flag: %d%n", flag);

		if (flag == 2) { // .. both ends pinned
			fi = 0;
			fj = 0;
		} // End If [

		if (flag == 1) { // .. propped cantilever
			if ((GModel.con_grp[k].rel_i == 0)) { // .. end i pinned
				fi = fi - fj / 2;
				fj = 0;
			} else { // .. end j pinned
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

	} // .. Calc_FE_Forces ..

	// << Accumulate_FE_Actions >>
	public void Accumulate_FE_Actions(int kMemberNum) // Byte)
	{
		int k;
		k = kMemberNum - 1;

		System.out.format("Accumulate_FE_Actions ... %d", kMemberNum);
		af[k][df1] = af[k][df1] + a_i;
		af[k][df2] = af[k][df2] + ri;
		af[k][df3] = af[k][df3] + fi;
		af[k][df4] = af[k][df4] + a_j;
		af[k][df5] = af[k][df5] + rj;
		af[k][df6] = af[k][df6] + fj;
	} // .. Accumulate_FE_Actions ..

	// << Process_FE_Actions >>
	public void Process_FE_Actions(int kMemberNum, double la, double lb) {
		System.out.format("Process_FE_Actions ... %d", kMemberNum);
		Accumulate_FE_Actions(kMemberNum);
		Combine_Joint_Loads(kMemberNum);
	} // .. Process_FE_Actions ..

	// << Do_Global_Load >>
	public void Do_Global_Load(int mem, int acd, double w0, double start) {
		System.out.println("Do_Global_Load ...");
		switch (acd) {
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

	} // .. Do_Global_Load ..

	// << Do_Axial_Load >>
	// .. Load type = "v" => #3
	public void Do_Axial_Load(int mno, double wu, double x1) {
		System.out.println("Do_Axial_Load ...");
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

	} // .. Do_Axial_Load ..

	// << Do_Self_Weight >>
	public void Do_Self_Weight(int mem) // Byte)
	{
		int msect; // Byte,
		int mat; // Byte
		int idxMem, idxMsect, idxMat;

		System.out.println("Do_Self_Weight ...");

		// Convert Member Number to Array Index
		idxMem = mem - 1;

		// Convert Section Number to Array Index
		msect = GModel.con_grp[idxMem].sect;
		idxMsect = msect - 1;

		// Convert Material Number to Array Index
		mat = GModel.sec_grp[idxMsect].mat;
		idxMat = mat - 1;

		udl = udl * GModel.mat_grp[idxMat].density
				* GModel.sec_grp[idxMsect].ax / clsGeomModel.kilo;
	} // .. Do_Self_Weight ..

	// << UDL_Slope >>
	public double UDL_Slope(double w0, double v, double c) // Double
	{
		System.out.println("UDL_Slope ...");
		return (w0 * v * (4 * (trl * trl - v * v) - c * c) / (24 * trl));
	} // End public void //.. UDL_Slope ..

	// << Do_Part_UDL >>
	// .. Load type = "u" => #1
	public void Do_Part_UDL(int mno, double wu, double x1, double cv, int wact) {
		double la;
		double lb; // Double

		la = x1 + cv / 2;
		lb = trl - la;

		System.out.format("Do_Part_UDL ... %d%n", mno);
		if (wact != clsGeomModel.local_act) {
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

		Calc_Moments(mno, trl, w_nrm, x1, la, cv, clsGeomModel.udl_ld,
				clsGeomModel.pos_slope); // .. Calculate the span moments
		Calc_FE_Forces(mno, la, lb);
		Process_FE_Actions(mno, la, lb);

		System.out.println("... Do_Part_UDL");

	} // .. Do_Part_UDL ..

	// << PL_Slope >>
	public double PL_Slope(double v) // Double) // Double
	{
		System.out.println("PL_Slope ...");
		return (w_nrm * v * (trl * trl - v * v) / (6 * trl));
	} // End public void //.. PL_Slope ..

	// << Do_Point_load >>
	// .. Load type = "p" => #2
	public void Do_Point_load(int mno, double wu, double x1, int wact) {

		System.out.println("Do_Point_load ...");
		la = x1;
		lb = trl - la;

		if (wact != clsGeomModel.local_act) {
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

		Calc_Moments(mno, trl, w_nrm, x1, la, 0, clsGeomModel.pnt_ld,
				clsGeomModel.pos_slope); // .. Calculate the span moments
		Calc_FE_Forces(mno, la, lb);
		Process_FE_Actions(mno, la, lb);

	} // .. Do_Point_load ..

	// << Tri_Slope >>
	public double Tri_Slope(double v, double w_nrm, double cv, double sl_switch) // Double
	{
		System.out.println("Tri_Slope ...");
		gam = cv / trl;
		v = v / trl;
		return (w_nrm
				* trl
				* trl
				* (270 * (v - v * v * v) - gam * gam
						* (45 * v + sl_switch * 2 * gam)) / 1620);
	} // End public void //.. Tri_Slope ..

	// << Do_Triangle >>
	// .. Load type =
	public void Do_Triangle(int mno, double w0, double la, double x1,
			double cv, int wact, int slopedir) {
		double lb; // Double

		System.out.println("Do_Triangle ...");
		lb = trl - la;

		if (wact != clsGeomModel.local_act) {
			Do_Global_Load(mno, wact, w0, x1);
			w_axi = axi_comp * cv / 2;
			Do_Axial_Load(mno, w_axi, la);
		} else {
			nrm_comp = w0;
			axi_comp = 0;
		} // End If [

		w_nrm = nrm_comp * cv / 2;

		dii = Tri_Slope(lb, w_nrm, cv, clsGeomModel.pos_slope * slopedir); // ..
																			// /!
																			// =>
																			// +ve
																			// when
																			// +ve
																			// slope
		djj = Tri_Slope(la, w_nrm, cv, clsGeomModel.neg_slope * slopedir); // ..
																			// !\
																			// =>
																			// +ve
																			// when
																			// -ve
																			// slope

		Calc_Moments(mno, trl, w_nrm, x1, la, cv, clsGeomModel.tri_ld, slopedir); // ..
																					// Calculate
																					// the
																					// span
																					// moments
		Calc_FE_Forces(mno, la, lb);
		Process_FE_Actions(mno, la, lb);

	} // .. Do_Triangle ..

	// << Do_Distributed_load >>
	// .. Load type = "v" => #1
	public void Do_Distributed_load(int mno, double wm1, double wm2, double x1,
			double cv, int lact) {
		double wudl; // Double,
		double wtri; // Double,
		int slope; // Double,
		double ltri; // Double

		System.out.format("Do_Distributed_load ... %d", mno);

		if (wm1 == wm2) { // .. load is a UDL
			Do_Part_UDL(mno, wm1, x1, cv, lact);
		} else {
			if (Math.abs(wm1) < Math.abs(wm2)) { // .. positive slope ie sloping
													// upwards / left ; i<=
													// right
				wudl = wm1;
				wtri = wm2 - wudl;
				slope = clsGeomModel.pos_slope;
				ltri = x1 + 2 * cv / 3;
			} else { // .. negative slope ie sloping upwards \ right ; i<= left
				wudl = wm2;
				wtri = wm1 - wudl;
				slope = clsGeomModel.neg_slope;
				ltri = x1 + cv / 3;
			} // End If [

			poslope = (slope == clsGeomModel.pos_slope);

			if (wudl != 0) {
				Do_Part_UDL(mno, wudl, x1, cv, lact);
			} // End If [

			if (wtri != 0) {
				Do_Triangle(mno, wtri, ltri, x1, cv, lact, slope);
			} // End If [

		} // End If [

		System.out.println("... Do_Distributed_load");

	} // .. Do_Distributed_load ..

	// << Get_FE_Forces >>
	public void Get_FE_Forces(int kMemberNum, int ldty, double wm1, double wm2,
			double x1, double cvr, int lact) {

		System.out.format("Get_FE_Forces ... %d", kMemberNum);
		switch (ldty) // .. Get_FE_Forces ..
		{
		case clsGeomModel.dst_ld:
			// .. "v" = #1
			Do_Distributed_load(kMemberNum, wm1, wm2, x1, cvr, lact);
			break;
		case clsGeomModel.pnt_ld:
			// .. "p" = #2
			Do_Point_load(kMemberNum, wm1, x1, lact);
			break;
		case clsGeomModel.axi_ld:
			// .. "a" = #3
			Do_Axial_Load(kMemberNum, wm1, x1);
			break;

		} // End Select

	} // .. Get_FE_Forces ..

	// << Process_Loadcases >>
	public void Process_Loadcases() {
		int idxMem;
		System.out.println();
		System.out.println("<Process_Loadcases ...>");
		if (GModel.structParam.njl != 0) {
			System.out.println("[Joint Loads]");
			System.out.format("nml = %d", GModel.structParam.njl);
			for (global_i = baseIndex; global_i < GModel.structParam.njl; global_i++) {
				// With jnt_lod[global_i]
				Get_Joint_Indices(GModel.jnt_lod[global_i].jt);

				fc[j1] = GModel.jnt_lod[global_i].fx;
				fc[j2] = GModel.jnt_lod[global_i].fy;
				fc[j3] = GModel.jnt_lod[global_i].mz;
				// EndWith
			} // next i
		} // End If [

		if (GModel.structParam.nml != 0) {
			System.out.println("[Member Loads]");
			System.out.format("nml = %d", GModel.structParam.nml);
			for (global_i = baseIndex; global_i < GModel.structParam.nml; global_i++) {
				// With mem_lod[global_i]
				System.out.format("i= %d", global_i);
				idxMem = GModel.mem_lod[global_i].mem_no - 1;
				System.out
						.format("mem_no= %d", GModel.mem_lod[global_i].mem_no);
				trl = mlen[idxMem];
				cosa = rot_mat[idxMem][ndx1]; // .. Cos
				sina = rot_mat[idxMem][ndx2]; // .. Sin
				ldc = GModel.mem_lod[global_i].lcode;
				wm1 = GModel.mem_lod[global_i].ld_mag1;
				wm2 = GModel.mem_lod[global_i].ld_mag2;
				cvr = GModel.mem_lod[global_i].cover;
				x1 = GModel.mem_lod[global_i].start;
				if ((ldc == clsGeomModel.dst_ld) && (cvr == 0)) {
					x1 = 0;
					cvr = trl;
				} // End If [
					// Pass Member Numbers, Convert to Index internally
				Get_FE_Forces(GModel.mem_lod[global_i].mem_no, ldc, wm1, wm2,
						GModel.mem_lod[global_i].start, cvr,
						GModel.mem_lod[global_i].f_action);
				try {
					fpTracer.write("FC[]: %d" + global_i);
					fprintVector(fc);
					fpTracer.newLine();
				} catch (IOException e) {
					// TODO Auto-generated catch block
					e.printStackTrace();
				}

				// EndWith
				System.out.println();

			} // next i
		} // End If [

		if (GModel.structParam.ngl != 0) {
			System.out.println("[Gravity Loads]");
			System.out.format("ngl = %d", GModel.structParam.ngl);
			for (global_i = baseIndex; global_i < GModel.structParam.nmb; global_i++) {
				// With grv_lod
				x1 = 0;
				trl = mlen[global_i];
				cvr = trl;
				cosa = rot_mat[global_i][ndx1];
				sina = rot_mat[global_i][ndx2];
				udl = GModel.grv_lod.load;
				ldc = clsGeomModel.dst_ld; // ud_ld //.. 1
				Do_Self_Weight(global_i);
				nrm_comp = udl;
				if (GModel.grv_lod.f_action != clsGeomModel.local_act) {
					Do_Global_Load(global_i, GModel.grv_lod.f_action, udl, 0);
				} // End If [
				Get_FE_Forces(global_i, clsGeomModel.dst_ld, nrm_comp,
						nrm_comp, x1, cvr, GModel.grv_lod.f_action);
				// EndWith
			} // next i
		} // End If [
	} // .. Process_Loadcases ..

	// End ////.. DoLoads Module ..
	// ===========================================================================

	// << Zero_Vars >>
	public void Zero_Vars() {
		int i, j;

		System.out.println("Zero_Vars ...");

		// GModel.initialise();

		// Erase mlen; // Each element set ; i<= 0.
		for (i = 0; i < v_size; i++) {
			mlen[i] = 0;
		}

		// Erase ad;
		for (i = 0; i < v_size; i++) {
			ad[i] = 0;
		}

		// Erase fc;
		for (i = 0; i < v_size; i++) {
			fc[i] = 0;
		}

		// Erase ar;
		for (i = 0; i < v_size; i++) {
			ar[i] = 0;
		}

		// Erase dj;
		for (i = 0; i < v_size; i++) {
			dj[i] = 0;
		}

		// Erase dd;
		for (i = 0; i < v_size; i++) {
			dd[i] = 0;
		}

		// Erase rjl;
		for (i = 0; i < v_size; i++) {
			rjl[i] = 0;
		}

		// Erase crl;
		for (i = 0; i < v_size; i++) {
			crl[i] = 0;
		}

		// Erase rot_mat;
		for (i = 0; i < v_size; i++) {
			for (j = 0; j < 2; j++)
				rot_mat[i][j] = 0;
		}

		for (i = 0; i < order; i++) {
			for (j = 0; j < v_size; j++)
				af[i][j] = 0;
		}

		// Erase sj;
		for (i = 0; i < order; i++) {
			for (j = 0; j < v_size; j++)
				sj[i][j] = 0;
		}

		for (i = 0; i < order; i++) {
			for (j = 0; j < v_size; j++)
				s[i][j] = 0;
		}

		for (i = 0; i < max_grps; i++) {
			for (j = 0; j < (n_segs + 1); j++)
				mom_spn[i][j] = 0;
		}

	} // .. Zero_Vars ..

	// << Initialise >>
	public void Initialise() {
		System.out.println("<Initialise ...>");
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

	} // .. Initialise ..

	// << Translate_Ndx >>
	// .. Restrained joint index
	public int Translate_Ndx(int i) // Byte) // Integer
	{
		// System.out.println("Translate_Ndx ...",i);
		return (i - crl[i]);
	} // End public void //.. Translate_Ndx ..

	// << Equiv_Ndx >>
	// ..equivalent matrix configuration joint index numbers
	public int Equiv_Ndx(int j) // Integer
	{
		// System.out.println("Equiv_Ndx ...",j);
		return (rjl[j] * (nn + crl[j]) + (1 - rjl[j]) * Translate_Ndx(j));
	} // End public void //.. Equiv_Ndx ..

	// << Get_Joint_Indices >>
	// .. get equivalent matrix index numbers
	public void Get_Joint_Indices(int nd) // Byte)
	{
		System.out.format("Get_Joint_Indices ... %d", nd);
		j0 = (3 * nd) - 1;
		j3 = Equiv_Ndx(j0);
		j2 = j3 - 1;
		j1 = j2 - 1;

		System.out.format("%d %d %d %d", j0, j1, j2, j3);

	} // .. Get_Joint_Indices ..

	// << Get_Direction_Cosines >>
	public void Get_Direction_Cosines() {
		int i; // Byte
		int tmp; // Byte
		int rel_tmp; // Byte
		double xm; // Double
		double ym; // Double

		System.out.println("Get_Direction_Cosines ...");
		for (i = baseIndex; i < GModel.structParam.nmb; i++) {
			// With con_grp[i]
			// System.out.println( i.ToString() + ": " +
			// con_grp[i].jj.ToString() + " , " + con_grp[i].jk.ToString())

			// Swap node subscripts so that near end subscript (jj) is smaller
			// than far end subscript (jk)
			if (GModel.con_grp[i].jk < GModel.con_grp[i].jj) { // .. swap end1
																// with end2 if
																// smaller !! ..
				tmp = GModel.con_grp[i].jj;
				GModel.con_grp[i].jj = GModel.con_grp[i].jk;
				GModel.con_grp[i].jk = tmp;

				rel_tmp = GModel.con_grp[i].rel_j;
				GModel.con_grp[i].rel_j = GModel.con_grp[i].rel_i;
				GModel.con_grp[i].rel_i = rel_tmp;
			} // End If

			// Calculate deltaX and deltaY
			xm = GModel.nod_grp[getArrayIndex(GModel.con_grp[i].jk)].x
					- GModel.nod_grp[getArrayIndex(GModel.con_grp[i].jj)].x;
			ym = GModel.nod_grp[getArrayIndex(GModel.con_grp[i].jk)].y
					- GModel.nod_grp[getArrayIndex(GModel.con_grp[i].jj)].y;
			// Calculate length of Member
			mlen[i] = Math.sqrt(xm * xm + ym * ym);

			// System.out.println( i.ToString() + ": mlen[i]: " +
			// mlen[i].ToString());

			// rot_mat[i] = new Array();
			// Determine Direction Cosines : Unit Direction Vector for member
			rot_mat[i][ndx1] = xm / mlen[i]; // .. Cos
			rot_mat[i][ndx2] = ym / mlen[i]; // .. Sin

			// EndWith
		} // next i

		System.out.println("... Get_Direction_Cosines");

	} // .. Get_Direction_Cosines ..

	// << Total_Section_Mass >>
	public void Total_Section_Mass() {
		int i; // Integer

		System.out.println("Total_Section_Mass ...");
		for (i = baseIndex; i < GModel.structParam.nsg; i++) {
			// With mat_grp[sec_grp[i].mat]
			GModel.sec_grp[i].t_mass = GModel.sec_grp[i].ax
					* GModel.mat_grp[getArrayIndex(GModel.sec_grp[i].mat)].density
					* GModel.sec_grp[i].t_len;
			// System.out.println(getArrayIndex(sec_grp[i].mat));
			// System.out.println(mat_grp[getArrayIndex(sec_grp[i].mat)].density);
			// System.out.println(i.ToString() + ": " +
			// sec_grp[i].t_mass.ToString());
			// EndWith
		} // next i
	} // .. Total_Section_Mass ..

	// << Total_Section_Length >>
	// Total length of all members of a given Section.
	public void Total_Section_Length() {
		int ndx;

		System.out.println("<Total_Section_Length>");
		for (global_i = baseIndex; global_i < GModel.structParam.nmb; global_i++) {
			// With con_grp[global_i]
			ndx = getArrayIndex(GModel.con_grp[global_i].sect);
			// System.out.println(ndx.ToString() + ": " +
			// mlen[global_i].ToString());
			GModel.sec_grp[ndx].t_len = GModel.sec_grp[ndx].t_len
					+ mlen[global_i];
			// System.out.println(sec_grp[ndx].t_len.ToString());
			// EndWith
		} // next i
		Total_Section_Mass();
	} // .. Total_Section_Length ..

	// << Get_Min_Max >>
	// ..find critical End forces ..
	public void Get_Min_Max() {

		System.out.println("<Get_Min_Max ...>");
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

		for (global_i = baseIndex; global_i < GModel.structParam.nmb; global_i++) {

			// With con_grp[global_i]

			// .. End moments ..
			if (maxM < GModel.con_grp[global_i].jnt_jj.momnt) {
				maxM = GModel.con_grp[global_i].jnt_jj.momnt;
				MaxMJnt = GModel.con_grp[global_i].jj;
				maxMmemb = global_i;
			} // End If [

			if (maxM < GModel.con_grp[global_i].jnt_jk.momnt) {
				maxM = GModel.con_grp[global_i].jnt_jk.momnt;
				MaxMJnt = GModel.con_grp[global_i].jk;
				maxMmemb = global_i;
			} // End If [

			if (MinM > GModel.con_grp[global_i].jnt_jj.momnt) {
				MinM = GModel.con_grp[global_i].jnt_jj.momnt;
				MinMJnt = GModel.con_grp[global_i].jj;
				MinMmemb = global_i;
			} // End If [

			if (MinM > GModel.con_grp[global_i].jnt_jk.momnt) {
				MinM = GModel.con_grp[global_i].jnt_jk.momnt;
				MinMJnt = GModel.con_grp[global_i].jk;
				MinMmemb = global_i;
			} // End If [

			// .. End axials ..
			if (maxA < GModel.con_grp[global_i].jnt_jj.axial) {
				maxA = GModel.con_grp[global_i].jnt_jj.axial;
				MaxAJnt = GModel.con_grp[global_i].jj;
				maxAmemb = global_i;
			} // End If [

			if (maxA < GModel.con_grp[global_i].jnt_jk.axial) {
				maxA = GModel.con_grp[global_i].jnt_jk.axial;
				MaxAJnt = GModel.con_grp[global_i].jk;
				maxAmemb = global_i;
			} // End If [

			if (MinA > GModel.con_grp[global_i].jnt_jj.axial) {
				MinA = GModel.con_grp[global_i].jnt_jj.axial;
				MinAJnt = GModel.con_grp[global_i].jj;
				MinAmemb = global_i;
			} // End If [

			if (MinA > GModel.con_grp[global_i].jnt_jk.axial) {
				MinA = GModel.con_grp[global_i].jnt_jk.axial;
				MinAJnt = GModel.con_grp[global_i].jk;
				MinAmemb = global_i;
			} // End If [

			// .. End shears..
			if (maxQ < GModel.con_grp[global_i].jnt_jj.shear) {
				maxQ = GModel.con_grp[global_i].jnt_jj.shear;
				MaxQJnt = GModel.con_grp[global_i].jj;
				maxQmemb = global_i;
			} // End If [

			if (maxQ < GModel.con_grp[global_i].jnt_jk.shear) {
				maxQ = GModel.con_grp[global_i].jnt_jk.shear;
				MaxQJnt = GModel.con_grp[global_i].jk;
				maxQmemb = global_i;
			} // End If [

			if (MinQ > GModel.con_grp[global_i].jnt_jj.shear) {
				MinQ = GModel.con_grp[global_i].jnt_jj.shear;
				MinQJnt = GModel.con_grp[global_i].jj;
				MinQmemb = global_i;
			} // End If [

			if (MinQ > GModel.con_grp[global_i].jnt_jk.shear) {
				MinQ = GModel.con_grp[global_i].jnt_jk.shear;
				MinQJnt = GModel.con_grp[global_i].jk;
				MinQmemb = global_i;
			} // End If [

			// EndWith
		} // next i
	} // {.. Get_Min_Max ..}

	public void TraceRotMat() {
		double stmp;
		int i, j;

		try {
			fpTracer.write("rot_mat[i,j] ... ");
			for (i = 0; i < v_size; i++) {
				for (j = 0; j < 2; j++) {
					stmp = rot_mat[i][j];
					fpTracer.write(String.format("%f", stmp));
				}
				fpTracer.newLine();
			}

		} catch (IOException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		}

	}

	public void Trace_s() {
		double stmp;
		int i, j;

		try {
			fpTracer.write("s[i,j] ... ");
			for (i = df1; i < df6 + 1; i++) {
				for (j = df1; j < df6 + 1; j++) {
					stmp = s[i][j];
					fpTracer.write(String.format("%f", stmp));
				}
				fpTracer.newLine();
			}

		} catch (IOException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		}

	}

	public void Trace_sj() {
		double stmp;
		int i, j;

		System.out.println("Trace_sj ...");
		try {
			fpTracer.write("sj[i,j] ... ");
			for (i = startIndex; i < order; i++) {
				for (j = startIndex; j < v_size; j++) {

					stmp = sj[i][j];
					fpTracer.write(String.format("%f", stmp));
				}
				fpTracer.newLine();
			}

		} catch (IOException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		}

		System.out.println("... Trace_sj");
	}

	// << Analyse_Frame >>
	public void Analyse_Frame() {

		int i;

		// Get definition of the Plane Frame ; i<= Analyse

		// Set MiWrkBk = ActiveWorkbook
		System.out.println(">>> Analysis of Frame Started <<<");
		// Erase sec_grp
		// Jotter
		// GetData

		// All Data required for analysis to be loaded into arrays
		// before calling this procedure.

		// Define Global/Public Variables and Initialise
		Initialise();

		// BEGIN PLANE FRAME ANALYSIS

		try {
			Fill_Restrained_Joints_Vector();
			fpTracer.write("rjl");
			fprintVector(rjl);

			fpTracer.newLine();
			fpTracer.write("crl");
			fprintVector(crl);

			Total_Section_Length();

			// Calculate Bandwidth
			Calc_Bandwidth();
			fpTracer.newLine();
			fpTracer.write(String.format("hbw: %d", hbw));
			fpTracer.write(String.format("nn: %d", nn));

			// Assemble Stiffness Matrix
			System.out.println();
			System.out.println(">>> Assemble_Global_Stiff_Matrix <<<");
			for (i = baseIndex; i < GModel.structParam.nmb; i++) {
				Assemble_Global_Stiff_Matrix(i);
				// Trace_s();
				fpTracer.write("S[]: ");
				fpTracer.write(i);
				fprintMatrix(s);

				System.out.println();
				Assemble_Struct_Stiff_Matrix(i);
				// Trace_sj();
				fpTracer.write("SJ[]: ");
				fpTracer.write(i);
				fprintMatrix(sj);
				System.out.println();

			} // next i

			// Trace Calculations
			// TraceRotMat();
			// END Trace

			// Decompose Stiffness Matrix
			fpTracer.write("Choleski_Decomposition ... ");
			Choleski_Decomposition(sj, nn, hbw);
			fpTracer.write("Result: SJ[]: ");
			fprintMatrix(sj);
			fpTracer.newLine();

			// Fixed End Forces & Combined Joint Loads
			Process_Loadcases();
			fpTracer.write("FC[]: Result: ");
			fprintVector(fc);
			fpTracer.newLine();

			fpTracer.write("AF[]: ");
			fprintMatrix(af);
			fpTracer.newLine();

			// Solve Joint Displacements
			Solve_Displacements();
			fpTracer.write("DD[]: ");
			fprintVector(dd);
			fpTracer.newLine();

			Calc_Joint_Displacements();
			fpTracer.write("DJ[]: ");
			fprintVector(dj);

			// Calculate Member Forces
			Calc_Member_Forces();

			// cprint();

			Get_Span_Moments();
			Get_Min_Max();

			// END OF PLANEFRAME ANALYSIS

			// Do something with the results of the analysis
			// PrintResults();
			// TestDesignCADD2
		} catch (IOException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		}

		System.out.println("*** Analysis Completed *** ");

	} // .. Analyse_Frame ..

	// ===========================================================================
	// REPORTING
	// ===========================================================================

	// <<< PrtDeltas >>>
	public void fprintDeltas(int r, int c) {
		String txt1, txt2, txt3, txt4;
		int idx1, idx2, idx3;

		System.out.println("fprintDeltas ...");
		try {
			fpRpt.write("fprintDeltas ...\n");
			for (global_i = baseIndex + 1; global_i <= GModel.structParam.njt; global_i++) {
				txt1 = String.format("%4d", global_i);

				idx1 = 3 * global_i - 3;
				idx2 = 3 * global_i - 2;
				idx3 = 3 * global_i - 1;

				txt2 = String.format("%15.4f", (-dj[idx1]));
				txt3 = String.format("%15.4f", (-dj[idx2]));
				txt4 = String.format("%15.5f", (-dj[idx3]));

				fpRpt.write(txt1 + " " + txt2 + " " + txt3 + " " + txt4);
				fpRpt.newLine();
				// fpRpt.WriteLine("{0,4:0} {1,8:0.0000} {2,8:0.0000} {3,8:0.00000}",
				// global_i, -dj[idx1], -dj[idx2], -dj[idx3]);

				r = r + 1;
			} // next i

			fpRpt.newLine();

		} catch (IOException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		}

		System.out.println("... fprintDeltas");
	} // ...PrtDeltas

	// <<< PrtEndForces >>>
	public void fprintEndForces(int r, int c) {
		String txt0, txt1, txt2, txt3, txt4, txt5;
		String txt6, txt7, txt8, txt9, txt;
		// String tmp;
		int i;

		System.out.println("fprintEndForces ...");
		try {
			fpRpt.write("fprintEndForces ...\n");
			for (i = baseIndex; i < GModel.structParam.nmb; i++) {
				// With con_grp(i)
				txt0 = String.format("%8d", i);
				txt1 = String.format("%12.3f", mlen[i]);

				txt2 = String.format("%8d", GModel.con_grp[i].jj);
				txt3 = String.format("%12.3f", GModel.con_grp[i].jnt_jj.axial);
				txt4 = String.format("%12.3f", GModel.con_grp[i].jnt_jj.shear);
				txt5 = String.format("%12.3f", GModel.con_grp[i].jnt_jj.momnt);

				txt6 = String.format("%8d", GModel.con_grp[i].jk);
				txt7 = String.format("%12.3f", GModel.con_grp[i].jnt_jk.axial);
				txt8 = String.format("%12.3f", GModel.con_grp[i].jnt_jk.shear);
				txt9 = String.format("%12.3f", GModel.con_grp[i].jnt_jk.momnt);

				txt = txt0 + " " + txt1 + " " + txt2 + " " + txt3 + " " + txt4
						+ " " + txt5;
				txt = txt + " " + txt6 + " " + txt7 + " " + txt8 + " " + txt9;
				fpRpt.write(txt);
				fpRpt.newLine();
				// } With
				r = r + 1;
			} // next i

			fpRpt.newLine();

		} catch (IOException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		}

		System.out.println("... fprintEndForces");
	} // ...PrtEndForces

	// << Prt_Reaction_Sum >>
	public void fprintReaction_Sum(int r, int c) {
		String txt0, txt1;

		try {
			fpRpt.write("fprintReaction_Sum ...\n");
			txt0 = String.format("%15.4f", sumx);
			txt1 = String.format("%15.4f", sumy);
			fpRpt.write(txt0 + " " + txt1);
			fpRpt.newLine();
		} catch (IOException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		}

	} // .. Prt_Reaction_Sum ..

	// <<< PrtReactions >>>
	public void fprintReactions(int row1, int col1) {
		int i, k, k3, c, r;
		String txt0, txt1, txt2;

		System.out.println("fprintReactions ...");
		try {
			fpRpt.write("fprintReactions ...\n");
			for (k = baseIndex; k < n3; k++) {
				if (rjl[k] == 1) {
					ar[k] = ar[k] - fc[Equiv_Ndx(k)];
				}
			} // next k
			sumx = 0;
			sumy = 0;

			r = row1;
			for (i = baseIndex; i < GModel.structParam.nrj; i++) {
				c = col1 + 1;
				// With sup_grp(i)
				txt0 = String.format("%6d", GModel.sup_grp[i].js);
				flag = 0;
				c = c + 1;
				k3 = 3 * GModel.sup_grp[i].js - 1;
				for (k = k3 - 2; k <= k3; k++) {
					if ((k + 1) % 3 == 0) {
						txt1 = String.format("%15.3f", ar[k]);
						try {
							fpRpt.write(txt1);
						} catch (IOException e) {
							// TODO Auto-generated catch block
							e.printStackTrace();
						}
					} else {
						txt2 = String.format("%15.3f", ar[k]);
						fpRpt.write(txt2);
						if (flag == 0) {
							sumx = sumx + ar[k];
						} else {
							sumy = sumy + ar[k];
						}
						flag = flag + 1;
					}
					c = c + 1;
				} // next k
				flag = 0;

				fpRpt.newLine();
				r = r + 1;
				// With
			} // next i

			fprintReaction_Sum(row1 - 5, col1 + 1);

			fpRpt.newLine();

		} catch (IOException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		}

		System.out.println("... fprintReactions");

	} // ...PrtReactions

	// << Prt_Controls >>
	public void fprintControls(int r, int c) {
		String txt1, txt2, txt3, txt4, txt5;
		String txt6, txt7, txt8, txt9, txt;
		// int i;

		System.out.println("fprintControls ...");
		try {
			fpRpt.write("fprintControls ...\n");
			txt1 = String.format("%6d", GModel.structParam.njt);
			txt2 = String.format("%6d", GModel.structParam.nmb);
			txt3 = String.format("%6d", GModel.structParam.nmg);
			txt4 = String.format("%6d", GModel.structParam.nsg);
			txt5 = String.format("%6d", GModel.structParam.nrj);
			txt6 = String.format("%6d", GModel.structParam.njl);
			txt7 = String.format("%6d", GModel.structParam.nml);
			txt8 = String.format("%6d", GModel.structParam.ngl);
			txt9 = String.format("%6d", GModel.structParam.nr);

			txt = txt1 + " " + txt2 + " " + txt3 + " " + txt4 + " " + txt5;
			txt = txt + " " + txt6 + " " + txt7 + " " + txt8 + " " + txt9;
			fpRpt.write(txt);
			fpRpt.newLine();

		} catch (IOException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		}

	} // .. Prt_Controls ..

	// <<< Prt_Section_Details >>>
	public void fprintSection_Details(int r, int c) {
		String txt0, txt1, txt2, txt3, txt4;
		String txt;
		int i;

		System.out.println("fprintSection_Details ...");
		try {
			fpRpt.write("fprintSection_Details ...\n");
			for (i = baseIndex; i < GModel.structParam.nmg; i++) {
				txt1 = String.format("%8d", i);
				txt2 = String.format("%12.3f", GModel.sec_grp[i].t_len);

				// txt3 = StrLPad(sec_grp[i].t_mass,8);
				txt3 = "<>";

				txt4 = String.format("%8s", GModel.sec_grp[i].Descr);

				txt = txt1 + " " + txt2 + " " + txt3 + " " + txt4;
				fpRpt.write(txt);

				r = r + 1;
			} // next i

			fpRpt.newLine();

		} catch (IOException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		}

		System.out.println("... fprintSection_Details");
	} // ...Prt_Section_Details

	// <<< PrtSpanMoments >>>
	public void fprintSpanMoments() {
		int r; // Integer
		int c; // Integer
		double seg; // Double
		double tmp;
		// String tmpStr;
		int i, j;

		String txt, txt1, txt2, txt3, txt4;

		System.out.println("fprintSpanMoments ...");
		try {
			fpRpt.write("fprintSpanMoments ...\n");
			r = 7;
			c = 1;

			for (i = baseIndex; i < GModel.structParam.nmb; i++) {
				seg = mlen[i] / n_segs;
				txt1 = String.format("%8d", i);
				r = r + 1;
				for (j = 0; j <= n_segs; j++) {
					txt2 = String.format("%8d", j);

					tmp = j * seg;
					txt3 = String.format("%12.4f", tmp);
					txt4 = String.format("%15.2f", mom_spn[i][j]);

					txt = txt1 + " " + txt2 + " " + txt3 + " " + txt4;
					fpRpt.write(txt);
					fpRpt.newLine();
					r = r + 1;
				} // next j

				fpRpt.newLine();
				r = 7;
				c = c + 3;
			} // next i

			fpRpt.newLine();

		} catch (IOException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		}

		System.out.println("... fprintSpanMoments");
	} // ...PrtSpanMoments

	// << Output Results to Table >>
	public void fprintResults() {

		System.out.println("fprintResults ...");

		fprintControls(4, 1);
		fprintDeltas(18, 1);
		fprintEndForces(18, 6);
		fprintReactions(18, 16);
		fprintSection_Details(5, 6);
		fprintSpanMoments();

		System.out.println("... fprintResults");

	} // ..PrintResults

	// ===========================================================================
	// END ''.. Main Module ..
	// ===========================================================================

	// ===========================================================================

} // class

