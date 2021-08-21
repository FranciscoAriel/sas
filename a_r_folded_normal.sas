PROC IML;
    n = 1000000;
    c = 1.5;
    START aar (n) GLOBAL (c);
        x = J(n,1);
        i = 0;
        j = 0;
        DO WHILE (i <n);
            y = J(1,1);
            CALL RANDGEN(y,"EXPONENTIAL");
            gy = PDF("EXPONENTIAL",y);
            fy = 2 # PDF("NORMAL",y);
            ratio = fy/(c # gy);
            u = J(1,1);
            CALL RANDGEN(u,"UNIFORM");
            IF (u < ratio) THEN DO;
                i = i + 1;
                x[i] = y;
            END;
            j = j + 1;
        END;
        q = {.5,1,1.5,2,3};
        pobs = J(5,1);
        pteo = J(5,1);
        DO k = 1 TO 5;
            pobs[k] = SUM(x<q[k])/n;
            pteo[k] = (CDF("NORMAL",q[k])-0.5) # 2;
        END;
        tabla = q || pobs || pteo;
        MATTRIB j LABEL = "N�meros aleatorios generados";
        MATTRIB tabla COLNAME = {"Cuantil","Observado","Esperado"} 
            LABEL = "Comparaci�n de Probabilidades Estimadas y te�ricas";
        PRINT j, tabla;
		CREATE datos FROM x[COLNAME = "x"];
		APPEND FROM x;
    FINISH;
	CALL aar(n);
QUIT;