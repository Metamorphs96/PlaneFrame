//
// Copyright (c)2016 S C Harrison
// Refer to License.txt for terms and conditions of use.
//
using System;
using System.Collections.Generic;
using System.Text;
using System.IO;

namespace w7cpframe
{
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


        public string sprint()
        {
            string s;

            s = "";
            s = s + axial.ToString().PadLeft( 8);
            s = s + shear.ToString().PadLeft( 8);
            s = s + momnt.ToString().PadLeft( 8);

            return s;

        }



        public void cprint()
        {
            System.Console.WriteLine(sprint());
        }




    } //class
} //name space
