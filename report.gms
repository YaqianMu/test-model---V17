parameter
report1    reporting variable
report2    reporting variable
report3    reporting variable
report4    reporting variable
report5
report6
report7
report8
report9
report10
report11
report12
;
*UNEM
*Pwage;;

*report1(lm)=sum(i,qlin.l(lm,i))+sum(sub_elec,qlin_ele.l(lm,sub_elec));
*report1(lm)=ur.l(lm)-ur0(lm);
*report1(lm)=ur0(lm)*(pl.l(lm)/wage("0.11",lm))**(-10)-ur.l(lm);
*display report1;

$ontext



*set rate reduction rate /0,10,20,30,40,50,60,70,80,90/  ;
set z reduction rate /0,1,2,3,4,5,6,7,8,9/  ;
parameter rate(z) /0=0,
                   1=0.1,
                   2=0.2,
                   3=0.3,
                   4=0.4,
                   5=0.5,
                   6=0.6,
                   7=0.7,
                   8=0.8,
                   9=0.9/;


loop(z,
*clim=(1-(ord(rate)-1)/10)*Temission1("co2");
*clim_s("elec")=(1-(ord(rate)-1)/10)*Temission0('co2',"elec");
*clim_s("EII")=(1-(ord(rate)-1)/10)*Temission0('co2',"EII");
*clim_s("construction")=(1-(ord(rate)-1)/10)*Temission0('co2',"construction");
clim_s("elec")=(1-rate(z))*Temission0('co2',"elec");

*sigma("kle_ele") = rate(z)*0.6;
$include China3E.gen

solve China3E using mcp;

display China3E.modelstat, China3E.solvestat,clim,rate,sigma;

UNEM(lm,z)=UR.l(lm);
pwage(lm,z)=pl.l(lm);

report1(z,i)=qdout.l(i);
report2(z,i)=sum(fe,ccoef_p(fe)*qin.l(fe,i));
report2(z,sub_elec)=sum(fe,ccoef_p(fe)*qin_ele.l(fe,sub_elec));
report2(z,fe)=0;
report2(z,"household")=sum(fe,ccoef_h(fe)*qc.l(fe));
report3(z,i,j)=qin.l(i,j);
report3(z,i,sub_elec)=qin_ele.l(i,sub_elec);
report3(z,i,"household")=qc.l(i);
report4(z,i)=qffin.l(i);
report4(z,sub_elec)=qffelec.l(sub_elec);
report5(z)=   pcons.l*grosscons.l+pinv.l*grossinvk.l+sum(i,py.l(i)*((nx0(i)+xinv0(i)+xcons0(i))*xscale));
report6(z,lm)= sum(i,qlin.l(lm,i))+sum(sub_elec,qlin_ele.l(lm,sub_elec));
report7(z)= sum(i,qkin.l(i))+sum(sub_elec,qkin_ele.l(sub_elec));
report8(z,sub_elec)=qelec.l(sub_elec);
report9(z,sub_elec,lm)=qlin_ele.l(lm,sub_elec);

);
execute_unload "results.gdx" UNEM Pwage report1 report2 report3  report4 report5  report6 report7 report8  report9
execute 'gdxxrw.exe results.gdx par=unem rng=UNEM!'
execute 'gdxxrw.exe results.gdx par=Pwage rng=wage!'
execute 'gdxxrw.exe results.gdx par=report1 rng=output!'
execute 'gdxxrw.exe results.gdx par=report2 rng=emission!'
execute 'gdxxrw.exe results.gdx par=report3 rng=input!'
execute 'gdxxrw.exe results.gdx par=report4 rng=ffactor!'
execute 'gdxxrw.exe results.gdx par=report5 rng=GDP!'
execute 'gdxxrw.exe results.gdx par=report6 rng=labor!'
execute 'gdxxrw.exe results.gdx par=report7 rng=capital!'
execute 'gdxxrw.exe results.gdx par=report8 rng=ele_out!'
execute 'gdxxrw.exe results.gdx par=report9 rng=ele_labor!'

$offtext
