T = 1000;
R = 5;
C = 10;

t = 1:T;
delays = (1:R)' * 10;

template = reshape(smooth(randn(3*T*C, 1), floor(T/10)), 3*T, C);

midT = floor(3*T / 2);

X = nan(R, T, C);
for r = 1:R
    X(r, :, :) = template((T:2*T-1) - delays(r), :);
end

X_offset = bsxfun(@plus, X, 0.03*(1:R)');
plot(squeeze(X_offset(:, :, C))');

%%

delaysFit = TrialDataUtilities.Data.findDelaysMultiAnalogTensor(X);
trueDelaysAdjusted = delays - (delays(1) - delaysFit(1));

maxDelta = max(abs(trueDelaysAdjusted -  delaysFit))

%%

Xa = TrialDataUtilities.Data.removeDelaysMultiAnalogTensor(X, delaysFit, 'fillMode', 'hold');

Xa_offset = bsxfun(@plus, Xa, 0.001*(1:R)');
plot(squeeze(Xa_offset(:, :, C))');