close all;
clear all;
addpath ./utils
globals;

Nx = 512;
a_x_long = 2.28*um;
Er_long = h^2/8/mass/a_x_long^2;
x_max = 3*um;
dt = 0.05e-6;
x = linspace(-x_max/2,x_max/2,Nx);
% k vector:
Nx = length(x);
dx = mean(diff(x));
kx2 = 2*cos( 2*pi/Nx*(0:(Nx-1)) )-2;
kin = -(hbar/2/mass)*kx2/dx^2;
params = [1.1482    0.8044]; %0.9997(and ??)

vs_max = 45.93; 
t_gate = 21.26e-6;

[V,t,V0,VL,VS] = ...
    figure7_single_swap_potential(x, vs_max, t_gate, dt);

[psi_0, psi_1, Ev] = solve_initial_conditions(V0, x, kin, 10);

psi_0 = 1/sqrt(2)*(psi_0+psi_1);
psi_t = propagate(t, psi_0, kin, V);

figure
imagesc(x/a_x_long,t/1e-6,abs(psi_t.^2));

psi_r = fliplr(psi_0); psi_r = psi_r/norm(psi_r);
psi_end = psi_t(end,:); psi_end = psi_end/norm(psi_end);
fidelity = abs(sum((conj(psi_r.*psi_end))))^2

%plot:
x1a = t/1e-6;
y1a = VS; 
y2a = VL; 

x2 = x/(a_x_long/2);
V_samples = V(1:71:253,:);
y2 = V_samples'*hbar/Er_long;

MAT = abs(psi_t.^2)/max(max(abs(psi_t.^2)));
X1 = x2;
Y1= t/1e-6;

fname = 'figure7.pdf';
save_asym_onecol_lineplot_plus_image(x1a,y1a,y2a, x2,y2,X1,Y1,MAT,fname);





