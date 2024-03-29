%LET n1 = 10;
%LET n2 = 5;
%LET m = 1000;
%LET v = 5;
PROC IML;
	CALL RANDSEED(1);
	x = J(&n1,&m);
	y = J(&n2,&m);
	CALL RANDGEN(x,"NORMAL",&v);
	CALL RANDGEN(y,"EXPONENTIAL");
	y = y * &v;
	mx = MEAN(x);
	vx = VAR(x);
	my = MEAN(y);
	vy = VAR(y);
	sp = SQRT(((&n1-1) * vx + (&n2-1) * vy)/(&n1 + &n2 -2));
	tc = (mx-my)/(sp*SQRT(1/&n1 + 1/&n2));
	alfa = 0.05;
	ttablas = QUANTILE("T",1-alfa/2,&n1+&n2-2);
	nrech = ABS(tc) > ttablas;
	pot = nrech[:];
	PRINT "Tamaño de la prueba",pot;
QUIT;