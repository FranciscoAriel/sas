PROC IML;
	TITLE "Box - Muller Transformation";
	n = 1000000;
	u1 = J(n,1);
	u2 = J(n,1);
	CALL RANDGEN(u1,"UNIFORM");
	CALL RANDGEN(u2,"UNIFORM");
	R = SQRT(-2#LOG(u1));
	theta = 2#CONSTANT("PI")#u2;
	X = R#COS(theta);
	Y = R#SIN(theta);
	xy = x || y;
	z = x+y/sqrt(2);
	xyz = xy || z;
	CREATE datos FROM xyz[COLNAME = {"X","Y","Z"}];
	APPEND FROM xyz;
QUIT;
PROC SGPLOT DATA = datos;
	HISTOGRAM z;
	DENSITY z;
RUN;
