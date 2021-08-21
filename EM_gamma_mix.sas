%LET p = 0.15;
%LET b1 = 2;
%LET b2 = 10;
%LET n = 5000;
DATA mix_gamma(KEEP = x);
    DO i = 1 TO &n;
        u = RAND("UNIFORM");
        y = RAND("EXPONENTIAL");
        IF (u < = &p) THEN DO;
                x = &b1*y;
                OUTPUT;
            END;
        ELSE DO;
                x = &b2*y;
                OUTPUT;
            END;
    END;
RUN;
PROC IML;
    USE mix_gamma;
    READ ALL INTO x;
    START E_step(params) GLOBAL (x);
        p = params[1];
        b1 = params[2];
        b2 = params[3];
        dens1 = p*PDF("EXPONENTIAL",x,b1);
        dens2 = (1-p)*PDF("EXPONENTIAL",x,b2);
        z = dens1/(dens1+dens2);
        RETURN(z);
    FINISH;
    START logv(params,z) GLOBAL (x);
        p = params[1];
        b1 = params[2];
        b2 = params[3];
        s1 = (LOG(p)-LOG(b1))*SUM(z);
        s2 = 1/b1*SUM(x#z);
        s3 = (LOG(1-p)-LOG(b2))*SUM(1-z);
        s4 = 1/b2*SUM(x#(1-z));
        lv = s1 +s3 -s2 - s4;
        RETURN(lv);
    FINISH;
    tol = 0.001;
    niter = 100;
    START EM(params) GLOBAL(x,tol,niter);
        n = NROW(x);
        dif = 1;
        i = 0;
        z = E_step(params);
        lv0 = logv(params,z);
        history = i || lv0 || .;
        DO WHILE (i < niter & dif > tol);
            par1 = SUM(z)/n;
            par2 = SUM(x#z)/SUM(z);
            par3 = SUM(x#(1-z))/SUM(1-z);
            newpar = par1 // par2 // par3;
			z = E_step(newpar);
            dif = MAX(ABS(newpar-params));
            i = i+1;
            lv1 = logv(newpar,z);
            history =history // ( i || lv1 || dif);
            params = newpar;
        END;
        MATTRIB history COLNAME = {"Iteration","Log-likelihhod","difference"};
        MATTRIB newpar ROWNAME = {"p","Beta 1","Beta 2"} LABEL = "Estimates";
        TITLE "EM algorithm for mixed Gamma distribution";
        PRINT history,newpar;
		actual = n // &p // &b1 // &b2;
		MATTRIB actual ROWNAME = {"N","P","Beta 1","Beta 2"} LABEL = "True parameters";
		PRINT actual;
    FINISH;
    params = {0.2,1.75,10.2};
    CALL EM(params);
QUIT;
