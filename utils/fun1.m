function y = fun1(t, t1, t2, y1)
    tm = 0.5 * (t1 + t2);  % midpoint
    y = -y1 * (1 - 4*((t - tm).^2) / (t2 - t1)^2);
    y = y-min(y);
end