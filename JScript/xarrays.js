//
// Copyright (c)2014 S C Harrison
// Refer to License.txt for terms and conditions of use.
//


function fprintMatrix(R2Matrix) {
    var i, j;
    var tmpValue, tmpStr;
    
    for(i=0;i<R2Matrix.length;i++){
      //WScript.Echo(R2Matrix[i].length);
      fpTracer.Write(StrLPad(i.toString(),3));
      for(j=0;j<R2Matrix[i].length;j++){
        tmpValue = R2Matrix[i][j];
        tmpValue = tmpValue.toFixed(4)
        //if(!tmpValue) fpTracer.Write(i,j,tmpValue);
        // fpTracer.WriteLine(i + ":" + j + ":" + tmpValue);
        tmpStr = "[" + StrLPad(tmpValue.toString(),15) + "]";
        tmpStr = StrLPad(tmpValue.toString(),15);
        fpTracer.Write(tmpStr);
      }
     fpTracer.WriteLine();
    }
}

function fprintVector(Vector) {
    var i;
    var tmpValue, tmpStr;
    
    for(i=0;i<Vector.length;i++){
        tmpValue = Vector[i];
        tmpValue = tmpValue.toFixed(4)
        tmpStr = StrLPad(tmpValue.toString(),15);
        fpTracer.Write(tmpStr);
    }
}
