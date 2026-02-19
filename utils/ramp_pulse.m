function pulse = ramp_pulse(t, t_ramp, t_hold, V_l, V_h)

dV = V_h-V_l;
t1 = t_ramp+t_hold;
pulse = (V_h-dV*t/t_ramp).*(t<t_ramp) + V_l.*(t>=t_ramp).*(t<t_ramp+t_hold)+...
    (V_l+dV*((t-t1)/t_ramp)).*(t>=t1);

pulse(t>=t1+t_ramp) = V_h;
