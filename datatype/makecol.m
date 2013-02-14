function vec = makecol( vec )

% transpose if it's currently a row vector
if(size(vec,2) > size(vec, 1) && isvector(vec))
    vec = vec';
end

end

