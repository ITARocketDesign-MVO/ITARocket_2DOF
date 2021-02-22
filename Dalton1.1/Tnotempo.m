function T=Tnotempo(t)
global PROP
global SIM

i=round(t/(SIM.RKSTEP/2)+1);

T_linearizado=process_T(PROP.Thrust);
T=T_linearizado(i);

end