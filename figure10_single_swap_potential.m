function [V, t, V0, VL, VS] = ...
    figure10_single_swap_potential(x, vs_max, t_gate, dt, waitT)
globals;
a_x_long = 2.28*um;
a_x_short = a_x_long/2;
Er_long = h^2/8/mass/a_x_long^2;
Er_short = h^2/8/mass/a_x_short^2;

Vll =20; 
Vhl = 140;

V_wide = 1/hbar*Er_long*sin(pi/a_x_long * (x)).^2;
V_short = 1/hbar*Er_short*cos(pi/a_x_short * (x)).^2;

t_max = t_gate+waitT;
t = 0:dt:t_max;

VL = Vhl-(Vhl-Vll)*fun1(t, 0,t_gate, 1).^4;
VS = vs_max*fun1(t, 0,t_gate, 1);

VL = VL.*(t<=t_gate) + Vll*(t>t_gate);
VS = VS.*(t<=t_gate) + vs_max*(t>t_gate);

Nx = length(x);
Nt = length(t);
V =zeros(Nt,Nx);

for ind = 1:Nt
     V(ind,:) =V_wide*VL(ind)+V_short*VS(ind);
end

V0 = V(1,:);

