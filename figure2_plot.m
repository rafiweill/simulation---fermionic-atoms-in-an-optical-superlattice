load('fig2_SE.mat', 'Pdown_up_vec1', 'Pup_down_vec1', 't_hold_vec1', 'px1');
load('fig2_DH.mat', 'Pdown_up_vec2', 'Pup_down_vec2', 't_hold_vec2', 'px2');
fname = 'figure2';
span ='one';
xlabels = {'$\tau_h \mathrm{(ms)}$', '$\tau_h \mathrm{(ms)}$'};
titles = {'$P_{|\uparrow,\downarrow\rangle}$', '$P_{|\uparrow\downarrow,0\rangle}$'};
ylabel_str = ' ';
save_pub_pdf_two(t_hold_vec1/1e-3, px1, t_hold_vec1/1e-3, Pdown_up_vec1,...
    t_hold_vec2/1e-3, px2, t_hold_vec2/1e-3, Pdown_up_vec2, fname, span, titles, xlabels, ylabel_str);