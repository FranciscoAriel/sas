DATA abc;
	DO i = -0.4 TO 0.4 BY 0.1;
		DO j = 0.6 TO 3 BY 0.1;
			OUTPUT;
		END;
	END;
RUN;
PROC IML;
	n = 1000;
	x = J(n,1);
	CALL RANDGEN(x,"NORMAL");
	USE abc;
	READ ALL VAR _ALL_;
	m = NROW(i);
	k = J(m,1,.);
	START loglike(mu,v) GLOBAL (n,x);
		lv = -n/2#LOG(v)-1/(2#v)#(T(x-mu)*(x-mu));
		RETURN (lv);
	FINISH;
	DO a = 1 TO m;
		mui = i[a,];
		vi = j[a,];
		k[a,] = loglike(mui,vi);
	END;
	x = i || j || k;
	CREATE datos FROM x[COLNAME ={"mu","v","logvero"}];
	APPEND FROM x;
QUIT;
TITLE "Log-likelihood function";
TITLE2 "Normal standard distribution";
PROC G3D DATA = datos;
	PLOT mu*v=logvero / ROTATE = 30;
RUN;
QUIT;
symbol1 value="Low"
        color=navy
        height=.6;
symbol7 value="High"
        color=red 
        height=.7;

PROC GCONTOUR DATA = datos;
	PLOT mu*v=logvero / autolabel=(check=none);
RUN;
QUIT;
