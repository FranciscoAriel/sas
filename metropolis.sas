proc iml;
	x = {4.3,2.2,3.1,8.4,-1.2,6.7,4.4,7.3,4.1,3.8};
	create datos from x[colname={"x"}];
	append from x;
	x0 = median(x);
	niter = 6000;
	start metro(semilla) global(niter,x);
		final = j(niter,1,0);
		i = 0;
		j = 0;
		candidato = j(1,1);
		u = j(1,1);
		do while(i < niter);
			call randgen(candidato,"normal",semilla);
			p = prod(pdf("cauchy",x,candidato))/prod(pdf("cauchy",x,semilla));
			r = min(1,p);
			call randgen(u,"uniform");
			if(u<r) then do;
				i = i + 1;
				final[i] = candidato;
				semilla = candidato;
			end;
			else do;
				i = i + 1;
				final[i] = semilla;
			end;
			j = j + 1;
		end;
		print "Iteraciones",j;
		return(final);
	finish;
	post=metro(x0);
	create final from post[colname={"x"}];
	append from post;
quit;
data final;
	set final;
	i = _n_;
run;
symbol1 interpol = join color=blue;
proc gplot data = final;
	plot x*i;
run;
quit;
proc means data = final n mean median stddev;
	where i gt 1000;
	var x;
run;
proc mcmc data = datos nmc = 5000;
	parms theta;
	prior theta ~ normal(0,var=1000);
	model x ~ cauchy(theta,1);
run;