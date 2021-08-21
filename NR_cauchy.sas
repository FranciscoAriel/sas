/*----------------------------------------------------------------------\
|  This programme estimates parameters from cauchy distribution         |
|  using Newton-Raphson algorithm.                 						|
|                                                                       |
|  You can modify the location parameter, number of iterations and      |
|   convergence criterion, seed. Initial values should be close to true |
|   parameters.                                                         |
\----------------------------------------------------------------------*/

%LET n = 5;
%LET mu = 0;
%LET nmax = 100;
%LET eps = 0.0001;
%LET semilla =4;
%LET inimu = 0;
%LET xmin = -3;
%LET xmax = 3;
options nodate;
ods noproctitle;
/* Simulate 100 random variables*/
DATA x;
  DROP i y;
  DO i = 1 TO &n;
    CALL STREAMINIT(&semilla);
    y = RAND("CAUCHY");
    x=y+&mu;
    OUTPUT;
  END;
RUN;
PROC IML;
  /* Import read data*/
  TITLE "Newton-Raphson algorithm";
  USE x;
  READ ALL;
  n = &n;
  ini1 = &inimu;
  inicial = ini1;
  nmax = &nmax;
  eps = &eps;
  START newton(inicial) GLOBAL (n,x,nmax,eps);
    ini = inicial;
    MATTRIB ini ROWNAME = {"Guess"} LABEL = "Initial values";
    obj1 = -n#LOG(CONSTANT("PI"))+SUM(1/((x-ini)##2+1));
    MATTRIB obj1 LABEL = "Initial Log-likelihood";
    i = 0;
    diff = 1;
    history = J(1,4);
    DO WHILE ( i < &nmax & diff > &eps);
      m = inicial;
      /* Gradient */
      score = SUM((2*(x-m))/((x-m)##2+1));
      /* Variance-covariance matrix */
      info = SUM((2*(x-m)##2-2)/((x-m)##2+1)##2);
      final = inicial-score/info;
      diff = MAX(ABS(final-inicial));
      i = i + 1;
      logv = -n#LOG(CONSTANT("PI"))+SUM(1/((x-final)##2+1));
      story = story // (i || logv || diff || final);
      inicial = final;
    END;
    result = final;
    IF diff < eps THEN status = "Converged";
    ELSE status = "Not converged";
    MATTRIB i LABEL = "Iteration";
    MATTRIB status LABEL = "Status";
    MATTRIB result COLNAME={"Estimate"} 
        ROWNAME={"Location Parameter"} LABEL = "Estimation";
    MATTRIB story 
        COLNAME = {"Iteration","Log likelihood","Criterion","Estimate"}
        LABEL = "Iterations story";
    PRINT ini,obj1,i,story,status, result;
  FINISH;
  CALL newton(inicial);
  TITLE;
QUIT;

PROC IML;
	USE x;
	READ ALL;
	n = &n;
	START llike(m) GLOBAL(n,x);
		ll = -n#LOG(CONSTANT("PI"))+SUM(1/((x-m)##2+1));
		RETURN(ll);
	FINISH;
	loc = DO(&xmin,&xmax,.1);
    len = NCOL(loc);
    y=J(len,1,.);
	DO i = 1 TO len;
        a = loc[i];
		aux1 = llike(a);
		y[i,] = aux1;
	END;
    loc = T(loc);
    temp = loc || y;
	CREATE datos FROM temp[COLNAME ={"Location","logvero"}];
	APPEND FROM temp;
QUIT;
PROC SGPLOT DATA = datos;
    SCATTER X = location Y = logvero;
	*dropline x=3.0297401 y=-58.1752 / dropto=both label="MLE"
      lineattrs=(color=blue pattern=dot) noclip;
    TITLE "Log-likelihood";
RUN;

PROC IML;
	USE x;
	READ ALL;
	n = &n;
	START grad(m) GLOBAL(n,x);
		ll = SUM((2*(x-m))/((x-m)##2+1));
		RETURN(ll);
	FINISH;
	loc = DO(&xmin,&xmax,.1);
    len = NCOL(loc);
    y=J(len,1,.);
	DO i = 1 TO len;
        a = loc[i];
		aux1 = grad(a);
		y[i,] = aux1;
	END;
    loc = T(loc);
    temp = loc || y;
	CREATE datos2 FROM temp[COLNAME ={"Location","score"}];
	APPEND FROM temp;
QUIT;
PROC SGPLOT DATA = datos2;
    SCATTER X = location Y = score;
	*DROPLINE X = 6.5 Y = 0 /DROPTO = Y;
	TITLE "Gradient";
RUN;

PROC IML;
	USE x;
	READ ALL;
	n = &n;
	START jacob(m) GLOBAL(n,x);
		ll = SUM((2*(x-m)##2-2)/((x-m)##2+1)##2);
		RETURN(ll);
	FINISH;
	loc = DO(&xmin,&xmax,.1);
    len = NCOL(loc);
    y=J(len,1,.);
	DO i = 1 TO len;
        a = loc[i];
		aux1 = jacob(a);
		y[i,] = aux1;
	END;
    loc = T(loc);
    temp = loc || y;
	CREATE datos3 FROM temp[COLNAME ={"Location","jacobian"}];
	APPEND FROM temp;
QUIT;
PROC SGPLOT DATA = datos3;
    SCATTER X = location Y = jacobian;
	*DROPLINE X = 6.5 Y = 0 /DROPTO = Y;
	TITLE "Jacobian";
RUN;