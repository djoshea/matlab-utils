function d = circ_diff(b, a)
% d = circ_diff(b, a)
% computes the signed difference between angles b-a in radians

d = mod((b - a)-pi, 2*pi) - pi;

end