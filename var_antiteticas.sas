proc iml;
    * tamaño de muestra;
    n = 1000;
    * vector de medias;
    mu = {0 0};
    * matriz de varianza-covarianza, correlación -0.5;
    v = {1 -.5,-.5 1};
    *modulo para generar normales multivariadas;
    x = randnormal(n,mu,v);
    * Método de cópulas: usar el teorema u = F(x) u ~ unif(0,1); 
    u1 = cdf("normal",x[,1]);
    u2 = cdf("normal",x[,2]);
    /* concatena vectores y calcula la correlación;
    u = u1 || u2;
    print (corr(u)); */
    * Estimador de variables antitéticas;
    eva = 1/n*sum(2/(1+u1##2)+2/(1+u2##2));
    print eva;
quit;