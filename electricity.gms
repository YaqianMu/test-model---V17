*----------------------------------------------*
*electricity sector division
*20151215 电力数据修改后，存在微小偏差，与ffactor有关，以后待查
*20161201,更新2012年数据，使用新的拆分方法，原数据在electricity文件夹
*----------------------------------------------*
$CALL GDXXRW.EXE elec.xlsx par=Eprop rng=A1:J34

Parameter Eprop(*,*) input data of sub-electricity sectors;
*Parameter elec_t(*,*)  electricity generation trend in 100 million kwh;
*Parameter mkup_t(*,*)  markup trend;
$GDXIN elec.gdx
$LOAD Eprop
*$LOAD elec_t
*$LOAD mkup_t
$GDXIN

*=== transfer unit to billion yuan
Eprop(i,sub_elec)=Eprop(i,sub_elec)/100000;
Eprop(f,sub_elec)=Eprop(f,sub_elec)/100000;
Eprop('tax',sub_elec)=Eprop('tax',sub_elec)/100000;

DISPLAY Eprop;

parameter
         ffshr           fraction of electric sector capital as fixed factor
         lelec0          labor in electricity generation
         kelec0          capital in electricity generation
         ffelec0         fixed factor in electricity generation
*         ffelec_b        fixed factor in base year
         intelec0        intermediate input to electricity generation
         taxelec0
         outputelec0     output of electricity generation
         Toutputelec0                                    ;



lelec0(sub_elec) =       Eprop("labor",sub_elec);
kelec0(sub_elec) =       Eprop("capital",sub_elec);

intelec0(i,sub_elec) =   Eprop(i,sub_elec);
taxelec0(sub_elec)=      Eprop("tax",sub_elec);

*==to be updata
parameter theta_elec(sub_elec)     imputed fixed factor share of capital      from Sue Wing 2006

table ff_data(*,*) cost structure from Sue Wing
                 hydro      nuclear    Wind       Solar      Biomass
labor            24         13         17         7          19
capital          56         60         64         73         59
ff               19         27         20         20         22
;
theta_elec(sub_elec) =0;
theta_elec(sub_elec)$ff_data("ff",sub_elec) = ff_data("ff",sub_elec)/(ff_data("ff",sub_elec)+ff_data("capital",sub_elec));

ffelec0(sub_elec)   =    0;

ffelec0(sub_elec)   = theta_elec(sub_elec)*kelec0(sub_elec);
kelec0(sub_elec)   =(1-theta_elec(sub_elec))*kelec0(sub_elec);


*ffelec_b(sub_elec)   =   ffelec0(sub_elec);

display taxelec0,ffelec0;


parameter enesta   substitution elasticity between different sub_elec    from EPPA 6
          emkup           electricity markup
          emkup0          base year electricity markup
          p_ff            proportion of fix-factor
          check1
          check2;
enesta=1.5;

*== markup factor
emkup(sub_elec)       =      1;
*emkup("wind")    =      1.3;
*emkup("solar")   =      2.5;
*emkup("Biomass")     =      1.8;

emkup0(sub_elec)      =      emkup(sub_elec);

outputelec0(sub_elec)=   emkup(sub_elec)*(lelec0(sub_elec)+kelec0(sub_elec)+ffelec0(sub_elec)+sum(i,intelec0(i,sub_elec)))+taxelec0(sub_elec);

*outputelec0(sub_elec)=   emkup(sub_elec)*(lelec0(sub_elec)+kelec0(sub_elec)+sum(i,intelec0(i,sub_elec)))+taxelec0(sub_elec);

Toutputelec0         =   sum(sub_elec,outputelec0(sub_elec));

taxelec0(sub_elec)$outputelec0(sub_elec)=taxelec0(sub_elec)/outputelec0(sub_elec);

p_ff(sub_elec)    =      emkup(sub_elec)*ffelec0(sub_elec)/((1-taxelec0(sub_elec))*outputelec0(sub_elec));

check1=output0("elec")-sum(sub_elec,outputelec0(sub_elec));

fact('capital')=fact('capital')-sum(sub_elec,ffelec0(sub_elec)*emkup(sub_elec));

*EPPA 6 elecpower 水电和核电的自然要素弹性
esub(sub_elec,"ff")=0.2;
esub("nuclear","ff")=0.6*p_ff("nuclear")/(1-p_ff("nuclear"));
esub("hydro","ff")=0.5*p_ff("hydro")/(1-p_ff("hydro"));
esub("wind","ff")=0.25;
*esub(sub_elec,"ff")=0.4;


display lelec0,kelec0,intelec0,outputelec0,taxelec0,tx0,emission0,p_ff,Toutputelec0,check1,esub;







