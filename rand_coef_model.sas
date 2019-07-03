/* This programme creates a random coefficient model.
Fish are nested in species 
We wanto to compute an intercept and a slope for every species.
*/
proc mixed data = sashelp.fish;
class species;
model weight = height height*height /solution outpred=pred;
random int height/ subject = species G;
store out = peces;
run;

proc plm restore = peces;
effectplot fit(x=height);
run;

proc sort data = pred;
by height;
run;

proc sgplot data = pred;
scatter x = height y = weight /group =species;
series x = height y = pred /group =species curvelabel;
run;
