%LET n = 50;
%LET m = 1000;
%LET mu = 1;
%LET semilla = 0;
DATA normal(DROP = j);
	CALL STREAMINIT(&semilla);
	DO i = 1 TO &m;
		DO j = 1 TO &n;
			x = RAND("NORMAL",&mu);
			OUTPUT;
		END;
	END;
RUN;

PROC MEANS DATA = normal NOPRINT;
	BY i;
	VAR x;
	OUTPUT OUT = medias(DROP = _TYPE_ _FREQ_) MEAN = m LCLM = linf UCLM = lsup;
RUN;

PROC FORMAT;
	FORMAT tipo;
	VALUE tipo 1 = "Dentro del intervalo"
		  0 = "Fuera del intervalo";
RUN;

DATA medias;
	ATTRIB status FORMAT = tipo.;
	SET medias;
	Status = 0;
	IF (linf < &mu AND lsup > &mu) THEN STATUS = 1;
RUN;

TITLE "Porcentaje de cobertura";
TITLE2 "Datos simulados de una distribución normal con media &mu.";
PROC FREQ DATA = medias;
	TABLES Status / NOCUM;
RUN;

ODS GRAPHICS ON;
PROC SGPLOT DATA = medias(OBS = 100);
	FORMAT status tipo.;
	HIGHLOW X = i LOW = linf HIGH = lsup / GROUP = status;
	SCATTER X = i Y = m / GROUP = status;
	REFLINE &mu / AXIS = Y;
	TITLE "Intervalo de confianza (95%). Media verdadera: mu = &mu";
	TITLE2 "Tamaño de muestra: n = &n, Número de réplicas: m = &m";
	XAXIS LABEL = "Muestra";
	YAXIS LABEL = "Valor de la media muestral";
	KEYLEGEND / POSITION = BOTTOMLEFT;
RUN;
ODS GRAPHICS OFF;

DATA expo(DROP = i);
	CALL STREAMINIT(&semilla);
	DO j = 1 TO &m;
		DO i = 1 TO &n;
		y = RAND("EXPONENTIAL")*&mu;
		OUTPUT;
		END;
	END;
RUN;

PROC MEANS DATA = expo NOPRINT;
	BY j;
	VAR y;
	OUTPUT OUT = medias(DROP = _TYPE_ _FREQ_) MEAN = m LCLM = linf UCLM = lsup;
RUN;

PROC FORMAT;
	FORMAT tipo;
	VALUE tipo 1 = "Dentro del intervalo"
		  0 = "Fuera del intervalo";
RUN;

DATA medias;
	ATTRIB status FORMAT = tipo.;
	SET medias;
	Status = 0;
	IF (linf < &mu AND lsup > &mu) THEN STATUS = 1;
RUN;

TITLE "Porcentaje de cobertura";
TITLE2 "Datos simulados de una distribución exponencial con media &mu.";

PROC FREQ DATA = medias;
	TABLES Status / NOCUM;
RUN;

ODS GRAPHICS ON;
PROC SGPLOT DATA = medias(OBS = 100);
	FORMAT status tipo.;
	HIGHLOW X = j LOW = linf HIGH = lsup / GROUP = status;
	SCATTER X = j Y = m / GROUP = status;
	REFLINE &mu / AXIS = Y;
	TITLE "Intervalo de confianza (95%). Media verdadera: mu = &mu";
	TITLE2 "Tamaño de muestra: n = &n, Número de réplicas: m = &m";
	XAXIS LABEL = "Muestra";
	YAXIS LABEL = "Valor de la media muestral";
	KEYLEGEND / POSITION = BOTTOMLEFT;
RUN;
ODS GRAPHICS OFF;

/*
TITLE3 "Estimación usando el procedimiento IML";
PROC IML;
	CALL RANDSEED(&semilla);
	X = J(&n,&m);
	CALL RANDGEN(X,"NORMAL",&mu);
	Media = MEAN(X);
	sm = STD(X);
	ttablas = QUANTILE("T",.975,&n-1);
	li = media - sm*ttablas/SQRT(&n);
	ls = media + sm*ttablas/SQRT(&n);
	ind = (li < &mu & ls > &mu);
	Cobertura = ind[:];
	PRINT cobertura;
QUIT;
*/
