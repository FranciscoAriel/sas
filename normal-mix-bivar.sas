PROC IML;
	x = J(250,1,0);
	mu1 = {0 15};
	v1 = {1 10};
	p1 = {0.3 0.7};
	CALL SRTEAMINIT(123);
	CALL RANDGEN(x,"NORMALMIX",p1,mu1,v1);
	y = J(250,1,0);
	mu2 = {3 10 25};
	v2 = {3 4 5};
	p2 = {0.5 0.4 0.1};
	CALL RANDGEN(y,"NORMALMIX",p2,mu2,v2);
	xx = x || y;
	CREATE Xbivar FROM xx [COLNAME = {"x1","x2"}];
	APPEND FROM xx;
	CLOSE;
QUIT;
PROC KDE DATA = xbivar;
	UNIVAR x1 x2/PLOTS = HISTDENSITY ;
	BIVAR x1 x2 / OUT = salida PLOTS = (CONTOURSCATTER);
RUN;

PROC g3d DATA = salida;
PLOT value2*value1 = density;
RUN;
QUIT;
