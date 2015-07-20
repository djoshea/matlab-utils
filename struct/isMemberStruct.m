function [found, index] = isMemberStruct(A, S)
% just like ismember, except for struct and struct arrays, and only returns
% the index, not the useless boolean output argument
    nA = max(length(A), 1); % for empty A, return 0
    found = false(nA,1);
    index = zeros(nA,1);
    for iA = 1:length(A)
        for iS = 1:length(S)
            if(compareStruct(A(iA), S(iS)))
                % found!
                found(iA) = true;
                index(iA) = iS;
                break;
            end
        end
    end
end


