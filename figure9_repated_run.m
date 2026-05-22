close all;
clear all;
addpath ./utils
globals;
a_x_long = 2.28*um;
a_x_short = a_x_long/2;
Nx = 512; 
dt = 0.005e-6;
x_max = 3.0*um;
x = linspace(-x_max/2,x_max/2,Nx);
dx = mean(diff(x));
% k vector:
kx2 = 2*cos( 2*pi/Nx*(0:(Nx-1)) )-2;
kin = -(hbar/2/mass)*kx2/dx^2;

gamma = 30.96*h/1e3; %30.96kHz*um
t_gate = 21.2e-6;
vs_max = 41.35;

%interaction delta potential 
delta_potential = eye(Nx)*1/2 + circshift(eye(Nx)*1/4,[1 0]) + circshift(eye(Nx)*1/4,[-1 0]);
delta_potential = delta_potential/dx;
V_inter = delta_potential;

[V_1d,t,V0,VL,VS] = ...
    figure7_single_swap_potential(x, vs_max, t_gate, dt);
[X1,X2] = meshgrid(x,x);
V0 = V_1d(1,:);

[psi_0, psi_1,Ev] = solve_initial_conditions(V0, x, kin, 10);
psi_left_0 = abs(1/sqrt(2)*(psi_0+psi_1));
psi_right_0 = fliplr(psi_left_0);
[max1, ind1] = max(psi_left_0);
if (ind1 > 500)
    psi_right_0 = psi_left_0;
    psi_left_0 = fliplr(psi_right_0);
end
[Psi_left_0,Psi_right_0] = meshgrid(psi_left_0, psi_right_0);
Psi_2d_00 = Psi_left_0.*Psi_right_0;
Psi_2d_00 = Psi_2d_00/sqrt(sum(sum(abs(Psi_2d_00.^2))));
use_gpu = 1;
[Psi_R_0,Psi_L_0] = meshgrid(psi_right_0, psi_left_0);
%ideal waveforms:
%after one sqrt(SWAP)
Psi1 = 0.5*(1i*Psi_left_0.*Psi_right_0+1*Psi_R_0.*Psi_L_0);
Psi1 = Psi1/sqrt(sum(sum(abs(Psi1.^2))));
%after two sqrt(SWAP)
Psi2 = Psi_R_0.*Psi_L_0;
Psi2 = Psi2/sqrt(sum(sum(abs(Psi2.^2))));
%after three sqrt(SWAP)
Psi3 = 0.5*(Psi_left_0.*Psi_right_0+1i*Psi_R_0.*Psi_L_0);
Psi3 = Psi3/sqrt(sum(sum(abs(Psi3.^2))));

waitT_vec = [0:1:30]*1e-6;
NN = length(waitT_vec); 
Pr = zeros(NN,3);
Pl = Pr;
fid = Pr;

for nr = 1:NN
    waitT = waitT_vec(nr);
    Psi_2d_0 = Psi_2d_00;
    kk = 1;
    for n_s = 1:3
        % add waiting time:
        n_t = round(waitT/dt);
        if n_t>1
            Vx = repmat(V0, [n_t 1]);
            V_1dt = [V_1d; Vx];
        else
            V_1dt = V_1d;
        end   
        t_saves1 = t_gate*[0,0.4,0.6,1];
        t = dt*[0:size(V_1dt,1)-1];
        gamma_t = ones(1,length(t));        
        [Psi_2d_save, Vs_t_save, t_saves, psi_left_t,psi_right_t, psi_end] = ...
            propagate2d_traps(Psi_2d_0, V_1dt, V_inter, gamma_t,gamma, kin, dx, X1,X2,t, t_saves1, use_gpu); 
        Psi_2d_0 = psi_end;
        Psi_2d_end = psi_end;
        Psi_2d_end = Psi_2d_end/sqrt(sum(sum(abs(Psi_2d_end.^2))));
        p_right = abs(Psi_2d_end.^2).*(X1>0).*(X2<0);
        p_right=sum(p_right(:))
        Pr(nr,kk) = p_right;
        p_left = abs(Psi_2d_end.^2).*(X1<0).*(X2>0);
        p_left=sum(p_left(:))
        Pl(nr,kk) = p_left;
        if n_s==1
            fid(nr,n_s) = abs(sum(sum(conj(Psi1).*Psi_2d_end)))^2;
        end
        if n_s==2
            fid(nr,n_s) = abs(sum(sum(conj(Psi2).*Psi_2d_end)))^2;
        end  
        if n_s==3
            fid(nr,n_s) = abs(sum(sum(conj(Psi3).*Psi_2d_end)))^2;
        end   
        kk = kk+1;
    end
end

fid2 = fid(:,2);
y2 = 1-0.993^2*ones(1,length(waitT_vec));

fid3 = fid(:,3);
y3 = 1-0.993^3*ones(1,length(waitT_vec));
fname = 'figure9';
span ='one';
xlabels = {'waiting time ($\mu \mathrm{s}$)', 'waiting time ($\mu \mathrm{s}$)'};
titles = {'$1-\mathcal{F}$ for 2 gates', '$1-\mathcal{F}$ for 3 gates'};
ylabel_str = '$1-\mathcal{F}$';
save_pub_pdf_two(waitT_vec/1e-6, 1-fid2, waitT_vec/1e-6, y2,...
    waitT_vec/1e-6, 1-fid3, waitT_vec/1e-6, y3, fname, span, titles, xlabels, ylabel_str);







