data bond;
  input ingot metal $ pres;
  datalines;
1   n   67.0
1   i   71.9
1   c   72.2
2   n   67.5
2   i   68.8
2   c   66.4
3   n   76.0
3   i   82.6
3   c   74.5
4   n   72.7
4   i   78.1
4   c   67.3
5   n   73.1
5   i   74.2
5   c   73.2
6   n   65.8
6   i   70.8
6   c   68.7
7   n   75.6
7   i   84.9
7   c   69.0
;
run;
proc mixed data=bond cl covtest;
   class ingot metal;
   model pres=metal;
   random ingot;
run;
PROC IML;
	use bond;
	n=21;
	m = 10000;
	s2 = 10.3716;
	s2g = 11.4478;
	j = 3; /* tratamientos */
	k = 7; /* bloques */
	betas = {71.1,-0.9143,4.8,0}; /* matriz 4 X 1 */
	gamas = {-1.5580,-3.7086,4.0743,0.2341,0.8485,-3.0429,3.1527}; /* Matriz de 7 X 1 */
	G = s2g*I(k); /* 7 X 7 */
	R = s2*I(n); /* 21 X 21 */
	unoj = j(j,1,1);
	z = block(unoj,unoj,unoj,unoj,unoj,unoj,unoj); /* Matriz de 21 X 7 */
	V = Z*G*t(z) +R;
	unon = j(n,1,1);
	unok = j(k,1,1);
	cerok = j(k,1,0);
	xx = block(unok,unok,cerok);
	x = unon || (xx); /* Matriz de 21 X 4 */
	mu = x*betas+z*gamas;
	DO i = 1 TO m;
		e = RANDNORMAL(1,mu,v);
		y = t(e);
		muestra = J(n,1,i);
		abc = abc // (muestra || y || x[,2:4] || z);
	END;
	CREATE datos FROM abc[COLNAME = {"muestra","Y","Trat1","Trat2","Trat3","b1","b2","b3","b4","b5","b6","b7"}] ;
	APPEND FROM abc;
QUIT;

DATA simu;
	SET datos;
	metal = "c";
	IF trat1 EQ 1 THEN metal = "n";
	IF trat2 EQ 1 THEN metal = "i";
	IF b1 EQ 1 THEN ingot = 1;
	IF b2 EQ 1 THEN ingot = 2;
	IF b3 EQ 1 THEN ingot = 3;
	IF b4 EQ 1 THEN ingot = 4;
	IF b5 EQ 1 THEN ingot = 5;
	IF b6 EQ 1 THEN ingot = 6;
	IF b7 EQ 1 THEN ingot = 7;
	keep muestra y metal ingot;
RUN;
options nonotes;
ods select none;
PROC MIXED DATA = simu;
	by muestra;
	CLASS metal ingot;
	MODEL y = metal/ SOLUTION;
	*specify the G matrix in the mixed model;
	RANDOM ingot;
	ODS OUTPUT CovParms = cvn1000;
	TITLE "Componentes de varianza";
RUN;
ods select all;
proc transpose data = cvn1000 out = sim1(drop=_name_) prefix = v;
	by muestra;
	var estimate;
run;
proc means data = sim1 mean median stddev;
	var v1 v2;
run;
proc sgplot data = sim1;
	histogram v1;
	density v1/type = kernel;
run;
quit;
proc sgplot data = sim1;
	histogram v2;
	density v2/type = kernel;
run;
quit;
proc sort data = sim1 out = intv1;
	by v1;
run;
proc sort data = sim1 out = intv2;
	by v2;
run;

data intv1;
	set intv1;
	keep v1;
	if _n_ eq 500 or _n_ eq 9750 then output;
run;
data intv2;
	set intv2;
	keep v2;
	if _n_ eq 500 or _n_ eq 9750 then output;
run;
proc print data = intv1;
run;
proc print data = intv2;
run;