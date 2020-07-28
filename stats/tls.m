function B = tls(X,Y)
% from https://en.wikipedia.org/wiki/Total_least_squares

[m, n]   = size(X); %#ok<*ASGLU> % n is the width of X (X is m by n)
Z       = [X Y];                 % Z is X augmented with Y.
[U, S, V] = svd(Z,0);            % find the SVD of Z.
VXY     = V(1:n,1+n:end);        % Take the block of V consisting of the first n rows and the n+1 to last column
VYY     = V(1+n:end,1+n:end);    % Take the bottom-right block of V.
B       = -VXY/VYY;

end