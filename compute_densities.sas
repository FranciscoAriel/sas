DATA density;
	DO x = -3 TO 3 BY .1;
		y = PDF("NORMAL",x);
		z = PROBNORM(x);
		OUTPUT;
	END;
RUN;

SYMBOL1
	INTERPOL = JOIN
	HEIGHT = 10pt
	VALUE = NONE
	LINE = 1
	WIDTH = 2
;
Axis1
	WIDTH = 1
	MINOR = NONE
	LABEL = ( "Density" )
;
Axis2
	WIDTH = 1
	MINOR = NONE
;
TITLE;
TITLE1 "Normal standard density";
FOOTNOTE;
FOOTNOTE1 "Created with the PDF() function";

PROC GPLOT DATA = density;
	PLOT y * x  /
 	VAXIS=AXIS1
	HAXIS=AXIS2
	FRAME;
RUN;
QUIT;

SYMBOL1
	INTERPOL = JOIN
	HEIGHT = 10pt
	VALUE = NONE
	LINE = 1
	WIDTH = 2
;
Axis1
	WIDTH = 1
	MINOR = NONE
	LABEL = ( "Probability" )
;
Axis2
	WIDTH = 1
	MINOR = NONE
;
TITLE;
TITLE1 "Normal standard distribution";
FOOTNOTE;
FOOTNOTE1 "Created with the PROBNORM() function";

PROC GPLOT DATA = density;
	PLOT z * x  /
 	VAXIS=AXIS1
	HAXIS=AXIS2
	FRAME;
RUN;
QUIT;
