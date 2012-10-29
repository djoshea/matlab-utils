function U = uniqueStruct( S )
% just like unique, except for struct arrays
    U = [];
    for iS = 1:length(S)
        if(~isMemberStruct(S(iS), U))
            U = cat(1, U, S(iS));
        end
    end
end

