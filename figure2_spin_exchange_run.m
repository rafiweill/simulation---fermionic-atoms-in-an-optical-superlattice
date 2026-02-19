close all;
clear all;
addpath ./utils
globals;
a_x_long = 2.28*um;
a_x_short = a_x_long/2;
omega_f = 1e5;
Nx = 512; 
x_max = 3.0*um;
x = linspace(-x_max/2,x_max/2,Nx);
dx = mean(diff(x));
% k vector:
kx2 = 2*cos( 2*pi/Nx*(0:(Nx-1)) )-2;
kin = -(hbar/2/mass)*kx2/dx^2;

%t/h (at Vx = 5.54) = 2.91e3 
%U/h = 4/sqrt(3)*t = 6.71e3; %according to ref.
%for this parameters the integral is:
factor_g_U = 1.4107e+06; %integral over w_L^4
gamma = 6.71e3*h*1/factor_g_U;

t_hold_vec = 1e-3*[0:0.025:0.5];
Pup_down_vec =zeros(1,length(t_hold_vec));
Pdown_up_vec =zeros(1,length(t_hold_vec));

%interaction delta potential 
delta_potential = eye(Nx)*1/2 + circshift(eye(Nx)*1/4,[1 0]) + circshift(eye(Nx)*1/4,[-1 0]);
delta_potential = delta_potential/dx;
V_inter = delta_potential;

for mk=1:length(t_hold_vec)
    close all;
    t_hold = t_hold_vec(mk)
    [V_1d,t,V0] = figure2_spin_exchange_potential(x, t_hold);
    [X1,X2] = meshgrid(x,x);
    t_saves1 = [500e-6, 800e-6];
    use_gpu = 1;

    % initial conditions for psi:
    [psi_0, psi_1, Ev] = solve_initial_conditions(V0, x, kin, 10);
    psi_left_0 = 1/sqrt(2)*(psi_0+psi_1);
    psi_right_0 = fliplr(psi_left_0);
    [Psi_left_0,Psi_right_0] = meshgrid(psi_left_0, psi_right_0);

    [V1,V2] = meshgrid(V_1d(1,:),V_1d(1,:));
    if (mk==1) %saved only once
        Psi_2d_0 = Psi_left_0.*Psi_right_0;
    end
    V_2d = (V1+V2);  
    gamma_t = ones(1,length(t));
    [Psi_2d_save, Vs_t_save, t_saves, psi_left_t,psi_right_t, psi_end] = ...
        propagate2d_traps(Psi_2d_0, V_1d, V_inter, gamma_t,gamma, kin, dx, X1,X2, t, t_saves1, use_gpu); 
    
    figure
    imagesc(x,t,-abs(psi_left_t.^2));
    figure
    imagesc(-abs(psi_right_t.^2));  

    for mm =1:size(Psi_2d_save,1)
        psi2 = Psi_2d_save(mm,:,:);  
        slice = squeeze(psi2);
        figure
        imagesc(x/um,x/um,abs(slice).^2); axis equal;  hold on;  
    end

    Psi_2d_end = psi_end;
    Psi_2d_end = Psi_2d_end/sqrt(sum(sum(abs(Psi_2d_end.^2)))*dx^2);
    Pup_down = sum(sum(abs((Psi_2d_end.^2).*(X1>0).*(X2<0))))*dx^2
    Pup_down_vec(mk) = Pup_down;
    Pdown_up = sum(sum(abs((Psi_2d_end.^2).*(X1<0).*(X2>0))))*dx^2
    Pdown_up_vec(mk) = Pdown_up;
    close all;
end

figure
plot(t_hold_vec, Pup_down_vec);
hold on;
plot(t_hold_vec, Pdown_up_vec);

f_s = 3.3e3; %guess
fo = fitoptions('Method','NonlinearLeastSquares');
ft = fittype('0.5*(1+cos(2*pi*a*x+b))','coefficients',{'a','b'}, 'options', fo);
[f1,~]=fit(t_hold_vec',Pdown_up_vec',ft,'startpoint',[f_s,0]); %1.2
px = 0.5*(1+cos(2*pi*f1.a*t_hold_vec+f1.b));
plot(t_hold_vec/1e-3,px); 
xlabel('$\tau_{h} (msec)$', 'Interpreter', 'latex');
ylabel('$P$', 'Interpreter', 'latex');
f_osc = f1.a

Pdown_up_vec1 = Pdown_up_vec; Pup_down_vec1 = Pup_down_vec;
t_hold_vec1 = t_hold_vec; px1 = px; 
save('fig2_SE.mat', 'Pdown_up_vec1', 'Pup_down_vec1', 't_hold_vec1', 'px1');



