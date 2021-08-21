DATA cauchy;
    KEEP x;
        DO i=1 TO 100;
        u = RAND("UNIFORM");
        x = 3+TAN(constant('PI')*(u-0.5));
        OUTPUT;
    END;
RUN;
PROC SGPLOT DATA = cauchy;
    HISTOGRAM x / Y2AXIS;
    DENSITY x;
    DENSITY x / TYPE = KERNEL;
RUN;