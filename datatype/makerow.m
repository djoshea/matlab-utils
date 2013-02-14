function rowVec = makerow( vec )
% rowVec = makeRow(vec)
% if it's a vector, rotate to row vector, else do nothing
    
if(size(vec,2) == 1 && isvector(vec))
    rowVec = vec';
else
    rowVec = vec;
end
        

end

