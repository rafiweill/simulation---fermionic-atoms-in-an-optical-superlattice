function [V_1d,t] = figure4_J_vs_U_potential(x, Vshort, Vlong)
globals;
dt = 0.01e-6; 
t_max = 4e-3;
a_x_long = 2.28*um;
a_x_short = a_x_long/2;
Er_long = h^2/8/mass/a_x_long^2;
Er_short = h^2/8/mass/a_x_short^2;
V_amp_short = Vshort* Er_short;
V_amp_long = Vlong*Er_long;
V0 = V_amp_short*cos(pi/a_x_short * (x)).^2+V_amp_long*sin(pi/a_x_long * (x)).^2 ;

t = 0:dt:t_max;
Nx = length(x);
Nt = length(t);

V_1d =zeros(Nt,Nx);

for ind = 1:Nt
    V_1d(ind,:) = hbar^(-1)*(V0);
end




