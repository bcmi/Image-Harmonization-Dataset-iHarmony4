function p = replaceStructFields(p, op)
%replaces fields in p with fields in op.
fnames = fieldnames(op);
for(i=1:numel(fnames))
    if(~isfield(p, fnames{i}))
        %fprintf(1, 'skipping extra field: %s\n', fnames{i})
        continue
    end
    if(isfield(p, fnames{i}) && isstruct(p.(fnames{i})))
        p.(fnames{i}) = replaceStructFields(p.(fnames{i}), op.(fnames{i}));
    else
        p.(fnames{i}) = op.(fnames{i});
    end
end