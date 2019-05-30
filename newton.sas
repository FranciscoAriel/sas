/*------------------------------------------------------------------------------\
|	This programme estimates parameters from normal distribution		|
|	using Newton-Raphson algorithm with Fisher scoring.			|
|										|
|	You can modify the parameter mu and standard deviation also number	|
|	of iterations and convergence criterion, seed. Initial values should    |
|	be close to true parameters.						|
\------------------------------------------------------------------------------*/

%LET n = 500;
%LET mu = 5;
%LET sd = 2;
%LET nmax = 100;
%LET eps = 0.0001;
%LET semilla = 3;
%LET inimu = 5.5;
%LET iniv = 3.5;

/* Simulate 100 random variables*/
DATA x;
	DROP i;
	DO i = 1 TO &n;
		CALL STREAMINIT(&semilla);
		x = RAND("NORMAL",&mu,&sd);
		OUTPUT;
	END;
RUN;
PROC MEANS DATA = x N MEAN STD;
RUN;
PROC IML;
	/* Import read data*/
	TITLE "Newton-Raphson algorithm with Fisher scoring";
	USE x;
	READ ALL;
	n = &n;
	ini1 = &inimu;
	ini2 = &iniv;
	inicial = ini1 // ini2;
	nmax = &nmax;
	eps = &eps;
	START newton(inicial) GLOBAL (n,x,nmax,eps);
		ini = inicial;
		MATTRIB ini ROWNAME = {"Mean","Variance"} LABEL = "Initial values";
		in1 = inicial[1];
		in2 = inicial[2];
		obj1 = -n/2#LOG(in2)-1/(2#in2)#(T(x-in1)*(x-in1));
		MATTRIB obj1 LABEL = "Initial Log-likelihood";
		i = 0;
		diff = 1;
		history = J(1,5);
		DO WHILE ( i < &nmax & diff > &eps);
			m = inicial[1];
			v = inicial[2];
			/* Gradient */
			sc1 = 1/v*SUM(x-m);
			sc2 = (T(x-m)*(x-m))/(2#v##2)-(n/(2#v));
			score = sc1 // sc2;
			/* Variance-covariance matrix */
			h11 = v/n;
			h22 = 2*v##2/n;
			h = h11 || h22;
			info = DIAG(h);
			final = inicial+info*score;
			diff = MAX(ABS(final-inicial));
			i = i + 1;
			a = final[1];
			b = final[2];
			logv = -n/2#LOG(b)-1/(2#b)#(T(x-a)*(x-a));
			story = story // (i || logv || diff || a || b);
			inicial = final;
		END;
		se1 = SQRT(info[1,1]);
		se2 = SQRT(info[2,2]);
		est1 = final[1];
		est2 = final[2];
		result = (est1 || se1)// (est2 || se2);
		IF diff < eps THEN status = "Converged";
		ELSE status = "Not converged";
		MATTRIB i LABEL = "Iteration";
		MATTRIB status LABEL = "Status";
		MATTRIB result COLNAME={"Estimate","Standard error"} 
				ROWNAME={"Mean", "Variance"} LABEL = "Estimation";
		MATTRIB story 
				COLNAME = {"Iteration","Log likelihood","Criterion","Mean","Variance"}
				LABEL = "Iterations story";
		PRINT ini,obj1,i,story,status, result;
		IF (n > 50) THEN 
			DO;
				li1 = est1 - se1#QUANTILE("NORMAL",.975);
				ls1 = est1 + se1#QUANTILE("NORMAL",.975);
				li2 = est2 - se2#QUANTILE("NORMAL",.975);
				ls2 = est2 + se2#QUANTILE("NORMAL",.975);
				PRINT "Normal distribution assumed";
			END;
		ELSE 
			DO;
				li1 = est1 - se1#QUANTILE("T",.975,n-1);
				ls1 = est1 + se1#QUANTILE("T",.975,n-1);
				li2 = (n-1)#est2 / QUANTILE("CHISQ",.975,n-1);
				ls2 = (n-1)#est2 / QUANTILE("CHISQ",.025,n-1);
				PRINT "Exact confidence interval computed";
			END;
		;
		ic1 = li1 || ls1;
		ic2 = li2 || ls2;
		ic = ic1 // ic2;
		MATTRIB ic LABEL = "95% confidence interval" 
				COLNAME = {"Lower","Upper"} ROWNAME={"Mean", "Variance"};
		PRINT ic;
	FINISH;
	CALL newton(inicial);
	TITLE;
QUIT;
