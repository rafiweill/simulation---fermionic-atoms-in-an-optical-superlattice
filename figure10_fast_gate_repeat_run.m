close all;
clear all;
addpath ./utils
globals;

NN = 100; %number of "experiments"
waitTmax = 15e-6;

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
    figure10_single_swap_potential(x, vs_max, t_gate, dt, 0);
[X1,X2] = meshgrid(x,x);
t_saves1 = t_gate*[0,0.4,0.6,1];

use_gpu = 1;

% initial conditions for psi:
[psi_0, psi_1, Ev] = solve_initial_conditions(V0, x, kin, 10);
psi_left_0 = 1/sqrt(2)*(psi_0+psi_1);
psi_right_0 = fliplr(psi_left_0);
[Psi_left_0,Psi_right_0] = meshgrid(psi_left_0, psi_right_0);
[V1,V2] = meshgrid(V_1d(1,:),V_1d(1,:));
Psi_2d_00 = Psi_left_0.*Psi_right_0;   
V_2d = (V1+V2);  

for nr = 1:NN
    kk=1;
    Psi_2d_0 = Psi_2d_00;
    for n_s = 1:20
        n_s
        waitT = waitTmax*rand(1);
        % waitT = 8e-6; %worst value
        % waitT = 3e-6; % best value
        [V_1d,t,V0,VL,VS] = ...
            figure10_single_swap_potential(x, vs_max, t_gate, dt, waitT);    
        t_saves1 = t_gate*[0,0.4,0.6,1];  
        gamma_t = ones(1,length(t));
        [Psi_2d_save, Vs_t_save, t_saves, psi_left_t,psi_right_t, psi_end] = ...
            propagate2d_traps(Psi_2d_0, V_1d, V_inter, gamma_t,gamma, kin, dx, X1,X2,t, t_saves1, use_gpu); 
        Psi_2d_0 = psi_end;
        if mod(n_s,4) ==0
            Psi_2d_end = psi_end;
            Psi_2d_end = Psi_2d_end/sqrt(sum(sum(abs(Psi_2d_end.^2))));
            p_right = abs(Psi_2d_end.^2).*(X1>0).*(X2<0);
            p_right=sum(p_right(:))
            Pr(nr,kk) = p_right;
            p_left = abs(Psi_2d_end.^2).*(X1<0).*(X2>0);
            p_left=sum(p_left(:))
            Pl(nr,kk) = p_left;
            kk = kk+1;
        end
    end
end

Pr_best = [ 1 0.9891    0.9950    0.9904    0.9903    0.9932]; %for 3us holding times
Pr_worst =[1 0.8839    0.6823    0.5835    0.5703    0.5448]; %for 8us holding times
PrX = [ones(100,1), Pr];
nn=0:4:20;
figure
plot(nn,PrX')
xlabel('number of gates');
ylabel('Probability');
Pr2 = [1, mean(Pr)];
std2p = [1, std(Pr)+ mean(Pr)];
std2m = [1, -std(Pr)+ mean(Pr)];
figure
plot(nn,Pr2,'o');
hold on;
% plot(nn, std2p); plot(nn, std2m);
F = 0.993;
y = F.^nn;
plot(nn,y)
hold on;
plot(nn, Pr_best, 'x');
plot(nn, Pr_worst, '+');

xlabel('number of gates');
ylabel('Probability');
legend('average', '(0.993)^n', '3 \mu s hold', '8 \mu s hold');


fname = 'figure10.pdf';
xname = '$n$ (number of gates)';
yname = '$P_{|\uparrow,\downarrow\rangle}$';
save_pub_pdf_one(nn, Pr2, y, Pr_best, Pr_worst, fname, 'one', xname, yname)
