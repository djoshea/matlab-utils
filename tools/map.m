function varargout = map(fn, varargin)
    % works just like cellfun or arrayfun  except auto converts each arg 
    % to a cell so that cellfun may be used. Returns a cell array with 
    % the same size as the tensor
    %
    % for outputs where the output is a scalar numeric value, converts to 
    % a matrix, otherwise keeps as cell
    
    % convert all inputs to cells
    for iArg = 1:numel(varargin)
        if ~iscell(varargin{iArg})
            varargin{iArg} = num2cell(varargin{iArg});
        end
    end
    
    [varargout{1:nargout}] = cellfun(fn, varargin{:}, 'UniformOutput', false);
    
    % convert scalar numeric cells back to matrices
    for iArg = 1:numel(varargout)
        if all(cellfun(@(x) isnumeric(x) && isscalar(x), varargout{iArg}))
            varargout{iArg} = cell2mat(varargout{iArg});
        end
    end
end