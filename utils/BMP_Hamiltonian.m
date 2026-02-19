function psi_out = BMP_Hamiltonian(psi,kin,V,symm)

psi = psi(:).';

if(nargin>3)
    if(symm>0)
        psi =0.5*(psi+fliplr(psi));
    else
        psi =0.5*(psi-fliplr(psi));
    end
end

psi_out = real(ifft(kin.*fft(psi)))+V.*psi;

return
end