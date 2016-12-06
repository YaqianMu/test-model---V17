*----------------------------------------------*
*1206, to build the basic model for employment analysis
*----------------------------------------------*
parameter      A                      /1/         ;
parameter ur_t0(lm)      the benchmark unemployment rate  ;
ur_t0(lm)    =  0;
$ONTEXT
$Model:China3E

$Sectors:
y(i)                   !activity level for domestic production
consum                 !activity level for aggregate consumption
invest                 !activity level for aggregate physical capital investment
welf                   !activity level for aggregate welfare
yelec(sub_elec)        !Activity level for electricity production

l_a(lm)                !Activity level for labor allocation

$Commodities:
py(i)                  !domestic price inex for goods
pelec(sub_elec)$(not bse(sub_elec))         !domestic price inex for subelec
pe_base                !domestic price inex for baseload elec
pls(lm)                   !domestic price index for labor demand
pl(i,lm)$labor_q0(i,lm)                  !domestic price index for labor demand
pk                     !domestic price index for captial
pffact(i)$ffact0(i)         !domestic price index for fixed factors
pffelec(sub_elec)$ffelec0(sub_elec)                !domestic price index for fixed factors in electric sector
pcons                  !price index for aggregate consumption
pinv                   !price index for aggregate physical capital investment
pu                     !price index for utility

pco2$clim
pco2_s(i)$clim_s(i)     !shadow value of carbon
pco2_h$clim_h

$consumers:
ra                     !income level for representative agent

$auxiliary:
sff(x)$ffact0(x)       !side constraint modelling supply of fixed factor
sffelec(sub_elec)$ffelec0(sub_elec)         !side constraint modelling supply of fixed factors

ur_t(lm)$ur_t0(lm)                 !unemployment rate

t_re(sub_elec)$wsb(sub_elec)       !FIT for renewable energy

rgdp                     !real gdp

$prod:l_a(lm)       t:1
         o:pl(i,lm)      q:labor_v0(i,lm)
         i:pls(lm)       q:tlabor_v0(lm)



$prod:y(i)$elec(i)   s:0   a:10
        o:py(i)                                  q:output0(i)
        i:pelec(sub_elec)$TD(sub_elec)        q:outputelec0(sub_elec)
        i:pelec(sub_elec)$wse(sub_elec)       q:outputelec0(sub_elec)       a:
        i:pe_base                             q:(sum(bse,outputelec0(bse)))       a:

*       Production of T&D electricity
$prod:yelec(sub_elec)$TD(sub_elec) s:0       l(s):eslm("l")
        o:pelec(sub_elec)        q:(outputelec0(sub_elec))              p:(1-taxelec0(sub_elec))  a:ra  t:taxelec0(sub_elec)
        i:py(i)$(not e(i))       q:intelec0(i,sub_elec)
        i:py(elec)               q:(intelec0(elec,sub_elec)*aeei("elec"))
        i:py(fe)                 q:(intelec0(fe,sub_elec)*aeei("elec"))
        i:pl("elec",lm)$ll(lm)   q:laborelec0(sub_elec,lm)                   l:
        i:pl("elec",lm)$hl(lm)   q:laborelec0(sub_elec,lm)                   l:
        i:pk                     q:kelec0(sub_elec)


*       Production of fossile fuel electricity
$prod:yelec(sub_elec)$ffe(sub_elec) s:0   kle(s):0.4 kl(kle):0.6 l(kl):eslm("l")   ene(kle):enesta roil(ene):0 coal(ene):0 gas(ene):0
        o:pe_base                q:(outputelec0(sub_elec))                 p:(1-taxelec0(sub_elec))  a:ra  t:taxelec0(sub_elec)
        i:py(i)$(not e(i))       q:(intelec0(i,sub_elec)*emkup(sub_elec))
        i:py(elec)               q:(intelec0(elec,sub_elec)*aeei("elec")*emkup(sub_elec))
        i:pl("elec",lm)$ll(lm)   q:(laborelec0(sub_elec,lm)*emkup(sub_elec))                   l:
        i:pl("elec",lm)$hl(lm)   q:(laborelec0(sub_elec,lm)*emkup(sub_elec))                   l:
        i:pk                     q:(kelec0(sub_elec)*emkup(sub_elec))                         kl:
        i:py(fe)$intelec0(fe,sub_elec)    q:(intelec0(fe,sub_elec)*aeei("elec")*emkup(sub_elec))                            fe.tl:
        i:pco2#(fe)$clim         q:(emission0("co2","e",fe,sub_elec)*aeei("elec")*emkup(sub_elec))      p:1e-5             fe.tl:
        i:pco2_s("elec")#(fe)$clim_s("elec")         q:(emission0("co2","e",fe,sub_elec)*aeei("elec")*emkup(sub_elec))      p:1e-5             fe.tl:

*       Production of hybro and nuclear biomass electricity      va2 from wang ke
$prod:yelec(sub_elec)$hnb(sub_elec)  s:esub(sub_elec,"ff") a:0 va(a):esub("elec","kl") l(va):eslm("l")
        o:pe_base$hne(sub_elec)  q:outputelec0(sub_elec)              p:(1-taxelec0(sub_elec))  a:ra  t:taxelec0(sub_elec)
        o:pe_base$wsb(sub_elec)  q:outputelec0(sub_elec)              p:(1-taxelec0(sub_elec))  a:ra  N:t_re(sub_elec)
        i:py(i)                  q:(intelec0(i,sub_elec)*emkup(sub_elec))                                              a:
        i:pl("elec",lm)$ll(lm)          q:(laborelec0(sub_elec,lm)*emkup(sub_elec))                          l:
        i:pl("elec",lm)$hl(lm)          q:(laborelec0(sub_elec,lm)*emkup(sub_elec))                          l:
        i:pk                     q:(kelec0(sub_elec)*emkup(sub_elec))                                                  va:
        i:pffelec(sub_elec)$ffelec0(sub_elec)                q:(ffelec0(sub_elec)*emkup(sub_elec))      P:1


*       Production of wind, solar  electricity      va2 from wang ke
$prod:yelec(sub_elec)$wse(sub_elec) s:esub(sub_elec,"ff") b:0 va(b):esub("elec","kl") l(va):eslm("l")
       o:pelec(sub_elec)        q:(outputelec0(sub_elec))               p:(1-taxelec0(sub_elec))  a:ra  N:t_re(sub_elec)
*        o:pelec(sub_elec)        q:(outputelec0(sub_elec))             p:(1-taxelec0(sub_elec))  a:ra  t:taxelec0(sub_elec)
        i:py(i)                  q:(intelec0(i,sub_elec)*emkup(sub_elec))                                              b:
        i:pl("elec",lm)$ll(lm)          q:(laborelec0(sub_elec,lm)*emkup(sub_elec))                           l:
        i:pl("elec",lm)$hl(lm)          q:(laborelec0(sub_elec,lm)*emkup(sub_elec))                           l:
        i:pk                     q:(kelec0(sub_elec)*emkup(sub_elec))                                                  va:
        i:pffelec(sub_elec)$ffelec0(sub_elec)                q:(ffelec0(sub_elec)*emkup(sub_elec))      P:1



$prod:y(i)$(not fe(i) and not elec(i) ) s:0 a:esub(i,"ff") b(a):0  kle(b):0.4 kl(kle):0.6  l(kl):eslm("l") e(kle):sigma("ele_p") ne(e):sigma("ene_p")  coal(ne):0 roil(ne):0 gas(ne):0
        o:py(i)                  q:(output0(i))                    p:(1-tx0(i))     a:ra    t:tx0(i)
        i:pffact(i)$ffact0(i)    q:ffact0(i)                                           a:
        i:py(j)$(not e(j))       q:int0(j,i)                                         b:
        i:pk                     q:fact0("capital",i)                              kl:
        i:pl(i,lm)$ll(lm)        q:labor_v0(i,lm)                           l:
        i:pl(i,lm)$hl(lm)        q:labor_v0(i,lm)                           l:
        i:py(elec)               q:(int0(elec,i)*aeei(i))                          e:
        i:py(fe)                 q:(int0(fe,i)*aeei(i))                            fe.tl:
        i:pco2#(fe)$clim         q:(emission0("co2","e",fe,i)*aeei(i))      p:1e-5             fe.tl:
        i:pco2_s(i)#(fe)$clim_s(i)         q:(emission0("co2","e",fe,i)*aeei(i))      p:1e-5             fe.tl:

*       Production of fossil fuel production       va from wang ke
$prod:y(i)$fe(i) s:0 a:esub(i,"ff") b(a):0 va(b):esub(i,"kl") l(va):eslm("l")  coal(b):0 roil(b):0 gas(b):0
        o:py(i)                  q:(output0(i))                    p:(1-tx0(i))     a:ra    t:tx0(i)
        i:py(j)$(not fe(j))      q:int0(j,i)                                     b:
        i:pk                     q:fact0("capital",i)            va:
        i:pl(i,lm)$ll(lm)          q:labor_v0(i,lm)                l:
        i:pl(i,lm)$hl(lm)          q:labor_v0(i,lm)                l:
        i:pffact(i)$ffact0(i)    q:ffact0(i)                                      a:
        i:py(fe)                 q:(int0(fe,i)*aeei(i))                            fe.tl:
        i:pco2#(fe)$clim         q:(emission0("co2","e",fe,i)*aeei(i))      p:1e-5             fe.tl:
        i:pco2_s(i)#(fe)$clim_s(i)         q:(emission0("co2","e",fe,i)*aeei(i))      p:1e-5             fe.tl:

*        consumption of goods and factors    based on EPPA

$prod:consum   s:esub_c  a:0.3 e:sigma("ene_fd") roil(e):0 coal(e):0 gas(e):0
         o:pcons                  q:(sum(i,cons0(i))+sum(f,consf0(f)))
         i:py(i)$(not e(i))       q:cons0(i)                a:
         i:py(i)$(elec(i))        q:(cons0(i)*aeei("fd"))                e:
         i:py(fe)                 q:(cons0(fe)*aeei("fd"))                 fe.tl:
         i:pco2#(fe)$clim         q:(emission0("co2","e",fe,"household")*aeei("fd"))      p:1e-5             fe.tl:
         i:pco2_h#(fe)$clim_h     q:(emission0("co2","e",fe,"household")*aeei("fd"))      p:1e-5           fe.tl:
         I:PSO2#(fe)$slim         Q:(emission0("so2","e",fe,"household")*aeei("fd"))      P:1e-5         fe.tl:


*        aggregate capital investment

$prod:invest   s:esub_inv
         o:pinv             q:(sum(i,inv0(i)))
         i:py(i)            q:inv0(i)



*        welfare          Ke Wang, EPPA S: 1

$prod:welf    s:1.0
         o:pu                 q:(sum(i,cons0(i)+inv0(i))+sum(f,consf0(f)+invf0(f)))
         i:pcons              q:(sum(i,cons0(i))+sum(f,consf0(f)))
         i:pinv               q:(sum(i,inv0(i))+sum(f,invf0(f)))


$demand:ra

*demand for consumption,invest and rd

d:pu                 q:(sum(i,cons0(i)+inv0(i))+sum(f,consf0(f)+invf0(f)))

*endowment of factor supplies

e:pk                 q:fact("capital")
e:pls(lm)                q:(tlabor_v0(lm)/(1-ur_t0(lm)))
e:pls(lm)$ur_t0(lm)             q:(-tlabor_v0(lm)/(1-ur_t0(lm)))                  r:ur_t(lm)$ur_t0(lm)
e:pffact(x)          q:ffact0(x)                 r:sff(x)$ffact0(x)
e:pffelec(sub_elec)  q:ffelec0(sub_elec)         r:sffelec(sub_elec)$ffelec0(sub_elec)

*exogenous endowment of net exports(include variances)

e:py(i)              q:(-(nx0(i)+xinv0(i)+xcons0(i))*xscale)

*endowment of carbon emission allowances

e:pco2$clim          q:clim
e:pco2_s(i)$clim_s(i)    q:clim_s(i)
e:pco2_h$clim_h      q:clim_h

*supplement benchmark fixed-factor endowments according to assumed price elasticities of resource supply

$constraint:sff(x)$ffact0(x)
     sff(x)    =e= (py(x)/pu)**eta(x);

$constraint:sffelec(sub_elec)$ffelec0(sub_elec)
*    sffelec(sub_elec) =e=  (py("elec")/pu)**eta(sub_elec);
     sffelec(sub_elec) =e= 1;

$constraint:ur_t(lm)$ur_t0(lm)
      (pls(lm)/pu)=E=(ur_t(lm)/ur_t0(lm))**(-0.1);

*== indentification of FIT
$constraint:t_re(sub_elec)$wsb(sub_elec)
        t_re(sub_elec) =e= taxelec0(sub_elec);

$constraint:rgdp
  pu*rgdp =e= pcons*(sum(i,cons0(i))+sum(f,consf0(f)))*consum+pinv*(sum(i,inv0(i)))*invest+sum(i,py(i)*((nx0(i)+xinv0(i)+xcons0(i))*xscale))   ;




$report:

v:qdout(j)             o:py(j)       prod:y(j)     !output by sector(domestic market)

v:qc(i)                i:py(i)       prod:consum   !consumpiton of final commodities
v:grosscons            o:pcons       prod:consum   !aggregate consumpiton

v:qinvk(i)             i:py(i)       prod:invest   !physical capital investment by non-energy sectors
v:grossinvk            o:pinv        prod:invest   !aggregate physical capital investment


v:util                 o:pu          prod:welf       !welf

v:qin(i,j)             i:py(i)       prod:y(j)      !inputs of intermediate goods
v:qin_ele(i,sub_elec)  i:py(i)       prod:yelec(sub_elec)      !inputs of intermediate goods to fossil fuel fired generation

v:qkin(j)              i:pk          prod:y(j)        !capital inputs
v:qlin(j,lm)           i:pl(j,lm)      prod:y(j)        !labor inputs
v:qlin_ele(sub_elec,lm)      i:pl("elec",lm)      prod:yelec(sub_elec)        !labor inputs
v:qkin_ele(sub_elec)   i:pk          prod:yelec(sub_elec)        !capital inputs
v:qffin(j)$x(j)        i:pffact(j)   prod:y(j)        !fixed factor inputs

v:qffelec(sub_elec)$cfe(sub_elec)    i:pffelec(sub_elec)     prod:yelec(sub_elec)      !fixed factor inputs

V:qelec(sub_elec)        o:pelec(sub_elec)       prod:yelec(sub_elec)

v:ECO2(i)              i:pco2         prod:y(i)
v:ECO2_s(i)              i:pco2_s(i)        prod:y(i)
v:ECO2_se(sub_elec)              i:pco2_s("elec")        prod:yelec(sub_elec)
v:eco2_h                i:pco2_h        prod:consum
v:EsO2(i)              i:pso2        prod:y(i)
v:EHsO2                i:pso2        prod:consum
$offtext
$sysinclude mpsgeset China3E

*carbon has zero price in the benchmark

*initialize constraints

sff.l(x)$ffact0(x)  =1;
t_re.l(sub_elec) = taxelec0(sub_elec);
t_re.lo(sub_elec)$ret0(sub_elec)=-inf;
pu.fx=1;

*== policy shock for static model
ur_t.l(lm)=ur_t0(lm);
*clim_s("construction")=0.5*Temission0('co2',"construction");
*clim_s("transport")=1*Temission0('co2',"transport");
*clim_s("EII")=0.5*Temission0('co2',"EII");
*clim_s("elec")=0.7*Temission0('co2',"elec");
*clim=0.5*Temission1('co2');

*benchmark calibration

China3E.iterlim =100000;

$include China3E.gen

solve China3E using mcp;

display China3E.modelstat, China3E.solvestat,ur_t.l,clim;


