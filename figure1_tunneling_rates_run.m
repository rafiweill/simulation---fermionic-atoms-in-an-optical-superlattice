close all; clear all;
addpath ./utils
globals;

% X grid
Nx = 512*1;
x_max = 3.0*um;
x = linspace(-x_max/2,x_max/2,Nx);
% k vector:
Nx = length(x);
dx = mean(diff(x));
kx2 = 2*cos( 2*pi/Nx*(0:(Nx-1)) )-2;
kin = -(hbar/2/mass)*kx2/dx^2;

% x axis values of fig.1
Vx = [3.1821    5.2107    7.2523    8.6112    9.9636   11.3160   12.6879];

t_max = 3.5*msec;

V_long_factor = 36.5; % 

f_osc = zeros(1,length(Vx));

for m=1:length(Vx)
    factor_short = Vx(m);
    [V,t] = figure1_tunneling_rates_potential(x,factor_short, V_long_factor, t_max);
    V0 = V(1,:);
    % solve the first eigenfunctions of the potential
    [psi_0, psi_1, Ev] = solve_initial_conditions(V0, x, kin, 10);     
    psi_00 = 0.5*(psi_0+psi_1); % the one site functions
    psi_t = propagate(t, psi_00, kin, V);
    p_right = calc_prob_right(x,t,psi_t);
    figure;
    plot(t/msec,p_right)
    xlabel('t (msec)');
    ylabel('p_r');
    dt = mean(diff(t));
    FS = 1/dt;
    f = [1:length(t)]*FS/length(t);
    f = f-mean(f);

    G = abs(fftshift(fft(p_right)));
    G = G.*(f>500);
    [max1,i] = max(G);
    f_max1 = f(i);
    fo = fitoptions('Method','NonlinearLeastSquares');
    ft = fittype('0.5*(1+cos(2*pi*a*x+b))','coefficients',{'a','b'}, 'options', fo);
    [f1,~]=fit(t',p_right',ft,'startpoint',[f_max1,0]); %1.2
    px = 0.5*(1+cos(2*pi*f1.a*t+f1.b));
    hold on;
    plot(t/msec,px); 
    f_osc(m) = f1.a;  
end

figure
plot(Vx, f_osc/1e3); hold on;

% Experimental results from ref. "High-fidelity collisional quantum gates
% with fermionic atoms"
tt_h = [10.3958    6.6527    3.7431    2.5321    1.6671    1.1166    0.8021];

err = abs(tt_h - f_osc/1e3)./tt_h

name_f = 'figure1';
xname = 'V_S (E_r^{\mathrm{short}})';
yname = '2t/h (\textnormal{kHz})';
span = 'one';
save_pub_pdf(Vx, f_osc/1e3, Vx, tt_h, name_f, span, xname, yname);



