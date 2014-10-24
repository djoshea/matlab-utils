function geeknote(varargin)

    home = char(java.lang.System.getProperty('user.home'));
    addToSysPath(fullfile(home, 'env/geeknote/bin'));
    system(['source ' fullfile(home, 'env/geeknote/bin/activate')]);
    
    status = system(['geeknote ' parse(varargin{:})]);
    
    function addToSysPath(dir)
        % update path
        p = getenv('PATH');
        pat1 = [dir ':'];
        pat2 = [':' dir];

        if isempty(strfind(p, pat1)) && isempty(strfind(p, pat2))
            setenv('PATH', [pat1 p]);
        end
    end

    function space_delimited_list = parse(varargin)
        space_delimited_list = cell2mat(...
        cellfun(@(s)([s,' ']),varargin,'UniformOutput',false));
    end
end