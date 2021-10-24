//
// Copyright (c)2016 S C Harrison
// Refer to License.txt for terms and conditions of use.
//
import java.io.*;

class clsGeomModel {

	static String[] TokenTable = { "JOB DETAILS", "JOB DATA", "CONTROL DATA",
			"NODES", "MEMBERS", "SUPPORTS", "MATERIALS", "SECTIONS",
			"JOINT LOADS", "MEMBER LOADS", "GRAVITY LOADS" };
	// Index equals TokenKey

	static boolean isEOF = false;

	public final int NUMLOADS = 80;
	public final int order = 50;
	public final int v_size = 50;
	public final int MAX_GRPS = 25;
	public final int MAX_MATS = 10;
	public final int n_segs = 10;
	

	// public final String DATABLOCKTAG = "::";

	// GLOBAL
	static int baseIndex = 0;
	static String dataBlockTag = "::";

	static int MinBound = 1; // NB: Collections start item count at 1.
	static int MaxNodes = 5;

	// .. enumeration constants ..

	// ... Load Actions
	public final static int local_act = 0;
	public final static int global_x = 1;
	public final static int global_y = 2;

	// ... Load Types
	public final static int dst_ld = 1; // .. distributed loads udl, trap,
										// triangular
	public final static int pnt_ld = 2; // .. point load
	public final static int axi_ld = 3; // .. axial load

	public final static int udl_ld = 4; // .. uniform load
	public final static int tri_ld = 5; // .. triangular load

	public final static double mega = 1000000;
	public final static double kilo = 1000;
	public final static double cent = 100;

	public final static double tolerance = 0.0001;
	public final static double infinity = 2E+20;
	public final static int neg_slope = 1;
	public final static int pos_slope = -1;
	//
	// //Public Nodes(MaxNodes) As clsPfCoordinate //Not possible in vba but
	// possible in vb.net
	// //var Nodes = new Collection //use collection instead of public array
	//
	// File Parser: Limit State Machine
	final int MachineOFF = 0;
	final int MachineTurnOFF = 0;

	final int MachineON = 1;
	final int MachineTurnON = 1;
	final int MachineRunning = 1;
	final int MachineScanning = 1;

	final int RecognisedSection = 2;
	final int DataBlockFound = 3;

	static String lastTxtStr = "";

	// ------------------------------------------------------------------------------
	// Need Public Access to this Data
	// As the whole point is to programmatically define and build a structural
	// model
	// External to the Class
	// ------------------------------------------------------------------------------
	// Project & Parameters
	public clsProjectData ProjectData = new clsProjectData();
	public clsParameters structParam = new clsParameters();

	// Materials & Sections
	public clsPfMaterial[] mat_grp = new clsPfMaterial[MAX_MATS]; // material_rec
	public clsPfSection[] sec_grp = new clsPfSection[MAX_GRPS]; // section_rec

	// Dimension & Geometry
	public clsPfCoordinate[] nod_grp = new clsPfCoordinate[MAX_GRPS]; // coord_rec
	public clsPfConnectivity[] con_grp = new clsPfConnectivity[MAX_GRPS]; // connect_rec
	public clsPfSupport[] sup_grp = new clsPfSupport[MAX_GRPS]; // support_rec

	// Design Actions
	public clsPfJointLoad[] jnt_lod = new clsPfJointLoad[NUMLOADS]; // jnt_ld_rec
	public clsPfMemberLoad[] mem_lod = new clsPfMemberLoad[NUMLOADS]; // mem_ld_rec
	public clsPfGravityLoad grv_lod = new clsPfGravityLoad(); // grv_ld_rec

	static int getTokenKey(String s) {
		int i;
		int NumTokens;
		boolean AllDone = false;

		//System.out.format("getTokenKey: <%s>%n", s);

		i = 0;
		NumTokens = TokenTable.length;
		AllDone = false;

		while (!AllDone){ 
			
			if (i < NumTokens) {
				
				if (TokenTable[i].toUpperCase().equals(s.toUpperCase())){
					//System.out.format("%d %s *%n", i, TokenTable[i]);
					AllDone = true;
				}else {
					//System.out.format("%d %s X%n", i, TokenTable[i]);
					i = i + 1;
				}
				
			}else{
				AllDone = true;
			}
				
		} //while
	

		if (i < NumTokens) {
			if (TokenTable[i].toUpperCase().equals(s.toUpperCase()))
				return i;
			else {
				return -1; // not a valid token
			}
		} else {
			return -1;
		}

	}

	// --------------------------------------------------------------------------------
	// //DATA COLLECTION SUBROUTINES
	// //------------------------------------------------------------------------------
	// function setNode(ByVal nodeKey , ByVal x1 , ByVal y1 )
	// {
	// var nodePtr As clsPfCoordinate
	//
	// Set nodePtr = Nodes(nodeKey)
	// Call nodePtr.setValues(nodeKey, x1, y1)
	// }

	// function setNode2(ByVal nodeKey , ByVal x1 , ByVal y1 )
	// {
	// var nodePtr As clsPfCoordinate
	//
	// Set nodePtr = nod_grp(nodeKey)
	// Call nodePtr.setValues(nodeKey, x1, y1)
	// }
	public void initialiseMaterials() {
		int i;

		System.out.println("Initialise: Materials");
		for (i = baseIndex; i < MAX_MATS; i++) {
			mat_grp[i] = new clsPfMaterial();
			mat_grp[i].initialise();
		}

	}

	public void initialiseSections() {
		int i;

		System.out.println("Initialise: Sections");
		for (i = baseIndex; i < MAX_GRPS; i++) {
			sec_grp[i] = new clsPfSection();
			sec_grp[i].initialise();
		}

	}

	public void initialiseNodes() {
		int i;

		System.out.println("Initialise: Nodes");
		for (i = baseIndex; i < MAX_GRPS; i++) {
			nod_grp[i] = new clsPfCoordinate();
			nod_grp[i].initialise();
		}

	}

	public void initialiseConnectivity() {
		int i;

		System.out.println("Initialise: Connectivity");
		for (i = baseIndex; i < MAX_GRPS; i++) {
			con_grp[i] = new clsPfConnectivity();
			con_grp[i].initialise();
		}

	}

	public void initialiseSupports() {
		int i;

		System.out.println("Initialise: Supports");
		for (i = baseIndex; i < MAX_GRPS; i++) {
			sup_grp[i] = new clsPfSupport();
			sup_grp[i].initialise();
		}

	}

	public void initialiseJointLoads() {
		int i;

		System.out.println("Initialise: Joint Loads");
		for (i = baseIndex; i < NUMLOADS; i++) {
			jnt_lod[i] = new clsPfJointLoad();
			jnt_lod[i].initialise();
		}

	}

	public void initialiseMemberLoads() {
		int i;

		System.out.println("Initialise: Member Loads");
		for (i = baseIndex; i < NUMLOADS; i++) {
			mem_lod[i] = new clsPfMemberLoad();
			mem_lod[i].initialise();
		}

	}

	public void initialiseGravityLoads() {
		System.out.println("Initialise: Gravity Loads");
		grv_lod.initialise();
	}

	public void initialise() {
		ProjectData.initialise();
		structParam.initialise();

		initialiseMaterials();
		initialiseSections();
		initialiseNodes();
		initialiseConnectivity();
		initialiseSupports();

		initialiseJointLoads();
		initialiseMemberLoads();
		initialiseGravityLoads();
	}

	public void setParameters() {
		// clsGeomModel mypublic = new clsGeomModel();

		// mypublic.structParam.njt = mypublic.nod_grp.Length; //.. No. of
		// joints ..
		// mypublic.structParam.nmb = mypublic.con_grp.Length; //.. No. of
		// members ..
		// mypublic.structParam.nmg = mypublic.mat_grp.Length; //.. No. of
		// material groups ..
		// mypublic.structParam.nsg = mypublic.sec_grp.Length; //.. No. of
		// member section groups ..
		// mypublic.structParam.nrj = mypublic.sup_grp.Length; //.. No. of
		// supported reaction joints ..
		// mypublic.structParam.njl = mypublic.jnt_lod.Length; //.. No. of
		// loaded joints ..
		// mypublic.structParam.nml = mypublic.mem_lod.Length; //.. No. of
		// loaded members ..
		// mypublic.structParam.ngl = 1; //.. No. of gravity load cases .. Self
		// weight

		structParam.njt = nod_grp.length; // .. No. of joints ..
		structParam.nmb = con_grp.length; // .. No. of members ..
		structParam.nmg = mat_grp.length; // .. No. of material groups ..
		structParam.nsg = sec_grp.length; // .. No. of member section groups ..
		structParam.nrj = sup_grp.length; // .. No. of supported reaction joints
											// ..
		structParam.njl = jnt_lod.length; // .. No. of loaded joints ..
		structParam.nml = mem_lod.length; // .. No. of loaded members ..
		structParam.ngl = 1; // .. No. of gravity load cases .. Self weight

	}

	public void addNode(clsPfCoordinate nodePtr) {

		nod_grp[structParam.njt] = nodePtr;
		structParam.njt = structParam.njt + 1;
	}

	public void addMember(clsPfConnectivity memberPtr) {
		con_grp[structParam.nmb] = memberPtr;
		structParam.nmb = structParam.nmb + 1;
	}

	public void addSupport(clsPfSupport supportPtr) {
		System.out.println("ADD Support");

		sup_grp[structParam.nrj] = supportPtr;
		structParam.nr = structParam.nr + supportPtr.rx + supportPtr.ry
				+ supportPtr.rm;
		System.out.println("structParam.nr : "
				+ String.format("%d", structParam.nr));
		structParam.nrj = structParam.nrj + 1;
	}

	public void addMaterialGroup(clsPfMaterial materialPtr) {

		mat_grp[structParam.nmg] = materialPtr;
		structParam.nmg = structParam.nmg + 1;
	}

	public void addSectionGroup(clsPfSection sectionPtr) {

		sec_grp[structParam.nsg] = sectionPtr;
		structParam.nsg = structParam.nsg + 1;
	}

	public void addJointLoad(clsPfJointLoad LoadPtr) {

		jnt_lod[structParam.njl] = LoadPtr;
		structParam.njl = structParam.njl + 1;
	}

	public void addMemberLoad(clsPfMemberLoad Loadptr) {

		mem_lod[structParam.nml] = Loadptr;
		structParam.nml = structParam.nml + 1;
	}

	public void addGravityLoad(clsPfGravityLoad Loadptr) {
		grv_lod = Loadptr;
	}

	public double getLength(int memberKey) {
		int ptA;
		int ptB;
		double deltaX, deltaY;
		double magnitude;

		ptA = con_grp[memberKey - 1].jj - 1;
		ptB = con_grp[memberKey - 1].jk - 1;

		// System.out.println(con_grp[memberKey-1].key);
		// System.out.println(ptA.toString() + "," + ptB.toString());
		// System.out.println(nod_grp[ptA].x,nod_grp[ptA].y);
		// System.out.println(nod_grp[ptB].x,nod_grp[ptB].y);

		deltaX = nod_grp[ptB].x - nod_grp[ptA].x;
		deltaY = nod_grp[ptB].y - nod_grp[ptA].y;

		// System.out.println(deltaX);
		// System.out.println(deltaY);
		magnitude = Math.sqrt(Math.pow(deltaX, 2) + Math.pow(deltaY, 2));
		// System.out.println(magnitude);

		return magnitude;
	}

	// REPORTING SUBROUTINES
	// ------------------------------------------------------------------------------

	public void cprintjobData() {
		System.out.println("cprintjobData ...");
		ProjectData.cprint();
	}

	public void cprintControlData() {
		System.out.println("cprintControlData ...");
		structParam.cprint();
	}

	public void cprintNodes() {
		int n;
		int i;

		System.out.println("cprintNodes ...");

		if (structParam.njt == 0) {
			n = MAX_GRPS;
		} else {
			n = structParam.njt;
		}

		// n = nod_grp.Length;
		for (i = baseIndex; i < n; i++) {
			nod_grp[i].cprint();
		}

		System.out.println("... cprintNodes");

	}

	public void cprintConnectivity() {
		int i;
		int n;

		System.out.println("cprint: Connectivity");
		if (structParam.nmb == 0) {
			n = MAX_GRPS;
		} else {
			n = structParam.nmb;
		}

		// n = con_grp.Length;
		for (i = baseIndex; i < n; i++) {
			con_grp[i].cprint();
		}

	}

	public void cprintMaterials() {
		int i;
		int n;

		System.out.println("cprint: Materials");
		if (structParam.nmg == 0) {
			n = MAX_MATS;
		} else {
			n = structParam.nmg;
		}

		// n = mat_grp.Length;
		for (i = baseIndex; i < n; i++) {
			mat_grp[i].cprint();
		}

	}

	public void cprintSections() {
		int i;
		int n;

		System.out.println("cprint: Sections");
		if (structParam.nsg == 0) {
			n = MAX_GRPS;
		} else {
			n = structParam.nsg;
		}

		// n = sec_grp.Length;
		for (i = baseIndex; i < n; i++) {
			sec_grp[i].cprint();
		}
	}

	public void cprintSupports() {
		int i;
		int n;

		System.out.println("cprint: Supports");
		if (structParam.nrj == 0) {
			n = MAX_GRPS;
		} else {
			n = structParam.nrj;
		}

		// n = sup_grp.Length;
		for (i = baseIndex; i < n; i++) {
			sup_grp[i].cprint();
		}
	}

	public void cprintJointLoads() {
		int i;
		int n;

		System.out.println("cprint: Joint Loads");
		if (structParam.njl == 0) {
			n = NUMLOADS;
		} else {
			n = structParam.njl;
		}

		// n = jnt_lod.Length;
		for (i = baseIndex; i < n; i++) {
			jnt_lod[i].cprint();
		}

	}

	public void cprintMemberLoads() {
		int i;
		int n;

		System.out.println("cprint: Member Loads");
		if (structParam.nml == 0) {
			n = NUMLOADS;
		} else {
			n = structParam.nml;
		}

		// n = mem_lod.Length;
		for (i = baseIndex; i < n; i++) {
			mem_lod[i].cprint();
		}
	}

	public void cprintGravityLoads() {
		// int i;
		// int n;

		System.out.println("cprint: Gravity Loads");

		// n = grv_lod.Length;
		// for(i = baseIndex; i<n;i++)
		// {
		// grv_lod[i].cprint();
		// }

		grv_lod.cprint();

	}

	public void cprint() {
		System.out.println("cprint ...");

		System.out.println("Project Data");
		System.out.println("------------");
		cprintjobData();
		cprintControlData();

		System.out.println("Materials");
		System.out.println("------------");
		cprintMaterials();
		cprintSections();

		System.out.println("Model");
		System.out.println("------------");
		cprintNodes();
		cprintConnectivity();
		cprintSupports();

		System.out.println("Loading");
		System.out.println("------------");
		cprintJointLoads(); // (false);
		cprintMemberLoads();
		cprintGravityLoads();

		System.out.println("... cprint");
	}

	// FILE READING SUBROUTINES
	// ------------------------------------------------------------------------------
	public boolean isDataBlockHeaderString(String s) {
		int p;

		if (s != null) {
			p = s.indexOf(dataBlockTag);
		} else
			p = -1;

		if (p != -1) {
			return true;
		} else {
			return false;
		}
	}

	public void fgetNodeData(BufferedReader fp) {
		clsPfCoordinate nodePtr; // = new clsPfCoordinate;

		String s = "";
		// String[] dataflds = new String[10]; // (0 To 9);

		int MachineState;
		boolean quit; // Switch Machine OFF and Quit
		boolean done; // Finished Reading File but not processing data, prepare
						// machine to switch off
		boolean isDataBlockFound;

		quit = false;
		MachineState = MachineON; // and is Scanning file
		done = false;
		isDataBlockFound = false;

		System.out.println("fgetNodeData ...");

		done = false;
		while (!(done) && !(quit)) {
			switch (MachineState) {
			case MachineTurnOFF:
				quit = true;
				System.out.println("Machine to be Turned OFF");
				break;
			case MachineScanning:
				try {
					if ((s = fp.readLine()) != null) {
						// s = fp.readLine();
						System.out.println(">" + s + "<");

						nodePtr = new clsPfCoordinate();

						isDataBlockFound = isDataBlockHeaderString(s);
						if (isDataBlockFound) {
							System.out.println("data block found");
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
				} catch (IOException e) {
					// TODO Auto-generated catch block
					e.printStackTrace();
				}
				break;
			case DataBlockFound:
				// Signifies End of Current Data Block
				done = true;
				MachineState = MachineTurnOFF;
				break;
			} // switch

			nodePtr = null;

		} // Loop
		lastTxtStr = s;
		System.out.println("lastTxtStr: " + lastTxtStr);
		System.out.println("... fgetNodeData");

	}

	public void fgetMemberData(BufferedReader fp) {
		clsPfConnectivity memberPtr;

		String s = "";
		// String[] dataflds = new String[10]; // (0 To 9);

		int MachineState;
		boolean quit; // Switch Machine OFF and Quit
		boolean done; // Finished Reading File but not processing data, prepare
						// machine to switch off
		boolean isDataBlockFound;

		quit = false;
		MachineState = MachineON; // and is Scanning file
		done = false;
		isDataBlockFound = false;

		System.out.println("fgetMemberData ...");

		done = false;
		while (!(done) && !(quit)) {
			switch (MachineState) {
			case MachineTurnOFF:
				quit = true;
				System.out.println("Machine to be Turned OFF");
				break;
			case MachineScanning:
				try {
					if ((s = fp.readLine()) != null) {

						// s = fp.ReadLine();;
						// s = fp.readLine();

						memberPtr = new clsPfConnectivity();
						memberPtr.initialise();
						memberPtr.jnt_jj = new clsPfForce();
						memberPtr.jnt_jj.initialise();
						memberPtr.jnt_jk = new clsPfForce();
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
				} catch (IOException e) {
					// TODO Auto-generated catch block
					e.printStackTrace();
				}
				break;

			case DataBlockFound:
				// Signifies End of Current Data Block
				done = true;
				MachineState = MachineTurnOFF;
				break;

			} // switch

			memberPtr = null;

		} // loop

		lastTxtStr = s;

		System.out.println("... fgetMemberData");

	}

	public void fgetSupportData(BufferedReader fp) {
		clsPfSupport supportPtr;
		String s = "";
		// String[] dataflds = new String[10]; // (0 To 9);

		int MachineState;
		boolean quit; // Switch Machine OFF and Quit
		boolean done; // Finished Reading File but not processing data, prepare
						// machine to switch off
		boolean isDataBlockFound;

		quit = false;
		MachineState = MachineON; // and is Scanning file
		done = false;
		isDataBlockFound = false;

		System.out.println("fgetSupportData ...");

		done = false;
		while (!(done) && !(quit)) {
			switch (MachineState) {
			case MachineTurnOFF:
				quit = true;
				System.out.println("Machine to be Turned OFF");
				break;
			case MachineScanning:
				try {
					if ((s = fp.readLine()) != null) {
						// s = fp.readLine();
						supportPtr = new clsPfSupport();

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
				} catch (IOException e) {
					// TODO Auto-generated catch block
					e.printStackTrace();
				}
				break;
			case DataBlockFound:
				// Signifies End of Current Data Block
				done = true;
				MachineState = MachineTurnOFF;
				break;
			} // } End Select

			supportPtr = null;

		} // Loop

		lastTxtStr = s;

		System.out.println("... fgetSupportData");

	}

	public void fgetMaterialData(BufferedReader fp) {
		clsPfMaterial materialPtr;
		String s = "";
		// String[] dataflds = new String[10]; // (0 To 9);

		int MachineState;
		boolean quit; // Switch Machine OFF and Quit
		boolean done; // Finished Reading File but not processing data, prepare
						// machine to switch off
		boolean isDataBlockFound;

		quit = false;
		MachineState = MachineON; // and is Scanning file
		done = false;
		isDataBlockFound = false;

		System.out.println("fgetMaterialData ...");

		done = false;
		while (!(done) && !(quit)) {
			switch (MachineState) {
			case MachineTurnOFF:
				quit = true;
				System.out.println("Machine to be Turned OFF");
				break;
			case MachineScanning:
				try {
					if ((s = fp.readLine()) != null) {
						// s = fp.readLine();
						materialPtr = new clsPfMaterial();

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
				} catch (IOException e) {
					// TODO Auto-generated catch block
					e.printStackTrace();
				}
				break;
			case DataBlockFound:
				// Signifies End of Current Data Block
				done = true;
				MachineState = MachineTurnOFF;
				break;
			} // End Select

			materialPtr = null;

		} // loop

		lastTxtStr = s;

		System.out.println("... fgetMaterialData");

	}

	public void fgetSectionData(BufferedReader fp) {
		clsPfSection sectionPtr;
		String s = "";
		// String[] dataflds = new String[10]; // (0 To 9);

		int MachineState;
		boolean quit; // Switch Machine OFF and Quit
		boolean done; // Finished Reading File but not processing data, prepare
						// machine to switch off
		boolean isDataBlockFound;

		quit = false;
		MachineState = MachineON; // and is Scanning file
		done = false;
		isDataBlockFound = false;

		System.out.println("fgetSectionData ...");

		done = false;
		while (!(done) && !(quit)) {
			switch (MachineState) {
			case MachineTurnOFF:
				quit = true;
				System.out.println("Machine to be Turned OFF");
				break;
			case MachineScanning:
				try {
					if ((s = fp.readLine()) != null) {
						// s = fp.readLine();
						sectionPtr = new clsPfSection();

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
				} catch (IOException e) {
					// TODO Auto-generated catch block
					e.printStackTrace();
				}
				break;
			case DataBlockFound:
				// Signifies End of Current Data Block
				done = true;
				MachineState = MachineTurnOFF;
				break;
			} // End Select

			sectionPtr = null;

		} // Loop

		lastTxtStr = s;

		System.out.println("... fgetSectionData");

	}

	public void fgetJointLoadData(BufferedReader fp) {
		clsPfJointLoad jloadPtr;
		String s = "";
		// String[] dataflds = new String[10]; // (0 To 9);

		int MachineState;
		boolean quit; // Switch Machine OFF and Quit
		boolean done; // Finished Reading File but not processing data, prepare
						// machine to switch off
		boolean isDataBlockFound;

		quit = false;
		MachineState = MachineON; // and is Scanning file
		done = false;
		isDataBlockFound = false;

		System.out.println("fgetJointLoadData ...");

		done = false;
		while (!(done) && !(quit)) {
			switch (MachineState) {
			case MachineTurnOFF:
				quit = true;
				System.out.println("Machine to be Turned OFF");
				break;
			case MachineScanning:
				try {
					if ((s = fp.readLine()) != null) {
						// s = fp.readLine();
						jloadPtr = new clsPfJointLoad();

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
				} catch (IOException e) {
					// TODO Auto-generated catch block
					e.printStackTrace();
				}
				break;
			case DataBlockFound:
				// Signifies End of Current Data Block
				done = true;
				MachineState = MachineTurnOFF;
				break;
			} // End Select

			jloadPtr = null;

		} // Loop

		lastTxtStr = s;

		System.out.println("... fgetJointLoadData");

	}

	public void fgetMemberLoadData(BufferedReader fp) {
		clsPfMemberLoad mLoadPtr;
		String s = "";
		// String[] dataflds = new String[10]; // (0 To 9);

		int MachineState;
		boolean quit; // Switch Machine OFF and Quit
		boolean done; // Finished Reading File but not processing data, prepare
						// machine to switch off
		boolean isDataBlockFound;

		quit = false;
		MachineState = MachineON; // and is Scanning file
		done = false;
		isDataBlockFound = false;

		System.out.println("fgetMemberLoadData ...");

		done = false;
		while (!(done) && !(quit)) {
			switch (MachineState) {
			case MachineTurnOFF:
				quit = true;
				System.out.println("Machine to be Turned OFF");
				break;
			case MachineScanning:
				try {
					if ((s = fp.readLine()) != null) {
						// s = fp.readLine();
						mLoadPtr = new clsPfMemberLoad();

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
				} catch (IOException e) {
					// TODO Auto-generated catch block
					e.printStackTrace();
				}
				break;
			case DataBlockFound:
				// Signifies End of Current Data Block
				done = true;
				MachineState = MachineTurnOFF;
				break;
			} // End Select

			mLoadPtr = null;

		} // Loop

		lastTxtStr = s;

		System.out.println("... fgetMemberLoadData");

	}

	public void fgetGravityLoadData(BufferedReader fp) {
		clsPfGravityLoad gLoadPtr;
		String s = "";
		String[] dataflds = new String[10]; // (0 To 9);

		int MachineState;
		boolean quit = false; // Switch Machine OFF and Quit
		boolean done; // Finished Reading File but not processing data, prepare
						// machine to switch off
		boolean isDataBlockFound;
		boolean isUseDefaultData;

		System.out.println("fgetGravityLoadData ...");

		isDataBlockFound = false;
		if (!isEOF) {
			quit = false;
			MachineState = MachineON; // and is Scanning file
			done = false;
			isUseDefaultData = false;
		} else {
			done = true;
			MachineState = MachineTurnOFF;
			isUseDefaultData = true;
		}

		while (!(done) && !(quit)) {
			switch (MachineState) {
			case MachineTurnOFF:
				quit = true;
				System.out
						.println("Limit State File Parser Machine to be Turned OFF");
				break;

			case MachineScanning:
				try {
					if ((s = fp.readLine()) != null) {
						// s = fp.readLine();
						gLoadPtr = new clsPfGravityLoad();

						isDataBlockFound = isDataBlockHeaderString(s);
						if (isDataBlockFound) {
							MachineState = DataBlockFound;
						} else {

							gLoadPtr.sgetData(s);
							addGravityLoad(gLoadPtr);

							MachineState = MachineScanning;
						}
					} else {
						System.out.println("... End of File");
						isEOF = true;
						done = true;
						MachineState = MachineTurnOFF;
					}
				} catch (IOException e) {
					// TODO Auto-generated catch block
					e.printStackTrace();
					isEOF = true;
				}
				break;

			case DataBlockFound:
				// Signifies End of Current Data Block
				done = true;
				MachineState = MachineTurnOFF;
				break;

			} // End Select

			gLoadPtr = null;

		} // Loop

		if (!isEOF) {
			lastTxtStr = s;
		} else {
			lastTxtStr = "";
		}

		if (isUseDefaultData) {
			System.out.println("Using Default Data");
			// addGravityLoad(2, -9.81);
		}

		// File Data Ignored
		// Default Values Used Only

		System.out.println("... fgetGravityLoadData");
	}

	// Limit State Machine: File Parser
	// File format to match requirements for F_wrk.exe (With File Date Modified
	// = Friday, 23 August 1996, 13:18:04)
	public void pframeReader00(BufferedReader fp) { // begin function

		String dataCtrlBlk = "";
		int dataCtrlBlkKey = -1;

		int MachineState;
		boolean quit;
		boolean done;
		boolean isDataBlockFound;
		String s;

		System.out.println("pframeReader00 ...");

		s = "";
		MachineState = MachineON; // and is Scanning file
		quit = false;
		done = false;
		isDataBlockFound = false;

		// System.out.println("Machine Should start Scanning:");
		while (!(done) && !(quit)) {
			System.out.println("Machine ON: Scanning Started");
			System.out.format("Machine State: %d%n", MachineState);
			switch (MachineState) {
			case MachineTurnOFF:

				quit = true;
				System.out.println("Machine to be Turned OFF");
				break;

			case MachineScanning:
				System.out.println("Machine Scanning ...");

				try {
					if ((s = fp.readLine()) != null) {
						System.out.println("Reading File ...");

						isDataBlockFound = isDataBlockHeaderString(s);
						System.out.format("IN: <%s>%n", s);
						System.out.println("machine scanning ...");

						if (isDataBlockFound) {
							MachineState = DataBlockFound;
						} else {
							MachineState = MachineScanning;
						}
					} else {
						System.out.println("<EndOfStream>");
						isEOF = true;
						done = true;
						MachineState = MachineTurnOFF;
					}
				} catch (IOException e) {
					// TODO Auto-generated catch block
					e.printStackTrace();
					isEOF = true;
				}

				break;
			case DataBlockFound:
				System.out.format("DataBlockFound:MAIN: <%s>%n", s);
				s = s.substring(0, s.length() - 2).trim().toUpperCase();
				dataCtrlBlk = String.format("%s", s);
				dataCtrlBlkKey = getTokenKey(dataCtrlBlk);
				System.out.format("dataCtrlBlk: <%s>%n", dataCtrlBlk);
				System.out.format("dataCtrlBlkKey: <%d>%n", dataCtrlBlkKey);
				MachineState = RecognisedSection;
				break;

			case RecognisedSection:
				System.out.format("Machine State: Recognised Section: %d%n",
						RecognisedSection);
				switch (dataCtrlBlkKey) { // (dataCtrlBlk) {
				case 0: // "JOB DETAILS": // Alternative to Job Data
					System.out.format("%d ) [%s]%n", dataCtrlBlkKey,
							dataCtrlBlk);
					ProjectData.fgetData(fp);
					MachineState = MachineScanning;
					break;

				case 1: // "JOB DATA": // Alternative to Job Details
					System.out.format("%d ) [%s]%n", dataCtrlBlkKey,
							dataCtrlBlk);
					ProjectData.fgetData(fp);
					MachineState = MachineScanning;
					break;

				case 2: // "CONTROL DATA":
					System.out.format("%d ) [%s]%n", dataCtrlBlkKey,
							dataCtrlBlk);
					structParam.initialise();
					structParam.fgetData(fp, true);
					MachineState = MachineScanning;
					structParam.nr = 0;
					System.out.println("structParam.nr : "
							+ String.format("%d", structParam.nr));
					break;

				case 3: // "NODES":
					System.out.format("%d ) [%s]%n", dataCtrlBlkKey,
							dataCtrlBlk);
					fgetNodeData(fp);
					s = lastTxtStr;
					MachineState = DataBlockFound;
					// MachineState = MachineScanning;
					break;

				case 4: // "MEMBERS":
					System.out.format("%d ) [%s]%n", dataCtrlBlkKey,
							dataCtrlBlk);
					fgetMemberData(fp); // s);
					s = lastTxtStr;
					MachineState = DataBlockFound;
					break;

				case 5: // "SUPPORTS":
					System.out.format("%d ) [%s]%n", dataCtrlBlkKey,
							dataCtrlBlk);
					fgetSupportData(fp);
					s = lastTxtStr;
					MachineState = DataBlockFound;
					// MachineState = MachineScanning;
					break;

				case 6: // "MATERIALS":
					System.out.format("%d ) [%s]%n", dataCtrlBlkKey,
							dataCtrlBlk);
					fgetMaterialData(fp);
					s = lastTxtStr;
					MachineState = DataBlockFound;
					break;

				case 7: // "SECTIONS":
					System.out.format("%d ) [%s]%n", dataCtrlBlkKey,
							dataCtrlBlk);
					fgetSectionData(fp);
					s = lastTxtStr;
					MachineState = DataBlockFound;
					break;

				case 8: // "JOINT LOADS":
					System.out.format("%d ) [%s]%n", dataCtrlBlkKey,
							dataCtrlBlk);
					fgetJointLoadData(fp);
					s = lastTxtStr;
					MachineState = DataBlockFound;
					break;

				case 9: // "MEMBER LOADS":
					System.out.format("%d ) [%s]%n", dataCtrlBlkKey,
							dataCtrlBlk);
					fgetMemberLoadData(fp);
					s = lastTxtStr;
					if (!isEOF) {
						MachineState = DataBlockFound;
					} else {
						MachineState = MachineTurnOFF;
					}
					break;

				case 10: // "GRAVITY LOADS":
					System.out.format("%d ) [%s]%n", dataCtrlBlkKey,
							dataCtrlBlk);
					fgetGravityLoadData(fp);
					s = lastTxtStr;
					MachineState = MachineTurnOFF;
					break;

				default:
					MachineState = MachineScanning;
					break;

				} // switch
				break;

			default:
				if (isEOF) {
					System.out.println("DataBlockFound: End Of File");
					done = true;
					MachineState = MachineTurnOFF;
				} else {
					MachineState = MachineScanning;
				}
				break;

			} // Switch: machine state

		} // Loop

		System.out.println("... pframeReader00");

	} // End Function

	public void fgetDataTest(BufferedReader fp) {
		String s;
		System.out.println("fgetDataTest ...");

		try {
			while ((s = fp.readLine()) != null) {
				// s = fp.readLine();
				System.out.format("<%s>%n", s);
			}

			if (s == null) {
				isEOF = true;

			}
			fp.close();

		} catch (IOException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
			isEOF = true;
		}

		System.out.println("... fgetDataTest");
	}

	public void testTokens() {
		   String TokenStr="";
		   
		   System.out.println("Testing Tokens");
		   System.out.format("Token Key %d%n",getTokenKey("JOB DETAILS"));
		   System.out.format("Token Key %d%n",getTokenKey("SUPPORTS"));
		   System.out.format("Token Key %d%n",getTokenKey( "GRAVITY LOADS" ));
		   System.out.format("Token Key %d%n",getTokenKey( "cat" ));
		   System.out.format("Token :%s%n",TokenTable[getTokenKey("SUPPORTS")]);
		   TokenStr = "JOB DETAILS";
		   System.out.println("Testing Tokens: Passing String Variable");
		   System.out.format("Token Key %d%n",getTokenKey(TokenStr));
	}

	// DATA FILE STORE SUBROUTINES
	// ------------------------------------------------------------------------------

	public void SaveDataToTextFile(BufferedWriter fp) {
		int i;

		System.out.println("SaveDataToTextFile ...");
		try {
			fp.write("JOB DATA" + dataBlockTag);
			ProjectData.fprint(fp);

			// NB: It some versions of original Pascal application require
			// screen magnification factor
			// other versions don//t. if needed and not present the program will
			// crash. if not needed but
			// is present it is simply ignored. Therefore always write to the
			// file.
			fp.write("CONTROL DATA" + dataBlockTag);
			structParam.fprint(fp);

			fp.write("NODES" + dataBlockTag);
			for (i = baseIndex; i < nod_grp.length; i++) {
				nod_grp[i].fprint(fp);
			}

			fp.write("MEMBERS" + dataBlockTag);
			for (i = baseIndex; i < con_grp.length; i++) {
				con_grp[i].fprint(fp);
			}

			fp.write("SUPPORTS" + dataBlockTag);
			for (i = baseIndex; i < sup_grp.length; i++) {
				sup_grp[i].fprint(fp);
			}

			fp.write("MATERIALS" + dataBlockTag);
			for (i = baseIndex; i < mat_grp.length; i++) {
				mat_grp[i].fprint(fp);
			}

			fp.write("SECTIONS" + dataBlockTag);
			for (i = baseIndex; i < sec_grp.length; i++) {
				sec_grp[i].fprint(fp);
			}

			fp.write("JOINT LOADS" + dataBlockTag);
			System.out.format("njl= %d%n", structParam.njl);
			for (i = baseIndex; i < jnt_lod.length; i++) {
				jnt_lod[i].fprint(fp);
			}

			fp.write("MEMBER LOADS" + dataBlockTag);
			for (i = baseIndex; i < mem_lod.length; i++) {
				mem_lod[i].fprint(fp);
			}

			fp.write("GRAVITY LOADS" + dataBlockTag);

			fp.close();

			System.out.println("... SaveDataToTextFile");

		} catch (IOException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		}

	}

} // class

