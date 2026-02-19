# Simulation data for [Fast collisional √SWAP gate for fermionic atoms in an optical superlattice]

This repository contains MATLAB code used to generate the numerical
results and figures presented in the paper:

"Fast collisional √SWAP gate for fermionic atoms in an optical superlattice".

## Requirements
- MATLAB R2021a or newer (older versions may work)
- parallel computing toolbox required for GPU acceleration

## Usage
Run:
    run_all.m

This script reproduces the main figures in the paper.

## Notes
The code is provided as-is for reproducibility purposes.
The split-step fourier method is implemented on two main functions:
propagate.m - for 1 dimension, and 
propagate2d_traps.m - for 2 dimensions.

These functions, given a potential V(x,t), propagte the initial waveform
psi_0 to psi_t.   
