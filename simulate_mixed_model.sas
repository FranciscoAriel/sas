data heights;
   input Family Gender$ Height @@;
   datalines;
1 F 67   1 F 66   1 F 64   1 M 71   1 M 72   2 F 63
2 F 63   2 F 67   2 M 69   2 M 68   2 M 70   3 F 63
3 M 67   3 F 64   4 F 66   4 M 67   4 M 67   4 M 69
4 M 64   5 M 67   5 M 66   5 F 70   5 F 71   5 F 72
;
run;

PROC MIXED DATA = datos;
	CLASS Family Gender;
	MODEL Height = Gender/ SOLUTION;
	RANDOM Family Family*Gender;
	TITLE "Modelo orginal";
RUN;

PROC IML;
	use heights;
	read all var {Family} into fam;
	read all var {Gender} into gen;
	close heights;
	n=nrow(fam);
	s2 = 2;
	s2g = 2.5;
	s2fg = 1.75;
	aux = concat(fam,gen);
	z = design(fam);
	p = ncol(z);
	G = s2g*I(p);
	z2 = design(aux);
	p2 = ncol(z2);
	G2 = s2fg*I(p2);
	R = s2*I(n);
	V = Z*G*t(z) + Z2*G2*t(z2) + R;
	mu = J(n,1,68);
	print G,G2,R,v;
	CALL RANDSEED(123);
	e = RANDNORMAL(1,mu,v);
	y = t(e);
	CREATE x FROM y[COLNAME = {"Y"}] ;
	APPEND FROM y;
QUIT;

DATA datos;
	merge heights(drop = Height) x;
RUN;

PROC MIXED DATA = datos;
	CLASS Family Gender;
	MODEL y = Gender/ SOLUTION;
	*specify the G matrix in the mixed model;
	RANDOM Family Family*Gender;
	TITLE "Componentes de varianza";
RUN;
PROC MIXED DATA = datos;
	CLASS Family Gender;
	MODEL y = / SOLUTION;
	*specify the G matrix in the mixed model;
	RANDOM INT Family*Gender/ SUBJECT = Family;
	TITLE "Modelo de interceptos aleatorios";
RUN;
/* PROC MIXED DATA = datos;
	CLASS Family Gender;
	MODEL y = / SOLUTION;
	*specify the R matrix in the mixed model;
	REPEATED Family*Gender/ SUBJECT = Family type=cs;
	TITLE "Medidas repetidas";
RUN; */