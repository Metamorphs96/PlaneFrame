//
// Copyright (c)2016 S C Harrison
// Refer to License.txt for terms and conditions of use.
//

//import java.io.*;


    class clsPfForce
    {


        public double axial = 0;        //.. axial force ..
        public double shear = 0;        //.. shear force ..
        public double momnt = 0;         //.. end moment ..



        public void initialise()
        {
            axial = 0;
            shear = 0;
            momnt = 0;
        }


        public String sprint()
        {
            String s;

            s = "";
            s = s + String.format("%12.48f",axial);
            s = s + String.format("%12.48f",shear);
            s = s + String.format("%12.48f",momnt);

            return s;

        }



        public void cprint()
        {
            System.out.println(sprint());
        }




    } //class

