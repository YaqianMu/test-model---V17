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
ffelec0(sub_elec)   =    0;


*ffelec_b(sub_elec)   =   ffelec0(sub_elec);

display taxelec0;

emission0("so2","e","process",sub_elec)=Eprop("SO2_emission_process",sub_elec)*emission0("so2","e","process","elec");
emission0("so2","e","coal",sub_elec)=Eprop("SO2_emission_coal",sub_elec)*emission0("so2","e","coal","elec");
emission0("so2","e","roil",sub_elec)=Eprop("SO2_emission_oil",sub_elec)*emission0("so2","e","roil","elec");

emission0("so2","g","process",sub_elec)=Eprop("SO2_production_process",sub_elec)*emission0("so2","g","process","elec");
emission0("so2","g","coal",sub_elec)=Eprop("SO2_production_coal",sub_elec)*emission0("so2","g","coal","elec");
emission0("so2","g","roil",sub_elec)=Eprop("SO2_production_oil",sub_elec)*emission0("so2","g","roil","elec");

emission0("so2","a","process",sub_elec)=Eprop("SO2_abated_process",sub_elec)*emission0("so2","a","process","elec");
emission0("so2","a","coal",sub_elec)=Eprop("SO2_abated_coal",sub_elec)*emission0("so2","a","coal","elec");
emission0("so2","a","roil",sub_elec)=Eprop("SO2_abated_oil",sub_elec)*emission0("so2","a","roil","elec");

emission0("co2","e","gas",sub_elec)=Eprop("cO2_emission_naturegas",sub_elec)*emission0("co2","e","gas","elec");
emission0("co2","e","coal",sub_elec)=Eprop("cO2_emission_coal",sub_elec)*emission0("co2","e","coal","elec");
emission0("co2","e","roil",sub_elec)=Eprop("cO2_emission_oil",sub_elec)*emission0("co2","e","roil","elec");


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



