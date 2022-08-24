function vals = catfields(S, args)
    arguments
        S (1, 1) struct
        args.fields (:, 1) string = fieldnames(S);
        args.asCell (1, 1) logical = true;
        args.flattenEach (1, 1) logical = true;
    end
    % concatenates each field of a struct
    flds = args.fields;

    vals = cell(numel(flds), 1);
    for iF = 1:numel(flds)
        vals{iF} = S.(flds{iF});
        if args.flattenEach
            vals{iF} = vals{iF}(:);
        end
    end
    if ~args.asCell
        vals = cat(1, vals{:});
    end
end