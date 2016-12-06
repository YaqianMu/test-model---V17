*----------------------------------------------*
*Parameters with trend
*0317 加入GDP趋势，劳动力趋势
*----------------------------------------------*
$CALL GDXXRW.EXE trend.xlsx par=PAT rng=A1:D18   par=RET1 rng=A26:I35   par=RET2 rng=A37:I46   par=sffelec_b rng=A47:I57  par=sffelec_BAU rng=A58:I68

Parameter PAT(*,*) parameters with trend;
Parameter RET1(*,*) renewable electricity trend;
Parameter RET2(*,*) renewable electricity trend;
Parameter sffelec_b(*,*)      benchmark fixed factor trend;
Parameter sffelec_bau(*,*)      benchmark fixed factor trend;
$GDXIN trend.gdx
$LOAD PAT
$LOAD RET1
$LOAD RET2
$LOAD sffelec_b
$LOAD sffelec_bau
$GDXIN

Parameter rgdp_b(t)      real gdp pathway;
Parameter rgdp0          real gdp;
Parameter aeei(*)        auto energy effiency index;
Parameter gprod_b(t)    benchmark productivity index;
Parameter gprod0        benchmark productivity index;
Parameter lgrowth_b(t)      labor growth rate;

Parameter ret0      renewable electricity trend;
Parameter ret_b(t,*)      benchmark renewable electricity trend;

Parameter sffelec0      benchmark fixed factor trend;
Parameter sffelec1      benchmark fixed factor trend in BAU;


rgdp_b(t)=PAT(t,"rgdp");
rgdp0=rgdp_b("2010");
aeei(i)=1;
aeei("fd")=1;
gprod_b(t)=PAT(t,"gprod");
gprod0=gprod_b("2010");
lgrowth_b(t)=PAT(t,"lgrowth");

sffelec0(sub_elec)=1;
sffelec1(sub_elec)=1;



*参考情景
*ret_b(t,sub_elec)=RET2(t,sub_elec);
*高比例情景
ret_b(t,sub_elec)=RET1(t,sub_elec);

ret0(sub_elec)=ret_b("2010",sub_elec);

display aeei,PAT,rgdp0,ret0,ret_b;
