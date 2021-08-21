proc iml;
    * tama�o de muestra;
    n = 1000;
    * vector de medias;
    mu = {0 0};
    * matriz de varianza-covarianza, correlaci�n -0.5;
    v = {1 -.5,-.5 1};
    *modulo para generar normales multivariadas;
    x = randnormal(n,mu,v);
    * M�todo de c�pulas: usar el teorema u = F(x) u ~ unif(0,1); 
    u1 = cdf("normal",x[,1]);
    u2 = cdf("normal",x[,2]);
    /* concatena vectores y calcula la correlaci�n;
    u = u1 || u2;
    print (corr(u)); */
    * Estimador de variables antit�ticas;
    eva = 1/n*sum(2/(1+u1##2)+2/(1+u2##2));
    print eva;
quit;