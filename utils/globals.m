%% units
global kelvin
global meter
global nm
global um
global hbar
global Jaul
global second
global kilogram
global Watt
global avugadro
global msec
global boltzman_constant;
global mass;
avugadro = 6.02214129e23;
meter = 1;
kelvin = 1;
nm = 1.e-9;
second = 1;
msec = 1.e-3*second;
micsec = 1.e-6*second;
um = meter*1.e-6;
kilogram = 1;
Jaul = kilogram*meter^2/second^2;
boltzman_constant = 1.38064852e-23*Jaul/kelvin;
Watt = Jaul/second;
h= 6.626070040e-34*Jaul*meter;
hbar = h/2/pi;
mass = 6*1.e-3/avugadro;  
