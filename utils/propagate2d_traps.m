function [psi_t, Vs_t, t_saves, psi_left_t,psi_right_t, psi_end, Pup_down_vec, Pdown_up_vec] = ...
    propagate2d_traps(Psi_2d_0, V_1d, V_inter, gamma_t,factor_g, kin, dx, X1,X2,t,t_saves1,use_gpu)
globals;
Nt = length(t);
dt = mean(diff(t));
psi = Psi_2d_0;
Nx = length(kin);
[kin1,kin2] = meshgrid(kin,kin);
kin = kin1+kin2;
prop_k = exp(1i*kin*dt);
n_saves = length(t_saves1);
psi_t = zeros(n_saves, Nx, Nx);
psi_left_t = zeros(Nt,Nx);
psi_right_t = zeros(Nt,Nx);
Vs_t = zeros(n_saves, Nx, Nx);
t_saves = zeros(n_saves, 1);
Pup_down_vec = zeros(Nt, 1);
Pdown_up_vec = zeros(Nt, 1);
flagK = 1;
k = 1;
if use_gpu
    V_1d = gpuArray(V_1d);
    V_inter = gpuArray(V_inter);
end
if use_gpu
    psi = gpuArray(psi);
    prop_k = gpuArray(prop_k);
end
for t_ind = 1:Nt
    [V1,V2] = meshgrid(V_1d(t_ind,:),V_1d(t_ind,:));
    V_2d = (V1+V2) + factor_g*gamma_t(t_ind)/hbar*V_inter;  %CHECK
%     V_2d = V1;
    psik = fft2(psi);
    psik = psik.*prop_k;
    psi = ifft2(psik); %this is the solution of the momentum part
    psi = psi.*exp(1i*V_2d*dt); %potential part
    if (t(t_ind)>t_saves1(k)) && (flagK)
        if use_gpu
            psi_t(k, :, :) = gather(psi);
            Vs_t(k, :, :) = gather(V_2d);
        else
            psi_t(k, :, :) = psi;
            Vs_t(k, :, :) = V_2d;
        end
        t_saves(k) = t(t_ind);
        k = k +1
        if k>length(t_saves1)
            flagK =0;
            k = 1;
        end
    end
    psi_left = sum(psi,1)*dx;
    psi_right = sum(psi,2)*dx;
    psi_left = psi_left/norm(psi_left)/sqrt(dx); 
    psi_right = psi_right/norm(psi_right)/sqrt(dx); 
    if use_gpu
        psi_left_t(t_ind,:) = gather(psi_left);
        psi_right_t(t_ind,:) = gather(psi_right); 
    else
        psi_left_t(t_ind,:) = psi_left;
        psi_right_t(t_ind,:) = psi_right; 
    end
    Pup_down = sum(sum(abs((psi.^2).*(X1>0).*(X2<0))))*dx^2;
    Pup_down_vec(t_ind) = gather(Pup_down);
    Pdown_up = sum(sum(abs((psi.^2).*(X1<0).*(X2>0))))*dx^2;
    Pdown_up_vec(t_ind) = gather(Pdown_up);          
end

psi_end = gather(psi);
