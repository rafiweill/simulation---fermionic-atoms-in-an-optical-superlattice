function pulse = Blackman_pulse(t, t_gate, Vshort_l, Vshort_h)

t1 = t(t<t_gate);
amp = blackman(length(t1))';
pulse1 = Vshort_l+ (Vshort_h-Vshort_l)*(1-amp);
pulse = zeros(1,length(t));
pulse(t<t_gate) = pulse1;
pulse(t>=t_gate) = Vshort_h;
