proc format;
value dieta
 1 = "Baja en grasas"
 2 = "Normal";
 value ejer
 1 = "Reposo"
 2 = "Caminar"
 3 = "Correr";
 value tiempo
 1 = "1 minuto"
 2 = "15 minutos"
 3 = "30 minutos";
run;

filename exer url "https://stats.idre.ucla.edu/stat/data/exer.csv";

data datos;
infile exer dlm = "," firstobs = 2;
input persona dieta ejercicio pulso tiempo;
format dieta dieta. ejercicio ejer. tiempo tiempo.;
label persona = "Individuo" dieta = "Tipo de dieta"
ejercicio = "Tipo de ejercicio" tiempo = "Intervalo de tiempo" pulso = "Pulso";
run;


/*gráficos*/
proc sgpanel data = datos;
panelby ejercicio;
vline tiempo / response = pulso group = dieta stat = mean;
run;

proc sgpanel data = datos;
panelby dieta;
vline tiempo / response = pulso group = ejercicio stat = mean;
run;



/* Modelo con estructura CS*/
proc mixed data = datos order = data;
class persona dieta ejercicio tiempo;
model pulso =  dieta|ejercicio|tiempo;
repeated / subject = persona type = cs r rcorr;
store out = mcs;
run;

proc plm restore = mcs;
effectplot mosaic;
effectplot interaction(PLOTBY=dieta)/ clm connect;
effectplot interaction(PLOTBY=ejercicio) / clm connect;
slice dieta*ejercicio*tiempo / sliceby(dieta ejercicio) pdiff = control("Normal" "Reposo" "1 minuto");
run;

/* Modelo con estructura ar(1)*/
proc mixed data = datos order = data;
class persona dieta ejercicio tiempo;
model pulso =  dieta|ejercicio|tiempo;
repeated / subject = persona type = ar(1) r rcorr;
run;


/* Modelo con estructura un*/
proc mixed data = datos order = data;
class persona dieta ejercicio tiempo;
model pulso =  dieta|ejercicio|tiempo;
repeated / subject = persona type = un r rcorr;
run;


/* Comparación de modelos cs vs un*/

data prueba;
lv_cs = 507.65678645;
lv_un = 502.81134117;
gl_cs = 2;
gl_un = 6;
dif_lv = abs(lv_un - lv_cs);
gl = gl_un - gl_cs; 
probchi = 1 - cdf('CHISQUARE', dif_lv, gl);
label lv_cs = "- 2 log verosimilitud modelo CS"
lv_un = "- 2 log verosimilitud modelo UN"
gl_cs = "Número de parámetros modelo CS"
gl_un = "Número de parámetros modelo UN"
dif_lv = "Diferencia entre las verosimilitudes"
gl = "Grados de libertad"
probchi = "Prob > Chisq";
run;

proc print data = prueba label;
run;
