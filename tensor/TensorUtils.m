classdef TensorUtils
    % set of classes for building high-d matrices easily
    
    methods(Static)
        function varargout = mapToSizeFromSubs(sz, varargin)
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
            
            [varargout{1:nargout}] = arrayfun(contentsFn, subsGrids{:}, 'UniformOutput', ~asCell);
        end

        function varargout = map(fn, varargin)
            % works just like cellfun or arrayfun  except auto converts each arg 
            % to a cell so that cellfun may be used. Returns a cell array with 
            % the same size as the tensor
            for iArg = 1:length(varargin)
                if ~iscell(varargin{iArg})
                    varargin{iArg} = num2cell(varargin{iArg});
                end
            end
            [varargout{1:nargout}] = cellfun(fn, varargin{:}, 'UniformOutput', false);
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
        
        function varargout = mapIncludeSubsAndSize(fn, varargin)
            % mapWithInds(fn, t1, t2, ...) calls fn(t1(subs), t2(subs), ..., subs, sz) with subs
            % being the subscript indices where the element of t1, t2, etc.
            % was extracted and sz being size(t1) == size(t2).
            
            sz = size(varargin{1});
            fnWrap = @(varargin) fn(varargin{:}, sz);
            [varargout{1:nargout}] = TensorUtils.mapIncludeSubs(fnWrap, varargin{:});
        end

        function varargout = mapSlices(fn, spanDim, varargin) 
            % this acts like map, except rather than being called on each element 
            % individually, it is called on slices of the tensor at once. These slices
            % are created by selecting all elements along the dimensions in dims and 
            % repeating this over each set of subscripts along the other dims.
            %
            % The result will be reassembled into a tensor. If the function returns
            % a matrix or cell with the same size as its inputs, the output tensor will
            % have the same shape and size as the input.
           
            sz = size(varargin{1});
            nd = ndims(varargin{1});
            nArgs = length(varargin);
            
            % we select individual slices by selecting each along the non-spanned dims 
            dim = setdiff(1:nd, spanDim);
            
            % slice through each of the varargin
            tCellArgs = cellfun(@(t) TensorUtils.selectEachAlongDimension(t, dim), varargin,...
                'UniformOutput', false);

            % run the function on each slice
            [resultCell{1:nargout}] = cellfun(fn, tCellArgs{:}, 'UniformOutput', false);

            % reassemble the result
            varargout = cellfun(@(r) TensorUtils.reassemble(r, dim), resultCell, 'UniformOutput', false);
        end
    end

    methods(Static) % Indices and subscripts
        function t = containingLinearInds(sz)
            % build a tensor with size sz where each element contains the linear
            % index it would be accessed at, e.g. t(i) = i 
            t = TensorUtils.mapToSizeFromSubs(sz, @(varargin) sub2ind(sz, varargin{:}), false);
        end

        function t = containingSubscripts(sz, asCell)
            % asCell == true means each element is itself a cell rather then a vector of
            % subscripts
            if nargin < 2
                asCell = false;
            end

            % build a tensor with size sz where each element contains the vector 
            % of subscripts it would be accessed at, e.g. t(i) = i 
            if asCell
                t = TensorUtils.mapToSizeFromSubs(sz, @(varargin) varargin, true);
            else
                t = TensorUtils.mapToSizeFromSubs(sz, @(varargin) [varargin{:}]', true);
            end
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
            if ndims == 2 && any(sz==1)
                ndims = 1;
            end
            subsCell = arrayfun(@(dim) mat(:, dim), 1:ndims, 'UniformOutput', false);
            
            inds = sub2ind(sz, subsCell{:});
        end
    end

    methods(Static) % Selecting, reshaping
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

        function maskByDim = maskByDimCell(sz)
            % get a cell array of selectors into each dim that would select
            % every element if used via t(maskByDim{:})
            maskByDim = arrayfun(@(n) true(n, 1), sz, 'UniformOutput', false);
        end

        % the next few methods accept a dim and select argument
        % if dim is a scalar, select is a logical or numeric vector to use 
        % for selecting along dim. If dim is a vector, select is a cell array of
        % vectors to be used for selecting along dim(i)
        function maskByDim = maskByDimCellSelectAlongDimension(sz, dim, select)
            % get a cell array of selectors into each dim that effectively select
            % select{i} along dim(i). These could be used by indexing a tensor t
            % via t(maskByDim{:}) --> se selectAlongDimension
            if ~iscell(select)
                select = {select};
            end

            assert(length(dim) == length(select), 'Number of dimensions must match length of select mask cell array');
            maskByDim = TensorUtils.maskByDimCell(sz);
            maskByDim(dim) = select;
        end

        function mask = maskSelectAlongDimension(sz, dim, select)
            % return a logical mask where for tensor with size sz
            % we select t(:, :, select, :, :) where select acts along dimension dim

            mask = false(sz); 
            maskByDim = TensorUtils.maskByDimCellSelectAlongDimension(sz, dim, select);
            mask(maskByDim{:}) = true;
        end

        function [res mask] = selectAlongDimension(t, dim, select, squeezeResult)
            if nargin < 4
                squeezeResult = false;
            end
            sz = size(t);
            maskByDim = TensorUtils.maskByDimCellSelectAlongDimension(sz, dim, select);
            res = t(maskByDim{:});

            if squeezeResult;
                res = squeeze(res);
            end
        end

        function [res mask] = squeezeSelectAlongDimension(t, dim, select)
            % select ind along dimension dim and squeeze() the result
            % e.g. squeeze(t(:, :, ... ind, ...)) 
            
            [res mask] = TensorUtils.selectAlongDimension(t, dim, select, true);
        end

        function tCell = selectEachAlongDimension(t, dim, squeezeEach)
            % returns a cell array tCell such that tCell{i} = selectAlongDimension(t, dim, i)
            % optionally calls squeeze on each element 
            if nargin < 4
                squeezeEach = false;
            end
            
            sz = size(t);

            % generate masks by dimension that are equivalent to ':'
            maskByDimCell = TensorUtils.maskByDimCell(sz);

            dimMask = true(ndims(t), 1);
            dimMask(dim) = false;
            szResult = sz;
            szResult(dimMask) = 1;

            % oh so clever
            tCell = TensorUtils.mapToSizeFromSubs(szResult, 'asCell', true, ...
                'contentsFn', @(varargin) TensorUtils.selectAlongDimension(t, dim, varargin(dim), squeezeEach));
        end

        function tCell = squeezeSelectEachAlongDimension(t, dim) 
            % returns a cell array tCell such that tCell{i} = squeezeSelectAlongDimension(t, dim, i)
            tCell = TensorUtils.selectEachAlongDimension(t, dim, true);
        end

        function t = reassemble(tCell, dim)
            % given a tCell in the form returned by selectEachAlongDimension
            % return the original tensor

            szOuter = size(tCell);
            szInner = size(tCell{1});
            nd = length(szInner);

            % dimMask(i) true if i in dim
            dimMask = false(nd, 1);
            dimMask(dim) = true;

            % compute size of result t
            % use outerDims when its in dim, innerDims when it isn't
            szT = nan(1, ndims(tCell));
            szT(dimMask) = szOuter(dimMask);
            szT(~dimMask) = szInner(~dimMask);

            % rebuild t by grabbing the appropriate element from tCell
            subs = TensorUtils.containingSubscripts(szT);
            t = TensorUtils.mapToSizeFromSubs(szT, @getElementT, true);

            function el = getElementT(varargin)
                [innerSubs outerSubs] = deal(varargin);
                % index with dim into tt, non-dim into tt{i}
                [outerSubs{~dimMask}] = deal(1);
                [innerSubs{dimMask}] = deal(1);
                tEl = tCell{outerSubs{:}};
                if iscell(tEl)
                    el = tEl{innerSubs{:}}; 
                else
                    el = tEl(innerSubs{:});
                end
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
            
            sqMask = TensorUtils.maskByDimCell(size(t));
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
