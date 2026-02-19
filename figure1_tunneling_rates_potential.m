function [V,t] = figure1_tunneling_rates_potential(x,factor_short,factor_long, t_max)
globals;
a_x_long = 2.28*um;
a_x_short = a_x_long/2;
Er_long = h^2/8/mass/a_x_long^2;
Er_short = h^2/8/mass/a_x_short^2;
V_amp_long = factor_long* Er_long;
V_amp_short = factor_short* Er_short;

V0 = V_amp_short*cos(pi/a_x_short * (x)).^2+V_amp_long*sin(pi/a_x_long * (x)).^2 ;

dt = 0.03e-6;
t = 0:dt:t_max;
Nx = length(x);
Nt = length(t);
V =zeros(Nt,Nx);

for ind = 1:Nt
    V(ind,:) = hbar^(-1)*(V0);
end



