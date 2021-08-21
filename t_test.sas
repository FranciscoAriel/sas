%LET n1 = 5;
%LET n2 = 5;
%LET muestra = 1000;
%LET semilla = 0;
%LET v1 = 1;
%LET v2 = 1;
DATA datos(DROP = j LABEL = "X1 ~ N(0,&v1), X2 ~ N(0,&v2)");
	ATTRIB x LABEL = "X" pobl LABEL = "Población" i LABEL = "Réplica";
	CALL STREAMINIT(&semilla);
	DO i = 1 TO &muestra;
		pobl = 1;
		DO j = 1 TO &n1;
			x = RAND("NORMAL",0,&v1);
			OUTPUT;
		END;
		pobl = 2;
		DO j = 1 TO &n2;
			x = RAND("NORMAL",0,&v2);
			OUTPUT;
		END;
	END;
RUN;

ODS SELECT NONE;
PROC TTEST DATA = datos;
	BY i;
	CLASS pobl;
	VAR x;
	ODS OUTPUT ttests=TTests(WHERE=(method="Pooled"));
RUN;
ODS SELECT ALL;

PROC FORMAT;
	FORMAT test;
	VALUE test  1 = "Rechazo" 0 = "No Rechazo";
RUN;

DATA prueba(LABEL = "Resultados prueba T, nivel de significancia 5%" DROP = Variable Method Variances DF);
	SET TTests;
	ATTRIB Status FORMAT = test.;
	Status = 1;
	IF (probt > 0.05) THEN Status = 0;
RUN;

TITLE "Tamaño de la prueba";
TITLE2 "Prueba T";
TITLE3 "&muestra réplicas";

PROC FREQ DATA = prueba;
	FORMAT Status test.;
	TABLES Status / NOCUM;
RUN;
