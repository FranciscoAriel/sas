
PROC IML;
	CALL RANDSEED(123);
	n=200;
	mu = {5 10};
	sigma2 = {5 3,3 4};
	x = RANDNORMAL(n,mu,sigma2);
	START dmvnormal(x,mu,cov);
		p = NROW(cov);
		k = (2 # CONSTANT("PI"))##(p/2)*SQRT(DET(cov));
		d = mahalanobis(x, mu, cov);
		fx = EXP(-d##2/2)/k;
		return(fx);
	FINISH;
	fx = dmvnormal(x,mu,sigma2);
	x = x || fx;
	CREATE Xbivar FROM x [COLNAME = {"x1","x2","fx"}];
	APPEND FROM x;
	CLOSE;
QUIT;

PROC KDE DATA = xbivar;
	BIVAR x1 x2 / OUT = salida PLOTS = (CONTOURSCATTER);
RUN;

PROC G3D DATA = xbivar;
	SCATTER x2*x1=fx / SHAPE = "BALLOON" NONEEDLE ROTATE = 120;
RUN;
QUIT;

PROC G3d DATA = salida;
	PLOT value2*value1=density;
RUN;
QUIT;