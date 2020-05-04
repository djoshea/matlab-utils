function [C, IA, IC] = uniqueStruct( A )
% just like unique, except for struct arrays

    hashFn = @(s) sum(typecast(Matdb.DataHash(s, struct('Format', 'uint8')), 'double'));
    aHash = arrayfun(hashFn, A);
    
    [~, IA, IC] = unique(aHash);
    IA = sort(IA); % undo the hash sorting
    C = A(IA);
    
%     U = [];
%     IC = [];
%     IA = nan(size(C));
%     for iC = 1:numel(C)
%         [tf, index] = isMemberStruct(C(iC), U);
%         if(~tf)
%             U = cat(1, U, C(iC));
%             IC  = cat(1,IC,iC);
%             index = numel(IC);
%         end
%         
%         IA(iC) = index;
%     end
%     
    
end

