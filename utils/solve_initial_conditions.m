function [psi_0, psi_1, Ev] = solve_initial_conditions(V, x, kin, number_eigen)
if nargin<5
    number_eigen = 1;
end
OPTS.sigma = min(V);
OPTS.issym = 1;
OPTS.tol = 1.e-8;
[D1,Ev,FLAG] = my_eigs(@(psi) BMP_Hamiltonian(psi,kin,V),length(x(:)),number_eigen+3,'sa',OPTS);
Ev = diag(Ev);
psi_0 = D1(:,1).';
dx = mean(diff(x));
psi_0 = psi_0/norm(psi_0)/dx;

psi_1 = D1(:,2).';
psi_1 = psi_1/norm(psi_1)/dx;
    