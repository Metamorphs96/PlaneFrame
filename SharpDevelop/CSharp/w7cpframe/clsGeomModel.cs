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
    class clsGeomModel
    {

        public const int NUMLOADS = 80;
        public const int order = 50;
        public const int v_size = 50;
        public const int MAX_GRPS = 25;
        public const int MAX_MATS = 10;
        public const int n_segs = 10;

        //public const string DATABLOCKTAG = "::";

        //GLOBAL
        static int baseIndex = 0;
        static string dataBlockTag = "::";



        static int MinBound = 1; //NB: Collections start item count at 1.
        static int MaxNodes = 5;

        //.. enumeration constants ..

        //... Load Actions
        public const int local_act = 0;
        public const int global_x = 1;
        public const int global_y = 2;

        //... Load Types
        public const int dst_ld = 1;    //.. distributed loads udl, trap, triangular
        public const int pnt_ld = 2;    //.. point load
        public const int axi_ld = 3;    //.. axial load

        public const int udl_ld = 4;    //.. uniform load
        public const int tri_ld = 5;    //.. triangular load

        public const double mega = 1000000;
        public const double kilo = 1000;
        public const double cent = 100;

        public const double tolerance = 0.0001;
        public const double infinity = 2E+20;
        public const int neg_slope = 1;
        public const int pos_slope = -1;
        //
        ////Public Nodes(MaxNodes) As clsPfCoordinate //Not possible in vba but possible in vb.net
        ////var Nodes = new Collection //use collection instead of public array
        //
        //File Parser: Limit State Machine
        const int MachineOFF = 0;
        const int MachineTurnOFF = 0;

        const int MachineON = 1;
        const int MachineTurnON = 1;
        const int MachineRunning = 1;
        const int MachineScanning = 1;

        const int RecognisedSection = 2;
        const int DataBlockFound = 3;

        static string lastTxtStr = "";

        //------------------------------------------------------------------------------
        //Need Public Access to this Data
        //As the whole point is to programmatically define and build a structural model
        //External to the Class
        //------------------------------------------------------------------------------
        //Project & Parameters
        public clsProjectData ProjectData = new clsProjectData();
        public clsParameters structParam = new clsParameters();

        //Materials & Sections
        public clsPfMaterial[] mat_grp = new clsPfMaterial[MAX_MATS];        //material_rec
        public clsPfSection[] sec_grp = new clsPfSection[MAX_GRPS];         //section_rec

        //Dimension & Geometry
        public clsPfCoordinate[] nod_grp = new clsPfCoordinate[MAX_GRPS];      //coord_rec
        public clsPfConnectivity[] con_grp = new clsPfConnectivity[MAX_GRPS];    //connect_rec
        public clsPfSupport[] sup_grp = new clsPfSupport[MAX_GRPS];         //support_rec

        //Design Actions
        public clsPfJointLoad[] jnt_lod = new clsPfJointLoad[NUMLOADS];       //jnt_ld_rec
        public clsPfMemberLoad[] mem_lod = new clsPfMemberLoad[NUMLOADS];      //mem_ld_rec
        public clsPfGravityLoad grv_lod = new clsPfGravityLoad();     //grv_ld_rec


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
        public void initialiseMaterials()
        {
            int i;

            Console.WriteLine("Initialise: Materials");
            for (i = baseIndex; i < MAX_MATS; i++)
            {
                mat_grp[i] = new clsPfMaterial();
                mat_grp[i].initialise();
            }

        }




        public void initialiseSections()
        {
            int i;

            Console.WriteLine("Initialise: Sections");
            for (i = baseIndex; i < MAX_GRPS; i++)
            {
                sec_grp[i] = new clsPfSection();
                sec_grp[i].initialise();
            }

        }


        public void initialiseNodes()
        {
            int i;

            Console.WriteLine("Initialise: Nodes");
            for (i = baseIndex; i < MAX_GRPS; i++)
            {
                nod_grp[i] = new clsPfCoordinate();
                nod_grp[i].initialise();
            }

        }


        public void initialiseConnectivity()
        {
            int i;

            Console.WriteLine("Initialise: Connectivity");
            for (i = baseIndex; i < MAX_GRPS; i++)
            {
                con_grp[i] = new clsPfConnectivity();
                con_grp[i].initialise();
            }

        }



        public void initialiseSupports()
        {
            int i;

            Console.WriteLine("Initialise: Supports");
            for (i = baseIndex; i < MAX_GRPS; i++)
            {
                sup_grp[i] = new clsPfSupport();
                sup_grp[i].initialise();
            }

        }

        public void initialiseJointLoads()
        {
            int i;

            Console.WriteLine("Initialise: Joint Loads");
            for (i = baseIndex; i < NUMLOADS; i++)
            {
                jnt_lod[i] = new clsPfJointLoad();
                jnt_lod[i].initialise();
            }

        }

        public void initialiseMemberLoads()
        {
            int i;

            Console.WriteLine("Initialise: Member Loads");
            for (i = baseIndex; i < NUMLOADS; i++)
            {
                mem_lod[i] = new clsPfMemberLoad();
                mem_lod[i].initialise();
            }

        }


        public void initialiseGravityLoads()
        {
            Console.WriteLine("Initialise: Gravity Loads");
            grv_lod.initialise();
        }

        public void initialise()
        {
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



        public void setParameters()
        {
            //clsGeomModel mypublic = new clsGeomModel();

            //mypublic.structParam.njt = mypublic.nod_grp.Length;        //.. No. of joints ..
            //mypublic.structParam.nmb = mypublic.con_grp.Length;        //.. No. of members ..
            //mypublic.structParam.nmg = mypublic.mat_grp.Length;        //.. No. of material groups ..
            //mypublic.structParam.nsg = mypublic.sec_grp.Length;        //.. No. of member section groups ..
            //mypublic.structParam.nrj = mypublic.sup_grp.Length;        //.. No. of supported reaction joints ..
            //mypublic.structParam.njl = mypublic.jnt_lod.Length;        //.. No. of loaded joints ..
            //mypublic.structParam.nml = mypublic.mem_lod.Length;        //.. No. of loaded members ..
            //mypublic.structParam.ngl = 1;                     //.. No. of gravity load cases .. Self weight  

            structParam.njt = nod_grp.Length;        //.. No. of joints ..
            structParam.nmb = con_grp.Length;        //.. No. of members ..
            structParam.nmg = mat_grp.Length;        //.. No. of material groups ..
            structParam.nsg = sec_grp.Length;        //.. No. of member section groups ..
            structParam.nrj = sup_grp.Length;        //.. No. of supported reaction joints ..
            structParam.njl = jnt_lod.Length;        //.. No. of loaded joints ..
            structParam.nml = mem_lod.Length;        //.. No. of loaded members ..
            structParam.ngl = 1;                     //.. No. of gravity load cases .. Self weight  

        }


        public void addNode(clsPfCoordinate nodePtr)
        {

            nod_grp[structParam.njt] = nodePtr;
            structParam.njt = structParam.njt + 1;
        }

        public void addMember(clsPfConnectivity memberPtr)
        {
            con_grp[structParam.nmb] = memberPtr;
            structParam.nmb = structParam.nmb + 1;
        }

        public void addSupport(clsPfSupport supportPtr)
        {
            System.Console.WriteLine("ADD Support");

            sup_grp[structParam.nrj] = supportPtr;
            structParam.nr = structParam.nr + supportPtr.rx + supportPtr.ry + supportPtr.rm;
            System.Console.WriteLine("structParam.nr : " + structParam.nr.ToString());
            structParam.nrj = structParam.nrj + 1;
        }

        public void addMaterialGroup(clsPfMaterial materialPtr)
        {

            mat_grp[structParam.nmg] = materialPtr;
            structParam.nmg = structParam.nmg + 1;
        }

        public void addSectionGroup(clsPfSection sectionPtr)
        {

            sec_grp[structParam.nsg] = sectionPtr;
            structParam.nsg = structParam.nsg + 1;
        }

        public void addJointLoad(clsPfJointLoad LoadPtr)
        {

            jnt_lod[structParam.njl] = LoadPtr;
            structParam.njl = structParam.njl + 1;
        }

        public void addMemberLoad(clsPfMemberLoad Loadptr)
        {

            mem_lod[structParam.nml] = Loadptr;
            structParam.nml = structParam.nml + 1;
        }

        public void addGravityLoad(clsPfGravityLoad Loadptr)
        {
            grv_lod = Loadptr;
        }


        public double getLength(int memberKey)
        {
            int ptA;
            int ptB;
            double deltaX, deltaY;
            double magnitude;

            ptA = con_grp[memberKey - 1].jj - 1;
            ptB = con_grp[memberKey - 1].jk - 1;

            //  System.Console.WriteLine(con_grp[memberKey-1].key);
            //  System.Console.WriteLine(ptA.toString() + "," + ptB.toString());
            //  System.Console.WriteLine(nod_grp[ptA].x,nod_grp[ptA].y);
            //  System.Console.WriteLine(nod_grp[ptB].x,nod_grp[ptB].y);

            deltaX = nod_grp[ptB].x - nod_grp[ptA].x;
            deltaY = nod_grp[ptB].y - nod_grp[ptA].y;

            //  System.Console.WriteLine(deltaX);
            //  System.Console.WriteLine(deltaY);
            magnitude = Math.Sqrt(Math.Pow(deltaX, 2) + Math.Pow(deltaY, 2));
            //  System.Console.WriteLine(magnitude);

            return magnitude;
        }


        //REPORTING SUBROUTINES
        //------------------------------------------------------------------------------

        public void cprintjobData()
        {
            System.Console.WriteLine("cprintjobData ...");
            ProjectData.cprint();
        }

        public void cprintControlData()
        {
            System.Console.WriteLine("cprintControlData ...");
            structParam.cprint();
        }

        public void cprintNodes()
        {
            int n;
            int i;

            System.Console.WriteLine("cprintNodes ...");

            if (structParam.njt == 0)
            {
                n = MAX_GRPS;
            }
            else
            {
                n = structParam.njt;
            }

            //n = nod_grp.Length;
            for (i = baseIndex; i < n; i++)
            {
                nod_grp[i].cprint();
            }

            System.Console.WriteLine("... cprintNodes");

        }

        public void cprintConnectivity()
        {
            int i;
            int n;

            System.Console.WriteLine("cprint: Connectivity");
            if (structParam.nmb == 0)
            {
                n = MAX_GRPS;
            }
            else
            {
                n = structParam.nmb;
            }

            //n = con_grp.Length;
            for (i = baseIndex; i < n; i++)
            {
                con_grp[i].cprint();
            }

        }

        public void cprintMaterials()
        {
            int i;
            int n;

            System.Console.WriteLine("cprint: Materials");
            if (structParam.nmg == 0)
            {
                n = MAX_MATS;
            }
            else
            {
                n = structParam.nmg;
            }

            //n = mat_grp.Length;
            for (i = baseIndex; i < n; i++)
            {
                mat_grp[i].cprint();
            }

        }

        public void cprintSections()
        {
            int i;
            int n;

            System.Console.WriteLine("cprint: Sections");
            if (structParam.nsg == 0)
            {
                n = MAX_GRPS;
            }
            else
            {
                n = structParam.nsg;
            }

            //n = sec_grp.Length;
            for (i = baseIndex; i < n; i++)
            {
                sec_grp[i].cprint();
            }
        }


        public void cprintSupports()
        {
            int i;
            int n;

            System.Console.WriteLine("cprint: Supports");
            if (structParam.nrj == 0)
            {
                n = MAX_GRPS;
            }
            else
            {
                n = structParam.nrj;
            }

            //n = sup_grp.Length;
            for (i = baseIndex; i < n; i++)
            {
                sup_grp[i].cprint();
            }
        }

        public void cprintJointLoads()
        {
            int i;
            int n;

            System.Console.WriteLine("cprint: Joint Loads");
            if (structParam.njl == 0)
            {
                n = NUMLOADS;
            }
            else
            {
                n = structParam.njl;
            }

            //n = jnt_lod.Length;
            for (i = baseIndex; i < n; i++)
            {
                jnt_lod[i].cprint();
            }

        }


        public void cprintMemberLoads()
        {
            int i;
            int n;

            System.Console.WriteLine("cprint: Member Loads");
            if (structParam.nml == 0)
            {
                n = NUMLOADS;
            }
            else
            {
                n = structParam.nml;
            }

            //n = mem_lod.Length;
            for (i = baseIndex; i < n; i++)
            {
                mem_lod[i].cprint();
            }
        }

        public void cprintGravityLoads()
        {
            //int i;
            //int n;

            System.Console.WriteLine("cprint: Gravity Loads");

            //n = grv_lod.Length;
            //for(i = baseIndex; i<n;i++)
            //{
            // grv_lod[i].cprint();
            //}

            grv_lod.cprint();

        }


        public void cprint()
        {
            System.Console.WriteLine("cprint ...");

            System.Console.WriteLine("Project Data");
            System.Console.WriteLine("------------");
            cprintjobData();
            cprintControlData();

            System.Console.WriteLine("Materials");
            System.Console.WriteLine("------------");
            cprintMaterials();
            cprintSections();

            System.Console.WriteLine("Model");
            System.Console.WriteLine("------------");
            cprintNodes();
            cprintConnectivity();
            cprintSupports();

            System.Console.WriteLine("Loading");
            System.Console.WriteLine("------------");
            cprintJointLoads(); //(false);
            cprintMemberLoads();
            cprintGravityLoads();

            System.Console.WriteLine("... cprint");
        }


        //FILE READING SUBROUTINES
        //------------------------------------------------------------------------------
        public bool isDataBlockHeaderString(string s)
        {
            int p;

            p = s.IndexOf(dataBlockTag);
            if (p != -1)
            {
                return true;
            }
            else
            {
                return false;
            }
        }

        public void fgetNodeData(StreamReader fp)
        {
            clsPfCoordinate nodePtr;  //= new clsPfCoordinate;

            string s = "";
            string[] dataflds = new string[10]; //(0 To 9);

            int MachineState;
            bool quit; //Switch Machine OFF and Quit
            bool done; //Finished Reading File but not processing data, prepare machine to switch off
            bool isDataBlockFound;


            quit = false;
            MachineState = MachineON; //and is Scanning file
            done = false;
            isDataBlockFound = false;

            System.Console.WriteLine("fgetNodeData ...");

            done = false;
            while (!(done) && !(quit))
            {
                switch (MachineState)
                {
                    case MachineTurnOFF:
                        quit = true;
                        System.Console.WriteLine("Machine to be Turned OFF");
                        break;
                    case MachineScanning:
                        if (!fp.EndOfStream)
                        {
                            s = fp.ReadLine();
                            System.Console.WriteLine(">" + s + "<");

                            nodePtr = new clsPfCoordinate();

                            isDataBlockFound = isDataBlockHeaderString(s);
                            if (isDataBlockFound)
                            {
                                System.Console.WriteLine("data block found");
                                MachineState = DataBlockFound;
                            }
                            else
                            {

                                nodePtr.sgetData(s);
                                addNode(nodePtr);

                                MachineState = MachineScanning;
                            }
                        }
                        else
                        {
                            done = true;
                            MachineState = MachineTurnOFF;
                        }
                        break;
                    case DataBlockFound:
                        //Signifies End of Current Data Block
                        done = true;
                        MachineState = MachineTurnOFF;
                        break;
                } //switch

                nodePtr = null;

            } //Loop
            lastTxtStr = s;
            System.Console.WriteLine("lastTxtStr: " + lastTxtStr);
            System.Console.WriteLine("... fgetNodeData");

        }


        public void fgetMemberData(StreamReader fp)
        {
            clsPfConnectivity memberPtr;

            string s = "";
            string[] dataflds = new string[10]; //(0 To 9);

            int MachineState;
            bool quit; //Switch Machine OFF and Quit
            bool done; //Finished Reading File but not processing data, prepare machine to switch off
            bool isDataBlockFound;

            quit = false;
            MachineState = MachineON; //and is Scanning file
            done = false;
            isDataBlockFound = false;

            System.Console.WriteLine("fgetMemberData ...");

            done = false;
            while (!(done) && !(quit))
            {
                switch (MachineState)
                {
                    case MachineTurnOFF:
                        quit = true;
                        System.Console.WriteLine("Machine to be Turned OFF");
                        break;
                    case MachineScanning:
                        if (!fp.EndOfStream)
                        {

                            //s = fp.ReadLine();;
                            s = fp.ReadLine();

                            memberPtr = new clsPfConnectivity();
                            memberPtr.initialise();
                            memberPtr.jnt_jj = new clsPfForce();
                            memberPtr.jnt_jj.initialise();
                            memberPtr.jnt_jk = new clsPfForce();
                            memberPtr.jnt_jk.initialise();

                            isDataBlockFound = isDataBlockHeaderString(s);
                            if (isDataBlockFound)
                            {
                                MachineState = DataBlockFound;
                            }
                            else
                            {

                                memberPtr.sgetData(s);
                                addMember(memberPtr);

                                MachineState = MachineScanning;
                            }
                        }
                        else
                        {
                            done = true;
                            MachineState = MachineTurnOFF;
                        }
                        break;

                    case DataBlockFound:
                        //Signifies End of Current Data Block
                        done = true;
                        MachineState = MachineTurnOFF;
                        break;

                } //switch

                memberPtr = null;

            } //loop

            lastTxtStr = s;

            System.Console.WriteLine("... fgetMemberData");

        }


        public void fgetSupportData(StreamReader fp)
        {
            clsPfSupport supportPtr;
            string s = "";
            string[] dataflds = new string[10]; //(0 To 9);

            int MachineState;
            bool quit; //Switch Machine OFF and Quit
            bool done; //Finished Reading File but not processing data, prepare machine to switch off
            bool isDataBlockFound;

            quit = false;
            MachineState = MachineON; //and is Scanning file
            done = false;
            isDataBlockFound = false;

            System.Console.WriteLine("fgetSupportData ...");

            done = false;
            while (!(done) && !(quit))
            {
                switch (MachineState)
                {
                    case MachineTurnOFF:
                        quit = true;
                        System.Console.WriteLine("Machine to be Turned OFF");
                        break;
                    case MachineScanning:
                        if (!fp.EndOfStream)
                        {
                            s = fp.ReadLine();
                            supportPtr = new clsPfSupport();

                            isDataBlockFound = isDataBlockHeaderString(s);
                            if (isDataBlockFound)
                            {
                                MachineState = DataBlockFound;
                            }
                            else
                            {

                                supportPtr.sgetData(s);
                                addSupport(supportPtr);

                                MachineState = MachineScanning;
                            }
                        }
                        else
                        {
                            done = true;
                            MachineState = MachineTurnOFF;
                        }
                        break;
                    case DataBlockFound:
                        //Signifies End of Current Data Block
                        done = true;
                        MachineState = MachineTurnOFF;
                        break;
                } //} End Select

                supportPtr = null;

            } //Loop

            lastTxtStr = s;

            System.Console.WriteLine("... fgetSupportData");

        }

        public void fgetMaterialData(StreamReader fp)
        {
            clsPfMaterial materialPtr;
            string s = "";
            string[] dataflds = new string[10]; //(0 To 9);

            int MachineState;
            bool quit; //Switch Machine OFF and Quit
            bool done; //Finished Reading File but not processing data, prepare machine to switch off
            bool isDataBlockFound;

            quit = false;
            MachineState = MachineON; //and is Scanning file
            done = false;
            isDataBlockFound = false;

            System.Console.WriteLine("fgetMaterialData ...");

            done = false;
            while (!(done) && !(quit))
            {
                switch (MachineState)
                {
                    case MachineTurnOFF:
                        quit = true;
                        System.Console.WriteLine("Machine to be Turned OFF");
                        break;
                    case MachineScanning:
                        if (!fp.EndOfStream)
                        {
                            s = fp.ReadLine();
                            materialPtr = new clsPfMaterial();

                            isDataBlockFound = isDataBlockHeaderString(s);
                            if (isDataBlockFound)
                            {
                                MachineState = DataBlockFound;
                            }
                            else
                            {

                                materialPtr.sgetData(s);
                                addMaterialGroup(materialPtr);

                                MachineState = MachineScanning;
                            }
                        }
                        else
                        {
                            done = true;
                            MachineState = MachineTurnOFF;
                        }
                        break;
                    case DataBlockFound:
                        //Signifies End of Current Data Block
                        done = true;
                        MachineState = MachineTurnOFF;
                        break;
                } //End Select

                materialPtr = null;

            } //loop

            lastTxtStr = s;

            System.Console.WriteLine("... fgetMaterialData");

        }


        public void fgetSectionData(StreamReader fp)
        {
            clsPfSection sectionPtr;
            string s = "";
            string[] dataflds = new string[10]; //(0 To 9);

            int MachineState;
            bool quit; //Switch Machine OFF and Quit
            bool done; //Finished Reading File but not processing data, prepare machine to switch off
            bool isDataBlockFound;

            quit = false;
            MachineState = MachineON; //and is Scanning file
            done = false;
            isDataBlockFound = false;

            System.Console.WriteLine("fgetSectionData ...");

            done = false;
            while (!(done) && !(quit))
            {
                switch (MachineState)
                {
                    case MachineTurnOFF:
                        quit = true;
                        System.Console.WriteLine("Machine to be Turned OFF");
                        break;
                    case MachineScanning:
                        if (!fp.EndOfStream)
                        {
                            s = fp.ReadLine();
                            sectionPtr = new clsPfSection();


                            isDataBlockFound = isDataBlockHeaderString(s);
                            if (isDataBlockFound)
                            {
                                MachineState = DataBlockFound;
                            }
                            else
                            {

                                sectionPtr.sgetData(s);
                                addSectionGroup(sectionPtr);

                                MachineState = MachineScanning;
                            }
                        }
                        else
                        {
                            done = true;
                            MachineState = MachineTurnOFF;
                        }
                        break;
                    case DataBlockFound:
                        //Signifies End of Current Data Block
                        done = true;
                        MachineState = MachineTurnOFF;
                        break;
                } //End Select


                sectionPtr = null;

            } //Loop

            lastTxtStr = s;



            System.Console.WriteLine("... fgetSectionData");

        }

        public void fgetJointLoadData(StreamReader fp)
        {
            clsPfJointLoad jloadPtr;
            string s = "";
            string[] dataflds = new string[10]; //(0 To 9);

            int MachineState;
            bool quit; //Switch Machine OFF and Quit
            bool done; //Finished Reading File but not processing data, prepare machine to switch off
            bool isDataBlockFound;

            quit = false;
            MachineState = MachineON; //and is Scanning file
            done = false;
            isDataBlockFound = false;

            System.Console.WriteLine("fgetJointLoadData ...");

            done = false;
            while (!(done) && !(quit))
            {
                switch (MachineState)
                {
                    case MachineTurnOFF:
                        quit = true;
                        System.Console.WriteLine("Machine to be Turned OFF");
                        break;
                    case MachineScanning:
                        if (!fp.EndOfStream)
                        {
                            s = fp.ReadLine();
                            jloadPtr = new clsPfJointLoad();

                            isDataBlockFound = isDataBlockHeaderString(s);
                            if (isDataBlockFound)
                            {
                                MachineState = DataBlockFound;
                            }
                            else
                            {

                                jloadPtr.sgetData(s);
                                addJointLoad(jloadPtr);

                                MachineState = MachineScanning;
                            }
                        }
                        else
                        {
                            done = true;
                            MachineState = MachineTurnOFF;
                        }
                        break;
                    case DataBlockFound:
                        //Signifies End of Current Data Block
                        done = true;
                        MachineState = MachineTurnOFF;
                        break;
                } //End Select

                jloadPtr = null;

            } //Loop

            lastTxtStr = s;


            System.Console.WriteLine("... fgetJointLoadData");

        }

        public void fgetMemberLoadData(StreamReader fp)
        {
            clsPfMemberLoad mLoadPtr;
            string s = "";
            string[] dataflds = new string[10]; //(0 To 9);

            int MachineState;
            bool quit; //Switch Machine OFF and Quit
            bool done; //Finished Reading File but not processing data, prepare machine to switch off
            bool isDataBlockFound;

            quit = false;
            MachineState = MachineON; //and is Scanning file
            done = false;
            isDataBlockFound = false;

            System.Console.WriteLine("fgetMemberLoadData ...");

            done = false;
            while (!(done) && !(quit))
            {
                switch (MachineState)
                {
                    case MachineTurnOFF:
                        quit = true;
                        System.Console.WriteLine("Machine to be Turned OFF");
                        break;
                    case MachineScanning:
                        if (!fp.EndOfStream)
                        {
                            s = fp.ReadLine();
                            mLoadPtr = new clsPfMemberLoad();

                            isDataBlockFound = isDataBlockHeaderString(s);
                            if (isDataBlockFound)
                            {
                                MachineState = DataBlockFound;
                            }
                            else
                            {

                                mLoadPtr.sgetData(s);
                                addMemberLoad(mLoadPtr);

                                MachineState = MachineScanning;
                            }
                        }
                        else
                        {
                            done = true;
                            MachineState = MachineTurnOFF;
                        }
                        break;
                    case DataBlockFound:
                        //Signifies End of Current Data Block
                        done = true;
                        MachineState = MachineTurnOFF;
                        break;
                } //End Select

                mLoadPtr = null;

            } //Loop

            lastTxtStr = s;


            System.Console.WriteLine("... fgetMemberLoadData");

        }

        public void fgetGravityLoadData(StreamReader fp)
        {
            clsPfGravityLoad gLoadPtr;
            string s = "";
            string[] dataflds = new string[10]; //(0 To 9);

            int MachineState;
            bool quit = false; //Switch Machine OFF and Quit
            bool done; //Finished Reading File but not processing data, prepare machine to switch off
            bool isDataBlockFound;
            bool isUseDefaultData;

            System.Console.WriteLine("fgetGravityLoadData ...");

            isDataBlockFound = false;
            if (!fp.EndOfStream)
            {
                quit = false;
                MachineState = MachineON; //and is Scanning file
                done = false;
                isUseDefaultData = false;
            }
            else
            {
                done = true;
                MachineState = MachineTurnOFF;
                isUseDefaultData = true;
            }

            while (!(done) && !(quit))
            {
                switch (MachineState)
                {
                    case MachineTurnOFF:
                        quit = true;
                        System.Console.WriteLine("Limit State File Parser Machine to be Turned OFF");
                        break;

                    case MachineScanning:
                        if (!fp.EndOfStream)
                        {
                            s = fp.ReadLine();
                            gLoadPtr = new clsPfGravityLoad();

                            isDataBlockFound = isDataBlockHeaderString(s);
                            if (isDataBlockFound)
                            {
                                MachineState = DataBlockFound;
                            }
                            else
                            {

                                gLoadPtr.sgetData(s);
                                addGravityLoad(gLoadPtr);

                                MachineState = MachineScanning;
                            }
                        }
                        else
                        {
                            System.Console.WriteLine("... End of File");
                            done = true;
                            MachineState = MachineTurnOFF;
                        }
                        break;

                    case DataBlockFound:
                        //Signifies End of Current Data Block
                        done = true;
                        MachineState = MachineTurnOFF;
                        break;

                } //End Select

                gLoadPtr = null;

            } //Loop

            if (!fp.EndOfStream)
            {
                lastTxtStr = s;
            }
            else
            {
                lastTxtStr = "";
            }

            if (isUseDefaultData)
            {
                System.Console.WriteLine("Using Default Data");
                // addGravityLoad(2, -9.81);
            }

            //File Data Ignored
            //Default Values Used Only

            System.Console.WriteLine("... fgetGravityLoadData");
        }


        //Limit State Machine: File Parser
        //File format to match requirements for F_wrk.exe (With File Date Modified = Friday, 23 August 1996, 13:18:04)
        public void pframeReader00(StreamReader fp)
        { //begin function

            string dataCtrlBlk = "";

            int MachineState;
            bool quit;
            bool done;
            bool isDataBlockFound;
            string s;

            System.Console.WriteLine("pframeReader00 ...");

            s = "";
            MachineState = MachineON; //and is Scanning file
            quit = false;
            done = false;
            isDataBlockFound = false;

            //System.Console.WriteLine("Machine Should start Scanning:");
            while (!(done) && !(quit))
            {
                System.Console.WriteLine("Machine ON: Scanning Started");
                System.Console.WriteLine("Machine State: {0}", MachineState);
                switch (MachineState)
                {
                    case MachineTurnOFF:

                        quit = true;
                        System.Console.WriteLine("Machine to be Turned OFF");
                        break;

                    case MachineScanning:
                        System.Console.WriteLine("Machine Scanning ...");
                        if (!fp.EndOfStream)
                        {
                            System.Console.WriteLine("Reading File ...");
                            s = fp.ReadLine();
                            isDataBlockFound = isDataBlockHeaderString(s);

                            System.Console.WriteLine("<{0}>", s);
                            System.Console.WriteLine("machine scanning ...");

                            if (isDataBlockFound)
                            {
                                MachineState = DataBlockFound;
                            }
                            else
                            {
                                MachineState = MachineScanning;
                            }
                        }
                        else
                        {
                            System.Console.WriteLine("<EndOfStream>");
                            done = true;
                            MachineState = MachineTurnOFF;
                        }
                        break;
                    case DataBlockFound:
                        System.Console.WriteLine("DataBlockFound:MAIN " + s);
                        s = s.Substring(0, s.Length - 2).Trim().ToUpper();
                        dataCtrlBlk = s;
                        MachineState = RecognisedSection;
                        break;

                    case RecognisedSection:

                        switch (dataCtrlBlk)
                        {
                            case "JOB DETAILS":  //Alternative to Job Data
                                System.Console.WriteLine("1[" + dataCtrlBlk + "]");
                                ProjectData.fgetData(fp);
                                MachineState = MachineScanning;
                                break;

                            case "JOB DATA": //Alternative to Job Details
                                System.Console.WriteLine("2[" + dataCtrlBlk + "]");
                                ProjectData.fgetData(fp);
                                MachineState = MachineScanning;
                                break;

                            case "CONTROL DATA":
                                System.Console.WriteLine("3[" + dataCtrlBlk + "]");
                                structParam.initialise();
                                structParam.fgetData(fp, true);
                                MachineState = MachineScanning;
                                structParam.nr = 0;
                                System.Console.WriteLine("structParam.nr : " + structParam.nr.ToString());
                                break;

                            case "NODES":
                                System.Console.WriteLine("4[" + dataCtrlBlk + "]");
                                fgetNodeData(fp);
                                s = lastTxtStr;
                                MachineState = DataBlockFound;
                                //MachineState = MachineScanning;
                                break;

                            case "MEMBERS":
                                System.Console.WriteLine("5[" + dataCtrlBlk + "]");
                                fgetMemberData(fp); // s);
                                s = lastTxtStr;
                                MachineState = DataBlockFound;
                                break;

                            case "SUPPORTS":
                                System.Console.WriteLine("6[" + dataCtrlBlk + "]");
                                fgetSupportData(fp);
                                s = lastTxtStr;
                                MachineState = DataBlockFound;
                                //MachineState = MachineScanning;
                                break;

                            case "MATERIALS":
                                System.Console.WriteLine("7[" + dataCtrlBlk + "]");
                                fgetMaterialData(fp);
                                s = lastTxtStr;
                                MachineState = DataBlockFound;
                                break;

                            case "SECTIONS":
                                System.Console.WriteLine("8[" + dataCtrlBlk + "]");
                                fgetSectionData(fp);
                                s = lastTxtStr;
                                MachineState = DataBlockFound;
                                break;

                            case "JOINT LOADS":
                                System.Console.WriteLine("9[" + dataCtrlBlk + "]");
                                fgetJointLoadData(fp);
                                s = lastTxtStr;
                                MachineState = DataBlockFound;
                                break;

                            case "MEMBER LOADS":
                                System.Console.WriteLine("10[" + dataCtrlBlk + "]");
                                fgetMemberLoadData(fp);
                                s = lastTxtStr;
                                if (!fp.EndOfStream)
                                {
                                    MachineState = DataBlockFound;
                                }
                                else
                                {
                                    MachineState = MachineTurnOFF;
                                }
                                break;

                            case "GRAVITY LOADS":
                                System.Console.WriteLine("11[" + dataCtrlBlk + "]");
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
                        if (fp.EndOfStream)
                        {
                            System.Console.WriteLine("DataBlockFound: End Of File");
                            done = true;
                            MachineState = MachineTurnOFF;
                        }
                        else
                        {
                            MachineState = MachineScanning;
                        }
                        break;

                } // Switch: machine state

            } //Loop

            System.Console.WriteLine("... pframeReader00");

        } // End Function


        public void fgetDataTest(StreamReader fp)
        {
            string s;
            System.Console.WriteLine("fgetDataTest ...");

            while (!fp.EndOfStream)
            {
                s = fp.ReadLine();
                System.Console.WriteLine("<{0}>", s);
            }
            fp.Close();
            System.Console.WriteLine("... fgetDataTest");
        }


        //DATA FILE STORE SUBROUTINES
        //------------------------------------------------------------------------------

        public void SaveDataToTextFile(StreamWriter fp)
        {
            int i;

            System.Console.WriteLine("SaveDataToTextFile ...");
            fp.WriteLine("JOB DATA" + dataBlockTag);
            ProjectData.fprint(fp);

            //NB: It some versions of original Pascal application require screen magnification factor
            //other versions don//t. if needed and not present the program will crash. if not needed but
            //is present it is simply ignored. Therefore always write to the file.
            fp.WriteLine("CONTROL DATA" + dataBlockTag);
            structParam.fprint(fp);

            fp.WriteLine("NODES" + dataBlockTag);
            for (i = baseIndex; i < nod_grp.Length; i++)
            {
                nod_grp[i].fprint(fp);
            }

            fp.WriteLine("MEMBERS" + dataBlockTag);
            for (i = baseIndex; i < con_grp.Length; i++)
            {
                con_grp[i].fprint(fp);
            }

            fp.WriteLine("SUPPORTS" + dataBlockTag);
            for (i = baseIndex; i < sup_grp.Length; i++)
            {
                sup_grp[i].fprint(fp);
            }

            fp.WriteLine("MATERIALS" + dataBlockTag);
            for (i = baseIndex; i < mat_grp.Length; i++)
            {
                mat_grp[i].fprint(fp);
            }

            fp.WriteLine("SECTIONS" + dataBlockTag);
            for (i = baseIndex; i < sec_grp.Length; i++)
            {
                sec_grp[i].fprint(fp);
            }

            fp.WriteLine("JOINT LOADS" + dataBlockTag);
            System.Console.WriteLine("njl= ", structParam.njl);
            for (i = baseIndex; i < jnt_lod.Length; i++)
            {
                jnt_lod[i].fprint(fp);
            }

            fp.WriteLine("MEMBER LOADS" + dataBlockTag);
            for (i = baseIndex; i < mem_lod.Length; i++)
            {
                mem_lod[i].fprint(fp);
            }


            fp.WriteLine("GRAVITY LOADS" + dataBlockTag);

            fp.Close();

            System.Console.WriteLine("... SaveDataToTextFile");

        }

    } //class
} //name space
