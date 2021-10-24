{###### MATHFUN.UNI ######
 ...a unit file of maths utility routines...
    trig functions added 15/1/88 ...
    Version 1.1 -- last modified 11/88  --  R G Harrison . . .}

UNIT Mathfun;
INTERFACE
{
 ...Variable declarations...
}
VAR
   mcerr, theta : REAL;

FUNCTION Machinerror : REAL;
FUNCTION Pow(base,expo : REAL) : REAL;
FUNCTION Radians(theta : REAL):REAL;
FUNCTION Degrees(theta : REAL):REAL;
FUNCTION DiffSq(theta : REAL):REAL;
FUNCTION Tan(theta : REAL):REAL;
FUNCTION Cot(theta : REAL):REAL;
FUNCTION Cosec(theta : REAL):REAL;
FUNCTION Sec(theta : REAL):REAL;
FUNCTION ArcSin(sintheta : REAL):REAL;
FUNCTION ArcCos(costheta : REAL):REAL;
FUNCTION Atan2(x,y : REAL) : REAL;

IMPLEMENTATION
  {
  <<< Machinerror >>>
  ...a function to return the machine error or accuracy...
  }
  FUNCTION Machinerror : REAL;
  VAR eps : REAL;
  BEGIN
    eps := 1.0;
    WHILE eps + 1.0 > 1.0
      DO eps := eps/2.0;
    Machinerror := 2.0 * eps;
  END;          {...Machinerror..}
  {
  <<< Pow >>>
  ...A function to return the power of any base and mantissa ..
  ..  i.e. base^expo ...
  }
  FUNCTION Pow(base,expo : REAL) : REAL;
  VAR tmp : REAL;
      i : INTEGER;
  BEGIN
    IF ABS(base) > mcerr THEN
      tmp := EXP(expo * LN(ABS(base)))
    ELSE
      tmp := 0;

    IF base < 0 THEN
      IF expo = TRUNC(expo) THEN
        BEGIN
          IF TRUNC(expo) MOD 2 <> 0 THEN
            tmp := -tmp;
        END
      ELSE
        BEGIN
          WRITELN('Root of negative number attempted ERROR');
          HALT;
        END;
    Pow := tmp;
  END;    {...Pow...}
  {
  <<< Radians >>>
  ... a function to return theta in radians argument in degrees...
  }
  FUNCTION Radians(theta : REAL):REAL;
  BEGIN {..Radians..}
    Radians := theta * PI / 180;
  END;  {..Radians..}
  {
  <<< Degrees >>>
  ... a function to return theta in degrees argument in radians...
  }
  FUNCTION Degrees(theta : REAL):REAL;
  BEGIN {..Degrees..}
    Degrees := 180 * theta / PI;
  END;  {..Degrees..}
  {
  <<< DiffSq >>>
  ... a function to return Cos or Sin theta in radians
      argument in radians...
  }
  FUNCTION DiffSq(theta : REAL):REAL;
  BEGIN {..DiffSq..}
    DiffSq := SQRT(1 - SQR(theta));
  END;  {..DiffSq..}
  {
  <<< Tan >>>
  ... a function to return Tan argument in radians...
  }
  FUNCTION Tan(theta : REAL):REAL;
  BEGIN {..Tan..}
    Tan := SIN(theta)/COS(theta);
  END;  {..Tan..}
  {
  <<< Cot >>>
  ... a function to return Cot argument in radians...
  }
  FUNCTION Cot(theta : REAL):REAL;
  BEGIN {..Cot..}
    Cot := 1/Tan(theta);
  END;  {..Cot..}
  {
  <<< Cosec >>>
  ... a function to return Cosec argument in radians...
  }
  FUNCTION Cosec(theta : REAL):REAL;
  BEGIN {..Cosec..}
    Cosec := 1/SIN(theta);
  END;  {..Cosec..}
  {
  <<< Sec >>>
  ... a function to return Sec argument in radians...
  }
  FUNCTION Sec(theta : REAL):REAL;
  BEGIN {..Sec..}
    Sec := 1/COS(theta);
  END;  {..Sec..}
  {
  <<< ArcSin >>>
  ... a function to return theta in radians argument Sin ...
  }
  FUNCTION ArcSin(sintheta : REAL):REAL;
  BEGIN {..ArcSin..}
    ArcSin := ARCTAN(sintheta / DiffSq(sintheta));
  END;  {..ArcSin..}
  {
  <<< ArcCos >>>
  ... a function to return theta in radians argument Cos ...
  }
  FUNCTION ArcCos(costheta : REAL):REAL;
  BEGIN {..ArcCos..}
    ArcCos := ARCTAN(DiffSq(costheta) / costheta);
  END;  {..ArcCos..}
  {
  <<< Atan2 >>>
  ... a 4-quadrant arc tangent function of argument y/x  to return
      theta in radians. Similar to LOTUS 1-2-3 @ATAN2 function
      and Fortran 77 ATAN2 function. NB The F77 version has the
      quotient reversed ! ...
  }
  FUNCTION Atan2(x,y : REAL) : REAL;

    FUNCTION At2(x,y,sig : REAL) : REAL;
    BEGIN
      IF x = 0 THEN
        At2 := sig * PI/2
      ELSE
        IF x > 0 THEN
          At2 := ARCTAN(y/x)
        ELSE
          At2 := ARCTAN(y/x) + sig * PI;
    END;

  BEGIN
    IF (x = 0) AND (y = 0) THEN
        WRITELN('Error !!!')
    ELSE
      IF y >= 0 THEN
        Atan2 := At2(x,y,1)
      ELSE
        Atan2 := At2(x,y,-1)
  END;  {.. Atan2 ..}
BEGIN
  mcerr := Machinerror;
END.  {...Mathfun Unit...}

  {
  <<< Power >>>
  ...A function to return the power of any base and mantissa ..
  ..  i.e. base^expo ...
  }
  FUNCTION Power(base,expo : REAL) : REAL;
  BEGIN
    IF base > machinerror THEN
      Power := EXP(expo * LN(base))
    ELSE
      Power := 0;
  END;    {...Power...}

