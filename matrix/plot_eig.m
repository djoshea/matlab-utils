function plot_eig(W)

[~, D] = eig(W);

d = diag(D);

rad = abs(d);
m_stable = rad <= 1;
sz = 20;
scatter(real(d(m_stable)), imag(d(m_stable)), sz, 'filled', 'k');
hold on;
scatter(real(d(~m_stable)), imag(d(~m_stable)), sz, 'filled', 'r');

theta = linspace(0, 2*pi, 180);
x = cos(theta);
y = sin(theta);

washolding = ishold;
plot(x, y, 'r--');
axis equal;

if ~washolding
    hold off;
end

end