PROC IML;
    n = 20000;
    v = 30;
    nsim = 500;
    START compt(n,v) GLOBAL(nsim);
        x = J(n,1);
		TITLE "Simulación de una T de Student con algoritmo de Gibbs";
        DO i = 1 TO n;
            y = J(1,1);
            /* Dist. a priori Y ~ GAMMA(v/2,2) */
            CALL RANDGEN(y,'CHISQUARE',v);
            xly = J(1,1);
            ylx = J(1,1);
            s = SQRT(v/y);
            DO j = 1 TO nsim;
                /* Simular X|Y ~ N(0,v/y) */
                CALL RANDGEN(xly,"NORMAL",0,s);
                /* Simular Y|X ~ GAMMA((v+1)/2,1/(1/2+x^2/(2v)))*/
                b = 1/2+(xly ## 2)/(2 # v);
                CALL RANDGEN(ylx,"GAMMA",(v+1)/2);
				ylx = ylx # 1/b;
                s = SQRT(v/ylx);
            END;
            /* Despues de muchas iteraciones tenemos una conjunta.
               Basta con tomar la última */
            x[i] = xly;
        END;
        RETURN(X);
    FINISH;
    x = compt(n,v);
    q = {-2, -1, 0, 1.64, 1.96};
    pobs = J(5,1);
    pteo = J(5,1);
	pnor = J(5,1);
	i = 0;
    DO WHILE (i < 5);
		i = i+ 1;
	    pobs[i] = sum(x<q[i])/n;
        pteo[i] = CDF("T",q[i],v);
		pnor[i] = CDF("NORMAL",q[i]);
    END;
	tabla = q || pobs || pteo || pnor;
	MATTRIB tabla COLNAME ={"Cuantil","Probabilidad observada","Probabilidad teórica","Probabilidad normal"}
		ROWNAME=EMPTY LABEL = "Comparación de probabilidades";
	m = x[:];
	vx = VAR(x);
	out1 = m || vx;
	mteo = 0;
	vteo = .;
	IF (v > 2) THEN vteo = v/(v-2);
	IF (v <= 1) THEN mteo = .;
	out1 = out1 // ( mteo ||  vteo );
	MATTRIB  out1 LABEL ="Estadísticas descriptivas" 
		ROWNAME = {"Obsevada","Esperada"} COLNAME = {"Media de X","Varianza de X"};
	out = n // v // nsim;
	MATTRIB out ROWNAME = {"Tamaño de muestra","Grados de libertad","Número de simulaciones"}
		LABEL = "Detalles del algoritmo";
	PRINT out;
    PRINT out1;
	PRINT tabla;
    CREATE datos FROM x[COLNAME = {"X"}];
    APPEND FROM x;
QUIT;
PROC SGPLOT DATA = datos;
    HISTOGRAM x;
RUN;
