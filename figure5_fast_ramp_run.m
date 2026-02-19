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

gamma = 3.5579*h/1e3; %3.56kHz*um

t_ramp = 50e-6;
t_hold = 78.3e-6;

%interaction delta potential 
delta_potential = eye(Nx)*1/2 + circshift(eye(Nx)*1/4,[1 0]) + circshift(eye(Nx)*1/4,[-1 0]);
delta_potential = delta_potential/dx;
V_inter = delta_potential;

[V_1d,t,V0] = figure5_fast_ramp_potential(x, t_hold);
[X1,X2] = meshgrid(x,x);
t_saves1 = [t_ramp, t_ramp+t_hold/2, t_ramp+t_hold, 2*t_ramp+t_hold];

use_gpu = 1;

% initial conditions for psi:
[psi_0, psi_1, Ev] = solve_initial_conditions(V0, x, kin, 10);
psi_left_0 = 1/sqrt(2)*(psi_0+psi_1);
psi_right_0 = fliplr(psi_left_0);
[Psi_left_0,Psi_right_0] = meshgrid(psi_left_0, psi_right_0);
[V1,V2] = meshgrid(V_1d(1,:),V_1d(1,:));
Psi_2d_0 = Psi_left_0.*Psi_right_0;   
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

fname = 'figure5.pdf';
save_four_in_row_with_cbar2(imgA,imgB,imgC,imgD, ...
    fname,'two');
