%LET niter = 10000;
%LET tipo = 3;

PROC IML;
	iter = &niter;
    tipo = &tipo;
    START sa(params) GLOBAL (iter,tipo);
        theta = params;
        START temper(i,tipo);
            IF (tipo = 1) THEN tt = 1/(10*i);
            IF (tipo = 2) THEN tt = 1/log(i+1);
            IF (tipo = 3) THEN tt = 100/log(i+1); 
            RETURN(tt);
        FINISH;
        i = 1;
        u1 = J(1,1);
		u2 = J(1,1);
        v = J(1);
        DO WHILE (i < iter);
            CALL RANDGEN(u1,"NORMAL");
			CALL RANDGEN(u2,"EXPONENTIAL");
            u = u1 // u2;
            delta = funcion(u)-funcion(theta);
			tmpr = temper(i,tipo);
            rho = EXP(delta/tmpr);
            CALL RANDGEN(v,"UNIFORM");
            IF (v < rho) THEN DO;
                x = x // (t(u) || tmpr);
                theta = u;
            END;
            ELSE x = x // (t(theta) || tmpr);
            i = i+1;
        END;
		MATTRIB i LABEL = "N�mero de aceptados";
        MATTRIB tmpr LABEL = "Temperatura final";
        PRINT i,tmpr;
		xfin = x[i-1,1:2];
		MATTRIB xfin COLNAME = {"x","y"} LABEL = "Resultado final";
		PRINT xfin;
		CREATE datos FROM x[COLNAME ={"x","y","temp"}];
		APPEND FROM x;
    FINISH;
    n = 1000;
	x = J(n,1);
	CALL RANDGEN(x,"NORMAL");
	START funcion(params) GLOBAL (n,x);
        mu = params[1];
        v = params[2];
		lv = -n/2#LOG(v)-1/(2#v)#(T(x-mu)*(x-mu));
		RETURN (lv);
	FINISH;
	x0 = {.2,1.5};
    CALL sa(x0);
QUIT;