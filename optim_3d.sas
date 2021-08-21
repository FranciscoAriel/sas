%LET n = 1000000;
%LET eps = 0.04;
DATA func;
	DO x = -5 TO 5 BY .1;
		DO y = -5 TO 5 BY .1;
			z = pdf("NORMALMIX",x,2,.5, .5,-1.5, 1.5,1, 1)*
				pdf("NORMALMIX",y,2,.5, .5,-1.5, 1.5,1, 1);
			OUTPUT;
		END;
	END;
RUN;
PROC G3D DATA = func;
	PLOT x*y=z;
	TITLE "Función compleja";
	TITLE2 "Producto de mezcla de normales";
RUN;
QUIT;
PROC GCONTOUR DATA = func;
	PLOT x*y=z / PATTERN JOIN;
RUN;
QUIT;

PROC IML;
	TITLE "Solución analítica";
	TITLE2 "Varios máximos locales";
    START funcion (vector);
        x = vector[1];
        y = vector[2];
        z = pdf("NORMALMIX",x,2,.5, .5,-1.5, 1.5,1, 1)*
			pdf("NORMALMIX",y,2,.5, .5,-1.5, 1.5,1, 1);;
        RETURN(z);
    FINISH;
    /* Matrix of Constraints:
						par1	par2
		lower bounds	-5		-5
		upper bounds 	5		5
	*/
	const = {-5 -5,5 5}; 
	/* Initial guess */
	x0 = {0,0};
	/*
	opt[1] = 1 -> Problema de maximización
	opt[1] = 1 -> Historial de iteración
	*/
    ops = {1,1};
    /* Optimisation routine */
	CALL NLPNRA(rc,xr,"funcion",x0,ops,const);
	PRINT "Result", x0, xr, rc;
	x0 = {2,1.5};
	CALL NLPNRA(rc,xr,"funcion",x0,ops,const);
	PRINT "Result", x0, xr,rc;
	x0 = {-.801,-1.75};
	CALL NLPNRA(rc,xr,"funcion",x0,ops,const);
	PRINT "Result", x0, xr,rc;
	x0 = {2.147,-1.448};
	CALL NLPNRA(rc,xr,"funcion",x0,ops,const);
	PRINT "Result", x0, xr,rc;
	START simmin(n);
		x = J(n,1);
		y = J(n,1);
		z = J(n,1);
		CALL RANDGEN(x,"UNIFORM");
		CALL RANDGEN(y,"UNIFORM");
		u1 = 10#(x-0.5);
		u2 = 10#(y-0.5);
		u = u1 || u2;
		DO i = 1 TO n;
			aux1 = T(u[i,]);
			z[i] = funcion(aux1);
		END;
		todos = u || z;
		CREATE datos FROM todos[COLNAME = {"X","Y","Z"}];
		APPEND FROM todos;
		ind = z[<:>];
		MATTRIB ind LABEL = "Index";
		maximo = u[ind,];
		valor = z[ind];
		MATTRIB valor LABEL =" Value";
		MATTRIB maximo LABEL = "Maximum";
		PRINT ind,maximo,valor;
	FINISH;
	CALL simmin(&n);
QUIT;
DATA maximos;
	SET datos;
	WHERE z gt &eps;
RUN;
PROC GPLOT DATA = maximos;
	PLOT y*x;
	TITLE "Máximos locales";
	FOOTNOTE "z > &eps";
RUN;
QUIT;
