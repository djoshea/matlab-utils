classdef TensorUtils
    % set of classes for building high-d matrices easily
    
    methods(Static)
        function t = mapToSizeFromSubs(sz, varargin)
            % t = mapTensor(sz, contentsFn = @(varargin) NaN, asCell = false)
            % build a tensor with size sz by passing subscripts inds to
            % contentsFn(sub1, sub2, ...) maps subscript indices as a vector to the contents
            % asCell == true --> returns cell, asCell == false returns matrix, defaults to false
            
            p = inputParser;
            p.addRequired('size', @(x) isempty(x) || (isvector(x) && isnumeric(x)));
            p.addOptional('contentsFn', [], @(x) isa(x, 'function_handle'));
            p.addOptional('asCell', false, @islogical);
            p.parse(sz, varargin{:});
            asCell = p.Results.asCell;
            contentsFn = p.Results.contentsFn;
            
            if isempty(sz)
                if asCell 
                    t = {};
                else
                    t = [];
                end
                return
            end

            nDims = length(sz);
            idxEachDim = arrayfun(@(n) 1:n, sz, 'UniformOutput', false);
            [subsGrids{1:nDims}] = ndgrid(idxEachDim{:});
            
            if isempty(contentsFn)
                if asCell
                    contentsFn = @(varargin) {};
                else
                    contentsFn = @(varargin) NaN;
                end
            end
            
            t = arrayfun(contentsFn, subsGrids{:}, 'UniformOutput', ~asCell);
        end

        function results = mapIncludeSubs(fn, varargin)
            % mapWithInds(fn, t1, t2, ...) calls fn(t1(subs), t2(subs), ..., subs) with subs
            % being the subscript indices where the element of t1, t2, etc.
            % was extracted
            
            for iArg = 1:length(varargin)
                if ~iscell(varargin{iArg})
                    varargin{iArg} = num2cell(varargin{iArg});
                end
            end
            tSubs = TensorUtils.containingSubscripts(size(varargin{1}));
            results = cellfun(fn, varargin{:}, tSubs, 'UniformOutput', false);
        end
        
        function results = mapIncludeSubsAndSize(fn, varargin)
            % mapWithInds(fn, t1, t2, ...) calls fn(t1(subs), t2(subs), ..., subs, sz) with subs
            % being the subscript indices where the element of t1, t2, etc.
            % was extracted and sz being size(t1) == size(t2).
            
            sz = size(varargin{1});
            fnWrap = @(varargin) fn(varargin{:}, sz);
            results = TensorUtils.mapIncludeSubs(fnWrap, varargin{:});
        end
        
        function t = containingLinearInds(sz)
            % build a tensor with size sz where each element contains the linear
            % index it would be accessed at, e.g. t(i) = i 
            t = TensorUtils.mapToSizeFromSubs(sz, @(varargin) sub2ind(sz, varargin{:}), false);
        end

        function t = containingSubscripts(sz)
            % build a tensor with size sz where each element contains the vector 
            % of subscripts it would be accessed at, e.g. t(i) = i 
            t = TensorUtils.mapToSizeFromSubs(sz, @(varargin) [varargin{:}], true);
        end

        function mat = ind2subAsMat(sz, inds)
            % sz is the size of the tensor
            % mat is length(inds) x length(sz) where each row contains ind2sub(sz, inds(i))
           
            ndims = length(sz);
            subsCell = cell(ndims, 1);
            
            [subsCell{:}] = ind2sub(sz, makecol(inds));
            
            mat = [subsCell{:}];
        end

        function inds = subMat2Ind(sz, mat)
            % sz is the size of the tensor
            % mat is length(inds) x length(sz) where each row contains ind2sub(sz, inds(i))
            % converts back to linear indices using sub2ind
           
            ndims = length(sz);
            subsCell = arrayfun(@(dim) mat(:, dim), 1:ndims, 'UniformOutput', false);
            
            inds = sub2ind(sz, subsCell{:});
        end
        
        function tCell = regroupAlongDimension(t, dim)
            % tCell{i} will be equivalent to squeeze(t(..., i, ...)) where i is in dimension t
            % for each row along dimension dim
            
            nAlong = size(t, dim);
            sqMask = arrayfun(@(n) true(n, 1), size(t), 'UniformOutput', false);
            tCell = cell(nAlong, 1);
            for iAlong = 1:nAlong;
                sqMask{dim} = iAlong;
                tCell{iAlong} = squeeze(t(sqMask{:}));
            end
        end

        function tSelect = squeezeSelectAlongDimension(t, dim, ind)
            % select ind along dimension dim and squeeze() the result
            % e.g. squeeze(t(:, :, ... ind, ...)) 
            
            sz = size(t);
            % generate masks by dimension that are equivalent to ':'
            maskByDimCell = arrayfun(@(d) true(sz(d), 1), 1:ndims(t), 'UniformOutput', false);
            maskByDimCell{dim} = ind;
            tSelect = makecol(squeeze(t(maskByDimCell{:})));
        end

        function tCell = squeezeSelectEachAlongDimensionAsCell(t, dim) 
            % returns a cell array tCell such that tCell{i} = squeezeSelectAlongDimension(t, dim, i)

            sz = size(t);
            % generate masks by dimension that are equivalent to ':'
            maskByDimCell = arrayfun(@(d) true(sz(d), 1), 1:ndims(t), 'UniformOutput', false);

            tCell = cell(sz(dim), 1);
            for ind = 1:sz(dim)
                maskByDimCell{dim} = ind;
                tCell{ind} = makecol(squeeze(t(maskByDimCell{:})));
            end
        end

        function vec = flatten(t)
            vec = makecol(t(:));
        end
        
        function mat = flattenAlongDimension(t, dim)
            % returns a 2d matrix where mat(i, :) is the flattened vector of tensor
            % values from each t(..., i, ...) where i is along dim
            
            nAlong = size(t, dim);
            nWithin = numel(t) / nAlong;
            if iscell(t)
                mat = cell(nAlong, nWithin);
            else
                mat = nan(nAlong, nWithin);
            end
            
            sqMask = arrayfun(@(n) true(n, 1), size(t), 'UniformOutput', false);
            for iAlong = 1:nAlong
                sqMask{dim} = iAlong;
                within = t(sqMask{:}); 
                mat(iAlong, :) = within(:);
            end
        end
        
        function tCell = flattenAlongDimensionAsCell(t, dim)
            % returns a cell array of length size(t, dim)
            % where each element is the flattened vector of tensor
            % values from each t(..., i, ...) where i is along dim
            tCell = TensorUtils.regroupAlongDimension(t, dim);
            for iAlong = 1:length(tCell)
                tCell{iAlong} = tCell{iAlong}(:);
            end
        end
    end
    
end
