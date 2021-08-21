%LET n = 100000;
%LET r = 3;
%LET p = 0.4;
%LET nsim = 100;
PROC IML;
    nsim = &nsim;
    START binneg(n,r,p) GLOBAL (nsim);
        TITLE "Simulación Binomial negativa con muestreador de Gibbs";
        TITLE2 "n =  &n  r =  &r  p =  &p";
        ini = n // r // p // &nsim;
        MATTRIB ini LABEL = "Detalles del algoritmo"
            ROWNAME = {"Tamaño de muestra","Número de éxitos",
            "Probabilidad de éxito","Número de simulaciones"};
        PRINT ini;
        x = J(n,1);
        DO i = 1 TO n;
            y = J(1,1);
            /* Simulo un valor de la a priori: Y ~ GAMMA(r,p/(1-p) */
            CALL RANDGEN(y,"GAMMA",r);
            y = y # p/(1-p);
            xly = J(1,1);
            ylx = J(1,1);
            DO j = 1 TO nsim;
                /* Simulo la condicional: X|y ~ Po(y) */
                CALL RANDGEN(xly,"POISSON",y);
                /* Simulo la condicional Y|x ~ Ga(r + x,p)*/
                CALL RANDGEN(ylx,"GAMMA",r + xly);
                ylx = ylx # p;
                y = ylx;
            END;
            x[i] = xly;
        END;
        m = x[:];
        v = VAR(x);
        mt = r  # p/(1-p);
        vt = r  # p/((1-p)##2);
        out1 = (m || v) // (mt || vt);
        MATTRIB out1 ROWNAME ={"Observada","Esperada"} 
            COLNAME ={"Media","Varianza"} LABEL = "Estadística descriptiva";
        PRINT out1;
        q = {0,1,2,3,4,5};
		pobs = J(6,1);
		pteo = J(6,1);
		DO k = 1 TO 6;
			pobs[k] = SUM(x <= q[k])/n;
			/* Vea CDF function: r failures, given k successes r = 0,1,...*/
			pteo[k] = CDF('NEGBINOMIAL',q[k],1-p,r);
		END;
		tabla = q || pobs || pteo;
		MATTRIB tabla COLNAME = {"Cuantil","Observada","Esperada"} LABEL = "P(X <= x)";
		PRINT tabla;
		CREATE datos FROM x[COLNAME = {"X"}];
    	APPEND FROM x;
    FINISH;
    CALL binneg(&n,&r,&p);
QUIT;
PROC FREQ DATA = datos NOPRINT;
    TABLES x / OUT = tabla;
RUN;
DATA tabla;
	SET tabla;
	DROP percent;
	LABEL count = "Observada" prob = "Esperada";
	count = count/&n;
	/* Vea PDF function: r failures, given k successes r = 0,1,...*/
	prob = PDF("NEGB",x,1-&p,&r);
RUN;
symbol1 value=dot;
symbol2 value=square color=red;
legend1 label=none
        position=(top center inside)
        mode=share;

PROC GPLOT DATA = tabla;
	PLOT count*x prob*x /OVERLAY LEGEND = legend1;
	TITLE "Comparación de probabilidades";
RUN;
QUIT;
