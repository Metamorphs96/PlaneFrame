//
// Copyright (c)2014 S C Harrison
// Refer to License.txt for terms and conditions of use.
//


function cMain() {


    //
    // Test arrays
    //

    var i,j,k;
    var aa = [];
    var bb = [];
    var rot_mat=[];
    var xm,ym;
    var mlen = [];
    var tmpValue, tmpStr;
    
    WScript.Echo("Test Matrices in JavaScript/JScript ...");
    
    WScript.Echo("aa[]...");
    for(i=0;i<2;i++){
      
      aa[i] = (i+3)*2;
      WScript.Echo(aa[i]);
      
    }
    WScript.Echo("-------------");

    k=0;
    WScript.Echo("bb[][]...");
    for(i=0;i<2;i++){
      bb[i] = new Array();
      
      for(j=0;j<2;j++){
        k = k +1;
        
        bb[i][j] = k;
        tmpValue = bb[i][j];
        WScript.Echo(tmpValue);
      }
    }



    // xm=12;
    // ym=15;
    // mlen[0]=5;
    // mlen[1]=7;

    // WScript.Echo("----------------");
    // WScript.Echo("rot_mat[][] ...");
    // for(i=0;i<2;i++){
        // rot_mat[i] = new Array();
        // rot_mat[i][0] = xm / mlen[i]; //.. Cos
        // rot_mat[i][1] = ym / mlen[i]; //.. Sin
        
        // WScript.Echo(rot_mat[i][0]);
        // WScript.Echo(rot_mat[i][1]);
        // WScript.Echo("----------------");
    // }
    
    TraceFName = "matrix.trc"
    fpTracer = fopenTXT(TraceFName,"wt",true);
    if (fpTracer != null) {
      fpTracer.WriteLine("Test Matrices ...");
      
      WScript.Echo("bb[i][j] ...",bb.length);
      for(i=0;i<2;i++){
          WScript.Echo(bb[i].length);
          for(j=0;j<2;j++){
            tmpValue = bb[i][j];
            //WScript.Echo(i,j,tmpValue);
            //WScript.Echo(i,j,bb[i][j].length);
            tmpStr = StrLPad(tmpValue.toString(),15);
            fpTracer.Write(tmpStr);
          }
         fpTracer.WriteLine();
      }
       
       fpTracer.WriteLine("... Test Matrices");
    }
    
    
    fpTracer.WriteLine("aa[]");
    fprintVector(aa);
    fpTracer.WriteLine();
    
    fpTracer.WriteLine("bb[][]");
    fprintMatrix(bb);
    
    var v_size=10;
    var fc=[]; 
    for(i=0;i<v_size;i++) {
        fc[i] = i;
    }
    fpTracer.WriteLine("fc[]");
    fprintVector(fc);
    fpTracer.WriteLine();
    
    var kc = new Array(5);
    
    WScript.Echo(kc.length);
    for(i=0;i<kc.length;i++) {
        kc[i] = i;
    }
    fpTracer.WriteLine("kc[]");
    fprintVector(kc);
    fpTracer.WriteLine(); 
    
    WScript.Echo();
    WScript.Echo("Count Up");
    for(i=0;i<12;i++) {
        WScript.Echo(i);
    }
    
    WScript.Echo();
    WScript.Echo("Count Down");
    for(i=11;i>=0;i--) {
        WScript.Echo(i);
    }   
    
    // WScript.Echo(bb.length);
    // WScript.Echo(bb[0].length);
    

    WScript.Echo("... Test Matrices in JavaScript/JScript");
    WScript.Echo("All Done!");

}
