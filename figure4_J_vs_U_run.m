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
[X1,X2] = meshgrid(x,x);
% k vector:
kx2 = 2*cos( 2*pi/Nx*(0:(Nx-1)) )-2;
kin = -(hbar/2/mass)*kx2/dx^2;
Vshort_vec = [9.5, 9.78:0.2:13.3,14.5];
Vlong = 39.5; %fig S2
factor_g_U = 1.4107e+06; %just to set the nominal g!
gamma = 6.71e3*h*1/factor_g_U;
%interaction potential
N = Nx;
delta_potential = eye(N)*1/2 + circshift(eye(N)*1/4,[1 0]) + circshift(eye(N)*1/4,[-1 0]);
delta_potential = delta_potential/dx;
V_inter = delta_potential;
save_p = {};
for m=1:length(Vshort_vec)
    Vshort = Vshort_vec(m)
    [V_1d,t] = figure4_J_vs_U_potential(x, Vshort, Vlong);
    t_saves1 = [t(end)/2];
    V0 = V_1d(1,:);
    use_gpu = 1;

    % initial conditions for psi:
    [psi_all1, psi_all2, Ev_a] = solve_initial_conditions(V0, x, kin, 10);
    psi_left1 = (psi_all1+psi_all2);
    psi_left1 = psi_left1/sqrt(sum(abs(psi_left1).^2)*dx);
    psi_r1 =(psi_all1-psi_all2);
    psi_r1 = psi_r1/sqrt(sum(abs(psi_r1).^2)*dx);    
    
    [Psi_left_0,Psi_right_0] = meshgrid(psi_left1, psi_r1);
    [V1,V2] = meshgrid(V_1d(1,:),V_1d(1,:));
    Psi_2d_0 = Psi_left_0.*Psi_right_0;
    V_2d = (V1+V2);  
    gamma_t = ones(1,length(t));
    [psi_t, Vs_t, t_saves, psi_left_t,psi_right_t, psi_end, Pup_down_vec, Pdown_up_vec] = ...
        propagate2d_traps(Psi_2d_0, V_1d, V_inter, gamma_t,gamma, kin, dx, X1,X2,t,t_saves1,use_gpu);
    
    figure(101);
    plot(t,Pup_down_vec);
    hold on;
    xlabel('t (msec)');
    ylabel('p_r');
    save_p{m} = Pup_down_vec;
    close all;
end

% analyze the results of the long run - find the frequencies and plot
f_s = 700;
Jvec = zeros(1,length(save_p));
for m=1:length(save_p)
    p_right = save_p{m};
    p_right =  p_right';
    figure;
    plot(t,p_right);
    hold on;
    xlabel('t (msec)');
    ylabel('p_r');
    fo = fitoptions('Method','NonlinearLeastSquares');
    ft = fittype('0.5*(1+cos(2*pi*a*x+b))','coefficients',{'a','b'}, 'options', fo);
    [f1,~]=fit(t',p_right',ft,'startpoint',[f_s,0]); %1.2
    px = 0.5*(1+cos(2*pi*f1.a*t+f1.b));
    plot(t,px); 
    f_max = f1.a;
    f_s = f_max/1.5; %next guess
    Jvec(m) = abs(f_max);
end

factor_g_U = zeros(1,length(Vshort_vec));
t_analytic = zeros(1,length(Vshort_vec));

for ind1=1:length(Vshort_vec)
    Vshort = Vshort_vec(ind1)
    [V_1d,t] = figure4_J_vs_U_potential(x, Vshort, Vlong);    
    V0 = V_1d(1,:);
    use_gpu = 1;
    [psi_all1, psi_all2, Ev_a] = solve_initial_conditions(V0, x, kin, 10);
    psi_left1 = (psi_all1+psi_all2);
    psi_left1 = psi_left1/sqrt(sum(abs(psi_left1).^2)*dx);
    factor_g_U(ind1) = sum(abs(psi_left1).^4)*dx; 
    psi_r1 =(psi_all1-psi_all2);
    psi_r1 = psi_r1/sqrt(sum(abs(psi_r1).^2)*dx);
    psi_out = BMP_Hamiltonian(psi_left1,kin,V0);
    t_analytic(ind1) = abs(sum(psi_r1.*psi_out*dx)*hbar); %t is hbar*omega         
end

U_ana = factor_g_U(end)*gamma;
calib_factor = 0.82;  % needed to fit the reusults
U_over_t2 = calib_factor*U_ana./t_analytic;

% Experimental results from ref. "High-fidelity collisional quantum gates
% with fermionic atoms"
C = [7.17348	0.62815
9.83595	0.35358
12.26461	0.22716
15.02514	0.16395
19.0528	0.10864]; 

plot(C(:,1),C(:,2),'o');
fname = 'figure4';
xname = 'U/t';
yname = 'J/h (\textnormal{kHz})';
span = 'one';
save_pub_pdf2(U_over_t2, Jvec/1e3, C(:,1),C(:,2), fname, span, xname, yname)





