function [V,t,V0] = figure5_fast_ramp_potential(x, t_hold)
globals;
Vshort_h = 54;
Vshort_l = 5.6;
Vlong_h = 34;
t_ramp = 50e-6;
dt = 0.008e-6;
t_max = (2*t_ramp+t_hold) + 0.1*t_ramp;
% t_max = 6e-3;
a_x_long = 2.28*um;
a_x_short = a_x_long/2;
Er_long = h^2/8/mass/a_x_long^2;
Er_short = h^2/8/mass/a_x_short^2;
V_amp_short = Vshort_h* Er_short;
V_amp_long = Vlong_h*Er_long;

V0 = V_amp_short*cos(pi/a_x_short * (x)).^2+V_amp_long*sin(pi/a_x_long * (x)).^2 ;
V0 = 1/hbar*V0;

t = 0:dt:t_max;
Nx = length(x);
Nt = length(t);
V =zeros(Nt,Nx);

pulse_mid = ramp_pulse(t, t_ramp, t_hold, Vshort_l, Vshort_h);
pulse_mid = pulse_mid*Er_short;

for ind = 1:Nt
    V(ind,:) = hbar^(-1)*(V_amp_long*sin(pi/a_x_long * (x)).^2 + pulse_mid(ind)*cos(pi/a_x_short * (x)).^2);
end





