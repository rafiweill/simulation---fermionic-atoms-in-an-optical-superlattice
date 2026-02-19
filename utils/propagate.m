function psi_t = propagate(t, psi_0, kin, V_potential, use_gpu)
if nargin < 5
    use_gpu = 0;
end
Nx = length(psi_0);
dt = mean(diff(t));
Nt = length(t);
psi_t =zeros(Nt,Nx);
psi = psi_0;
prop_k = exp(1i*kin*dt);
if use_gpu
    prop_k = gpuArray(prop_k);
    psi = gpuArray(psi);
end
%Vt = V_potential;
for t_ind = 1:Nt
    Vt = V_potential(t_ind,:);
    if use_gpu
        Vt = gpuArray(Vt);
    end
    psik = fft(psi);
    psik = psik.*prop_k;
    psi = ifft(psik); %this is the solution of the momentum part
    psi = psi.*exp(1i*Vt*dt); %potential part
    if use_gpu
        psi_t(t_ind,:) = gather(psi);
    else
        psi_t(t_ind,:) = psi;
    end
end