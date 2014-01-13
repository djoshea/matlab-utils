classdef TensorUtils
    % set of classes for building, manipulating, and computing on 
    % high-d (or arbitrary-d) matrices easily
    methods(Static) % Mapping, construction via callback
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
                for i = 1:nargout
                    if asCell 
                        varargout{i} = {};
                    else
                        varargout{i} = [];
                    end
                end
                return
            end

            sz = TensorUtils.expandScalarSize(sz);
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
            % convert scalar numeric cells back to matrices
            for iArg = 1:numel(varargout);
                if all(cellfun(@(x) isnumeric(x) && isscalar(x), varargout{iArg}));
                    varargout{iArg} = cell2mat(varargout{iArg});
                end
            end
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
            % varargout = mapSlices(fn, spanDims, varargin)
            %
            % this acts like map, calling fn(varargin{1}(ind),varargin{2}(ind))
            % except rather than being called on each element of varargin{:}
            % individually, it is called on slices of the tensor(s) at once. These slices
            % are created by selecting all elements along the dimensions in spanDims and 
            % repeating this over each set of subscripts along the other dims.
            % The slices passed to fn will not be squeezed, so they will
            % have singleton dimensions for dim in spanDim. Call
            % .squeezeDims(in, spanDim) to obtain a squeezed slice.
            % 
            % The result will be reassembled into a tensor, whose size is determined by
            % the sizes of dimensions not in spanDim. Because the output
            % values will be stored as cell tensor elements, there are no
            % constraints on what these outputs look like
           
            sz = size(varargin{1});
            nd = ndims(varargin{1});
            nArgs = length(varargin);
            
            % we select individual slices by selecting each along the non-spanned dims 
            dim = setdiff(1:nd, spanDim);
            
            % slice through each of the varargin
            tCellArgs = cellfun(@(t) TensorUtils.selectEachAlongDimension(t, dim), ...
                varargin, 'UniformOutput', false);

            % run the function on each slice
            [resultCell{1:nargout}] = cellfun(fn, tCellArgs{:}, 'UniformOutput', false);

            varargout = resultCell;
            
            % (old) reassemble the result 
            % varargout = cellfun(@(r) TensorUtils.reassemble(r, dim), resultCell, 'UniformOutput', false);
        end
        
        function varargout = mapSlicesInPlace(fn, spanDim, varargin)
            % This function acts very similarly to mapSlices. The only
            % difference is that fn must return outputs that has the same
            % size and shape as it's inputs. Provided this constraint is
            % met, the output will be a tensor that has the same shape as
            % the input tensor. Effectively you loop through the
            % input tensors one slice at a time, transform that slice in
            % place via slice = fn(slice) and rebuild the output tensor one
            % slice at a time.
            
            [resultCell{1:nargout}] = TensorUtils.mapSlices(fn, spanDim, varargin{:});
            nonSpanDims = TensorUtils.otherDims(size(resultCell{1}), spanDim);
            varargout = cellfun(@(r) TensorUtils.reassemble(r, nonSpanDims), resultCell, 'UniformOutput', false);
        end
        
        function varargout = mapFromAxisLists(fn, axisLists, varargin)
            % varargout = mapToSizeFromAxisElements(sz, [fn = @(varargin) varargin], axis1, axis2, ...)
            % build a tensor with size sz by setting 
            % tensor(i,j,k,...) = fn(axis1{i}, axis2{j}, axis3{k})
            % (or axis(i) for numeric arrays)
            % if fn is omitted returns a cell array of 
            % {axis1{i}, axis2{j}, axis3{j}}
            
            p = inputParser;
            p.addParamValue('asCell', true, @islogical);
            p.parse(varargin{:});
            
            if isempty(fn)
                fn = @(varargin) varargin;
            end
            if iscell(axisLists)
                sz = cellfun(@numel, axisLists);
            else
                sz = arrayfun(@numel, axisLists);
            end

            [varargout{1:nargout}] = TensorUtils.mapToSizeFromSubs(sz, @indexFn, 'asCell', p.Results.asCell);
            
            function varargout = indexFn(varargin)
                inputs = cellvec(numel(axisLists));
                for iAx = 1:numel(axisLists)
                    if iscell(axisLists{iAx})
                        inputs{iAx} = axisLists{iAx}{varargin{iAx}};
                    else
                        inputs{iAx} = axisLists{iAx}(varargin{iAx});
                    end
                end
                [varargout{1:nargout}] = fn(inputs{:});
            end
           
        end
    end

    methods(Static) % Dimensions and sizes
        function out = emptyWithSameType(in, szOut)
            % create out as size szOut with same type as in (either cell or
            % nans)
            if iscell(in)
                out = cell(szOut);
            else
                out = nan(szOut);
            end
        end
            
        function tf = isvector(vec)
            % like isvector except works for high-d vectors as well
            sz = size(vec);
            tf = nnz(sz ~= 1) == 1 && ~any(sz == 0);
        end
        
        function sz = sizeMultiDim(t, dims)
            % sz = sizeMultiDim(t, dims) : sz(i) = size(t, dims(i))
            szAll = size(t);
            sz = arrayfun(@(d) szAll(d), dims);
        end

        function sz = expandScalarSize(sz)
            % if sz (size) is a scalar, make it into a valid size vector by
            % appending 1 to the end. i.e. 3 --> [3 1]
            if isempty(sz)
                sz = [0 0];
            elseif isscalar(sz)
                sz = [sz 1];
            end
        end
        
        % pads sz with 1s to make it nDims length
        function sz = expandSizeToNDims(sz, nDims)
            szPad = ones(nDims - numel(sz), 1);
            sz(end+1:nDims) = szPad;
        end
        
        function tf = compareSizeVectors(sz1, sz2)
            nDims = max(numel(sz1), numel(sz2));
            tf = isequal(TensorUtils.expandSizeToNDims(sz1, nDims), ....
                TensorUtils.expandSizeToNDims(sz2, nDims));
        end
            
        function other = otherDims(sz, dims)
            % otherDims(t, dims) returns a list of dims in t NOT in dims
            % e.g. if ndims(t) == 3, dims = 2, other = [1 3]
            allDims = 1:length(sz);
            other = makecol(setdiff(allDims, dims));
        end
    end
    
    methods(Static) % Indices and subscripts
        function t = containingLinearInds(sz)
            % build a tensor with size sz where each element contains the linear
            % index it would be accessed at, e.g. t(i) = i 
            sz = TensorUtils.expandScalarSize(sz);
            t = TensorUtils.mapToSizeFromSubs(sz, @(varargin) sub2ind(sz, varargin{:}), false);
        end

        function t = containingSubscripts(sz, asCell)
            sz = TensorUtils.expandScalarSize(sz);
            
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
            sz = TensorUtils.expandScalarSize(sz);
            
            % sz is the size of the tensor
            % mat is length(inds) x length(sz) where each row contains ind2sub(sz, inds(i))
           
            ndims = length(sz);
            subsCell = cell(ndims, 1);
            
            [subsCell{:}] = ind2sub(sz, makecol(inds));
            
            mat = [subsCell{:}];
        end

        function inds = subMat2Ind(sz, mat)
            sz = TensorUtils.expandScalarSize(sz);
            
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

    methods(Static) % Selection Mask generation        
        function maskByDim = maskByDimCell(sz)
            sz = TensorUtils.expandScalarSize(sz);

            % get a cell array of selectors into each dim that would select
            % every element if used via t(maskByDim{:})
            maskByDim = arrayfun(@(n) true(n, 1), sz, 'UniformOutput', false);
        end

        % the next few methods accept a dim and select argument
        % if dim is a scalar, select is a logical or numeric vector to use 
        % for selecting along dim. If dim is a vector, select is a cell array of
        % vectors to be used for selecting along dim(i)
        function maskByDim = maskByDimCellSelectAlongDimension(sz, dim, select)
            sz = TensorUtils.expandScalarSize(sz);

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
            sz = TensorUtils.expandScalarSize(sz);

            % return a logical mask where for tensor with size sz
            % we select t(:, :, select, :, :) where select acts along dimension dim

            mask = false(sz); 
            maskByDim = TensorUtils.maskByDimCellSelectAlongDimension(sz, dim, select);
            mask(maskByDim{:}) = true;
        end
        
        function maskByDim = maskByDimCellSelectPartialFromOrigin(sz, dim, select)
            maskByDim = TensorUtils.maskByDimCell(sz);
            maskByDim(dim) = arrayfun(@(n) 1:n, select, 'UniformOutput', false);
        end
        
        function mask = maskSelectPartialFromOrigin(sz, dim, select)
            % select the first select(i) items from dim(i) 
            % for i = 1:numel(sz)
            selectCell = arrayfun(@(n) 1:n, select, 'UniformOutput', false);
            mask = TensorUtils.maskSelectAlongDimension(sz, dim, selectCell);
        end                 
    end

    methods(Static) % Squeezing along particular dimensions
        function tsq = squeezeDims(t, dims)
            % like squeeze, except only collapses singleton dimensions in list dims
            siz = size(t);
            dims = dims(dims <= ndims(t));
            dims = dims(siz(dims) == 1);
            siz(dims) = []; % Remove singleton dimensions.
            siz = [siz ones(1,2-length(siz))]; % Make sure siz is at least 2-D
            tsq = reshape(t,siz);
        end
        
        function newDimIdx = shiftDimsPostSqueeze(sz, squeezeDims, dimsToShift)
            assert(isvector(sz), 'First arg must be size');
            % when squeezing along squeezeDims, the positions of dims in
            % dimsToShift will change. The new dim idx will be returned
            origDims = 1:length(sz);
            squeezeDims = squeezeDims(squeezeDims <= length(sz));
            remainDims = setdiff(origDims, squeezeDims);
            
            [~, newDimIdx] = ismember(dimsToShift, remainDims);
            newDimIdx(newDimIdx==0) = NaN;
        end

        function tsq = squeezeOtherDims(t, dims)
            other = TensorUtils.otherDims(size(t), dims);
            tsq = TensorUtils.squeezeDims(t, other);
        end
    end

    methods(Static) % Regrouping, Nesting, Selecting, Reshaping
        function tCell = regroupAlongDimension(t, dims)
            % tCell = regroupAlongDimension(t, dims)
            % returns a cell tensor of tensors, where the outer tensor is over 
            % the dims in dims. Each inner tensor is formed by selecting over
            % the dims not in dims.
            %
            % e.g. if size(t) = [nA nB nC nD] and dims is [1 2],
            % size(tCell) = [nA nB] and size(tCell{iA, iB}) = [nC nD]
            
            tCell = TensorUtils.squeezeSelectEachAlongDimension(t, dims);
            tCell = TensorUtils.squeezeOtherDims(tCell, dims);
        end

        function tCell = nestedRegroupAlongDimension(t, dimSets)
            assert(iscell(dimSets), 'dimSets must be a cell array of dimension sets');

            dimSets = makecol(cellfun(@makecol, dimSets, 'UniformOutput', false));
            allDims = cell2mat(dimSets);

            assert(length(unique(allDims)) == length(allDims), ...
                'A dimension was included in multiple dimension sets');

            otherDims = TensorUtils.otherDims(size(t), allDims);
            if ~isempty(otherDims)
                dimSets{end+1} = otherDims;
            end

            tCell = inner(t, dimSets);
            return;

            function tCell = inner(t, dimSets)
                if length(dimSets) == 1
                    % special case, no grouping, just permute dimensions and
                    % force to be cell
                    tCell = permute(t, dimSets{1});
                    if ~iscell(tCell)
                        tCell = num2cell(tCell);
                    end
                elseif length(dimSets) == 2
                    % last step in recursion, call final regroup
                    tCell = TensorUtils.regroupAlongDimension(t, dimSets{1});
                else
                    % call inner on each slice of dimSets{1}
                    remainingDims = TensorUtils.otherDims(size(t), dimSets{1});
                    tCell = TensorUtils.mapSlices(@(t) mapFn(t, dimSets), ...
                        remainingDims, t);
                    tCell = TensorUtils.squeezeOtherDims(tCell, dimSets{1});
                end
            end
            
            function tCell = mapFn(t, dimSets)
                remainingDimSets = cellfun(...
                    @(dims) TensorUtils.shiftDimsPostSqueeze(size(t), dimSets{1}, dims), ...
                    dimSets(2:end), 'UniformOutput', false);
                tCell = inner(TensorUtils.squeezeDims(t, dimSets{1}), remainingDimSets);
            end
            
        end

        function [res mask] = selectAlongDimension(t, dim, select, squeezeResult)
            if nargin < 4
                squeezeResult = false;
            end
            sz = size(t);
            maskByDim = TensorUtils.maskByDimCellSelectAlongDimension(sz, dim, select);
            res = t(maskByDim{:});

            if squeezeResult
                % selectively squeeze along dim
                res = TensorUtils.squeezeDims(res, dim);
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
            if nargin < 3
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
                'contentsFn', @(varargin) TensorUtils.selectAlongDimension(t, dim, ...
                varargin(dim), squeezeEach));
        end

        function tCell = squeezeSelectEachAlongDimension(t, dim) 
            % returns a cell array tCell such that tCell{i} = squeezeSelectAlongDimension(t, dim, i)
            tCell = TensorUtils.selectEachAlongDimension(t, dim, true);
        end

        function t = reassemble(tCell, dim)
            % given a tCell in the form returned by selectEachAlongDimension
            % dim is the dimension embedded within each slice
            % return the original tensor

            nd = ndims(tCell);
            szOuter = size(tCell);
            szOuter = [szOuter ones(1, nd - length(szOuter))];
            szInner = size(tCell{1});
            szInner = [szInner ones(1, nd - length(szInner))];

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
    
    methods(Static) % Slice orienting and repmat
        % A slice is a selected region of a tensor, in which each dimension
        % either selects all of the elements (via :), or 1 of the elements.
        % This is the 2-d matrix equivalent of a row (slice with spanDim = 1)
        % or a column (slice with spanDim = 2). For a 3-d tensor, a slice
        % along spanDim = [2 3] would look like t(1, :, :);
        function out = orientSliceAlongDims(slice, spanDim)
            % given a slice with D dimensions, orient slice so that it's
            % dimension(i) becomes dimension spanDim(i)
            
            szSlice = size(slice);
            ndimsSlice = length(spanDim);
            if ndimsSlice == 1
                % when spanDim is scalar, expect column vector or makecol
                slice = makecol(squeeze(slice));
            end
            
            ndimsOut = max(2, max(spanDim));
            sliceHigherDims = ndimsSlice+1:ndimsOut;
            nonSpanDims = setdiff(1:ndimsOut, spanDim);
            
            permuteOrder = nan(1, ndimsOut);
            permuteOrder(spanDim) = 1:ndimsSlice;
            permuteOrder(nonSpanDims) = sliceHigherDims;
            
            out = permute(slice, permuteOrder);
        end
        
        function out = orientSliceAlongSameDimsAs(slice, refSlice)
            % orient slice such that it has the same shape as refSlice
            spanDim = find(size(refSlice) > 1);
            if ~isempty(spanDim);
                out = TensorUtils.orientSliceAlongDims(slice, spanDim);
            else
                out = slice;
            end
        end
        
        function out = repmatSliceAlongDims(slice, szOut, spanDim)
            % given a slice with ndims(slice) == numel(spanDim), 
            % orient that slice along the dimensions in spanDim and repmat
            % it so that the output is size szOut.
            
            nSpan = 1:length(spanDim);
            ndimsOut = length(szOut);
            
            sliceOrient = TensorUtils.orientSliceAlongDims(slice, spanDim);
            
            repCounts = szOut;
            repCounts(spanDim) = 1;
            
            out = repmat(sliceOrient, repCounts);
        end
    end
    
    methods(Static) % Size expansion
        function out = singletonExpandToSize(in, szOut)
            % expand singleton dimensions to match szOut
            szIn = size(in);
            repCounts = szOut;
            repCounts(szIn ~= 1) = 1;
            out = repmat(in, repCounts);
        end
        
        function out = expandAlongDims(in, dims, by)
            % expand by adding nans or empty cells for cell array
            sz = size(in);
            sz(dims) = sz(dims) + by;
            
            out = TensorUtils.emptyWithSameType(in, sz);
            
            % build the mask over out to assign in into
            szInDims = TensorUtils.sizeMultiDim(in, dims);
            maskByDim = TensorUtils.maskByDimCellSelectPartialFromOrigin(size(out), dims, szInDims);
            
            out(maskByDim{:}) = in;
        end
    end

    methods(Static) % List resampling and shuffling along dimension
        function seedRandStream(seed)
            if nargin == 0
                seed = 'Shuffle';
            end
            s = RandStream('mt19937ar', 'Seed', seed);
            RandStream.setGlobalStream(s);
        end
        
        % Each of these methods apply to cell tensors containing vector
        % lists of values. They will move values around among the
        % different cells, i.e. from one list to another, but generally
        % they each preserve the total count within each list.
        % They also typically act along one or more dimensions, in that
        % they will move values among the cells that lie along a particular
        % dimension(s), but not among cells that lie at different positions
        % on the other dimensions. For example, if t is a 2-d matrix,
        % shuffling along dimension 1 would move values among cells that
        % lie along the same row, but not across rows. Here, the row would
        % be referred to as a slice of the matrix.
        %
        % Inputs are not required to have lists be column vectors, but the
        % output will have column vectors in each cell.
        %
        % The various functions differ in how they move the values around
        % and whether or not they sample with replacement, which would
        % allow some values to be replicated multiple times and others to
        % not appear in the final lists.

        function t = listShuffleAlongDimension(t, iA, replace)
            % t is a cell tensor of vectors. For each slice along iA, i.e. 
            % t(i, j, ..., :, ..., k) where the : is in position iA,
            % shuffle the elements among all cells of that slice,
            % preserving the total number in each cell. If replace is true
            % shuffles with replacement.
            
            if nargin < 3
                replace = false;
            end
                        
            t = TensorUtils.mapSlicesInPlace(@shuffleFn, iA, t);
            
            function sNew = shuffleFn(s)
                list = TensorUtils.combineListFromCells(s);
                list = randsample(list, numel(list), replace);
                sNew = TensorUtils.splitListIntoCells(list, TensorUtils.map(@numel, s));
            end
        end
        
        function t = listResampleFromSame(t)
            % resample from replacement within each list, i.e. don't move
            % anything between lists, just take each list and resample with
            % replacement from itself.
            t = TensorUtils.map(@(list) randsample(list, numel(list), true), t); 
        end
        
        function t = listResampleFromSpecifiedAlongDimension(t, from, iA, replace)
            % resample from replacement from other lists, according to a
            % specified set of cell elements along each slice. from{i} is a
            % specifies the linear index (or indices) of which cells to
            % sample from when building the list for the cell at position i
            % along that slice. If replace is true, samples with
            % replacement.
            % 
            % Example: listResampleFromSpecified(t, {1, [1 2]}, 1) where t
            % is a 3 x 2 matrix. For each row i of t, the new list at cell
            % t{i, 1} will be built by sampling from list in t{i, 1}. 
            % The new list at cell t{i, 2} will be built by sampling from
            % both t{i, 1} and t{i, 2}.
            
            if nargin < 4
                replace = false;
            end
                        
            t = TensorUtils.mapSlicesInPlace(@resampleFn, iA, t);
            
            function sNew = resampleFn(s)
                sNew = cell(size(s));
                for i = 1:numel(s)
                    list = TensorUtils.combineListFromCells(s(from{i}));
                    sNew{i} = randsample(list, numel(s{i}), replace);
                end
            end
        end
        
        function list = combineListFromCells(t)
            % gathers all lists from t{:} into one long column vector
            t = cellfun(@makecol, t, 'UniformOutput', false);
            list = cell2mat(t(:));
        end
        
        function t = splitListIntoCells(list, nPerCell)
            % list is a vector list, nPerCell is a numeric tensor
            % specifying how many elements to place in each list.
            % This undoes combineListFromCells
            t = mat2cell(makecol(list), nPerCell(:), 1);
            t = reshape(t, size(nPerCell));
        end
            
    end
end
