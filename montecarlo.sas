%LET N = 5;
%LET m = 10;
%LET seed = 1;

DATA simu;
	ATTRIB i LABEL = "Sample" j LABEL = "Observation" x LABEL = "Value";
	DO i = 1 TO &m;
		DO j = 1 TO &N;
			x = ranuni(&seed);
			OUTPUT;
		END;
	END;
RUN;

PROC MEANS DATA = simu NOPRINT;
	BY i;
	VAR x;
	OUTPUT OUT = mc(DROP = _TYPE_ _FREQ_ ) MEAN = mx;
RUN;

PROC UNIVARIATE DATA = WORK.mc NOPRINT;
	HISTOGRAM mx / NORMAL VAXISLABEL = "Frequency" CBARLINE = GREEN;
	INSET N = "Number of samples" MEAN = "Monte Carlo estimate" VAR = "Mean square error";
RUN;

PROC IML;
	x = J(&m,&n);
	CALL RANUNI(&seed,x);
	s = x[,:];
	M = MEAN(s);
	PRINT "Sample mean",M;
QUIT;
