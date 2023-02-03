PROC IML;
    location = 1;
    scale = 2;
    niter = 100;
    tol = 0.0001;
    n = 1000;
    y = J(n,1);
    CALL RANDSEED(1);
    CALL RANDGEN(y,"CAUCHY");
    x = y#scale + location;
    START lvero(semilla) GLOBAL (n, x);
        par1 = semilla[1];
        par2 = semilla[2];
        lv = -n#LOG(CONSTANT("PI")#par2)-SUM(LOG(1+((x-par1)/(par2))##2));
        RETURN (lv);
    FINISH;
    START Gradiente(semilla) GLOBAL (n, x);
        par1 = semilla[1];
        par2 = semilla[2];
        d1 = SUM((2#(x-par1))/(par2##2+(x-par1)##2));
        d2 = -n/par2 + SUM((2#(x-par1)##2)/(par2#(par2##2+(x-par1)##2)));
        score = d1 // d2;
        RETURN (score);
    FINISH;
    START Hessiano(semilla) GLOBAL (n,x);
        par1 = semilla[1];
        par2 = semilla[2];
        d11 = SUM((2#(x-par1)##2-2#par2##2)/((par2##2+(x-par1)##2)##2));
        d22 = n/par2##2-SUM((2#(x-par1)##2#(3#par2+(x-par1)##2))/((par2#(par2##2+(x-par1)##2)##2)));
        dd = SUM((-4#par2#(x-par1))/((par2##2+(x-par1)##2)##2));
        hessian = ( d11 || dd) // (dd || d22);
        RETURN (hessian);
    FINISH;
    START NEWTON(semilla) GLOBAL (n, x, niter, tol);
		TITLE "Newton-Raphson Algorithm";
        inicial = semilla;
        MATTRIB inicial ROWNAME = {"Location","Scale"} LABEL = "Initial values";
        lvi = lvero(inicial);
        MATTRIB lvi LABEL = "Initial log-likelihood";
        PRINT inicial, lvi;
        dist = 1;
        i = 0;
        DO WHILE(dist > tol & i < niter);
            H = Hessiano(inicial);
            VC = INV(H);
            S = Gradiente(inicial);
            final = inicial - VC*S;
            dist = MAX(ABS(final-inicial));
			IF (dist > 1/tol) THEN DO;
				ultiter = history[i,];
				MATTRIB ultiter COLNAME = {"Iteration","Distance","Location","Scale"}
						LABEL = "Last iteration";
				message = {"The Newton-Raphson algorithm could fail to converge",
							"There are some problems of convergence",
							"Algorithm was halted"};
				MATTRIB message LABEL = "Convergence status";
            	PRINT message,ultiter;
				STOP;
			END;
            i = i+1;
            a = final[1];
            b = final[2];
            history = history // (i || dist || a || b);
            inicial = final;
        END;
        MATTRIB history COLNAME = {"Iteration","Distance","Location","Scale"} LABEL = "Iteration";
		PRINT history;
        IF dist < tol THEN DO;
            MATTRIB final ROWNAME = {"Location","Scale"} LABEL = "Estimates";
            message = "Successful convergence";
			MATTRIB message LABEL = "Convergence status";
            PRINT message;
            PRINT final;
            logv = lvero(final);
            MATTRIB logv LABEL = "Final log-likelihood";
            PRINT logv;
            H = -Hessiano(final);
            VC = INV(H);
            MATTRIB VC LABEL = "Hessian Matix";
            PRINT VC;
        END;
    FINISH;
    a = {1.05,2.02};
    CALL NEWTON (a);
QUIT;
