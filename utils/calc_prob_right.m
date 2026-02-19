function p_right = calc_prob_right(x1,t1,psi1_t)
p_right = zeros(1,length(t1));
for m=1:length(t1)
    psi = psi1_t(m,:);
    psi_right = abs(psi.^2).*(x1>0);
    p_r = sum(psi_right)/sum(abs(psi.^2));
    p_right(m) = p_r;
end
