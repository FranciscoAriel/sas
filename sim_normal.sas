/* --- MACRO VARIABLE --- */
%LET N = 100;
/* --- Create data set "WORK.NORMAL" --- */
DATA Normal(keep=x);
	/* --- Set the seed value --- */
	CALL streaminit(123);
	/* --- DO loop: do from 1 to 100 ... --- */
	DO i = 1 to &N;
		/* --- Simulate a normal standard variable --- */
		x = rand("NORMAL");
		/* write to data set --- */
		OUTPUT;
	/* --- Close the loop --- */
	END;
	/* (These line can be ommited) */
	*%PUT Version  &SYSVER;
	RETURN;
/* (This line should be always written) */
RUN;
PROC PRINT DATA = Normal(OBS=5);
RUN;

/* --- Histogram ---*/
PROC UNIVARIATE DATA = WORK.NORMAL NOPRINT;
	HISTOGRAM x / NORMAL VAXISLABEL = "Frequency" CBARLINE = GREEN;
RUN;

SYMBOL V = dot C = BLUE;
TITLE;
TITLE1 "QQ Plot";
FOOTNOTE;
FOOTNOTE1 "Comparison between actual and simulated values";

PROC UNIVARIATE DATA = normal NOPRINT;
	QQPLOT x;
RUN;

PROC SORT DATA = normal;
	BY x;
RUN;

DATA normal;
	SET normal;
	i = _N_/&N;
	z = PROBIT(i);
RUN;

SYMBOL1 V = dot C = BLUE;
SYMBOL2 C = RED;
LEGEND1	LABEL = NONE VALUE = ("Simulated" "Actual");
TITLE;
TITLE1 "Empirical cumulative density function";
FOOTNOTE;
FOOTNOTE1 "Comparison between actual and simulated values";

PROC GPLOT DATA = normal;
	PLOT x*i z*i /OVERLAY LEGEND = LEGEND1;
RUN;
QUIT;
FOOTNOTE;
/* --- Using SAS/IML --- */

PROC IML;
	X = J(100,1,.);
	CALL RANDGEN(x,"NORMAL");
	/* version 9.0 uses CALL RANNOR(1,X);*/
	PRINT X;
QUIT;

/* --- Simulating a multivariate normal distribution ---*/
PROC IML;
	CALL RANDSEED(123);
	n=500;
	mu = {5 10 20};
	sigma2 = {2 1 2,1 3 3,2 3 4};
	TITLE "Multivariate Normal distribution";
	print "Parameters",mu,sigma2;
	x = RANDNORMAL(n,mu,sigma2);
	CREATE trivar FROM x [COLNAME = {"x1","x2","x3"}];
	APPEND FROM x;
	CLOSE;
QUIT;

PROC G3D DATA = trivar;
	TITLE "Normal Trivariada";
	SCATTER x2*x1=x3 / noneedle rotate = 120 SHAPE = "BALLOON";
RUN;
QUIT;