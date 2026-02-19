close all;
clear all;
addpath ./utils
globals;
a_x_long = 2.28*um;
a_x_short = a_x_long/2;
Nx = 512; 
x_max = 3.0*um;
x = linspace(-x_max/2,x_max/2,Nx);
dx = mean(diff(x));
% k vector:
kx2 = 2*cos( 2*pi/Nx*(0:(Nx-1)) )-2;
kin = -(hbar/2/mass)*kx2/dx^2;

%t/h (at Vx = 6) = 2.7111e3 
%U/h = 4/sqrt(3)*t = 6.261e3; %according to ref.
%for this parameters the integral is:
factor_g_U = 1.4357e+06; %integral over w_L^4
gamma = 6.261e3*h*1/factor_g_U;

t_r = 0.5e-3;
t_hold = 0.2e-3;

%interaction delta potential 
delta_potential = eye(Nx)*1/2 + circshift(eye(Nx)*1/4,[1 0]) + circshift(eye(Nx)*1/4,[-1 0]);
delta_potential = delta_potential/dx;
V_inter = delta_potential;

[V_1d,t,V0] = figure2_DH_exchange_potential(x, t_hold);
[X1,X2] = meshgrid(x,x);
t_saves1 = [0.1e-6, t_r+0.25*t_hold, t_r+t_hold , 2*t_r+t_hold-1e-6];
use_gpu = 1;

% initial conditions for psi:
[psi_0, psi_1, Ev] = solve_initial_conditions(V0, x, kin, 10);
psi_left_0 = 1/sqrt(2)*(psi_0+psi_1);
psi_right_0 = fliplr(psi_left_0);
[Psi_left_0,Psi_left_1] = meshgrid(psi_left_0, psi_left_0);
[V1,V2] = meshgrid(V_1d(1,:),V_1d(1,:));
Psi_2d_0 = Psi_left_0.*Psi_left_1;   
V_2d = (V1+V2);  
gamma_t = ones(1,length(t));
[Psi_2d_save, Vs_t_save, t_saves, psi_left_t,psi_right_t, psi_end] = ...
    propagate2d_traps(Psi_2d_0, V_1d, V_inter, gamma_t,gamma, kin, dx, X1,X2,t, t_saves1, use_gpu); 

for m = 1:length(t_saves)
    t = t_saves(m)/1e-3
    psi2 = Psi_2d_save(m,:,:);  
    slice = squeeze(psi2);
    slice = flipud(slice);    
    if m==1
        max1 = max(max(abs(slice)));
        imgA = abs(slice)/max1;
    end
    if m==2
        imgB = abs(slice)/max1;
    end 
    if m==3
        imgC = abs(slice)/max1;
    end  
    if m==4
        imgD = abs(slice)/max1;
    end        
end

fname = 'figure3.pdf';
save_four_in_row_with_cbar(imgA,imgB,imgC,imgD, ...
    fname,'two');
