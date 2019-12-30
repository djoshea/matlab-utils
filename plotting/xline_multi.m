function h = xline_multi(vals, linespec, labels, varargin)

p = inputParser();
p.addParameter('Color', [], @(x) true);
p.KeepUnmatched = true;
p.parse(varargin{:});
extraArgs = struct2paramValueCell(p.Unmatched);

N = numel(vals);
if nargin < 2
    linespec = '-';
end
if nargin < 3
    labels = strings(N, 1);
end
if ischar(labels) || iscellstr(labels) %#ok<ISCLSTR>
    labels = string(labels);
end

colors = p.Results.Color;
if ~isempty(colors)
   if isnumeric(colors)
       if size(colors, 1) == 1
           colors = repmat({colors}, N, 1);
       else
           colors = mat2cell(colors, ones(N, 1), 3);
       end
   else
       if ischar(colors) || iscellstr(colors)
           colors = string(colors);
       end
       if numel(colors) == 1
           colors = repmat(colors, N, 1);
       end
   end
end
    
if numel(labels) == 1
    labels = repmat(labels, N, 1);
end

holding = ishold;
h = gobjects(N, 1);
for i = 1:N
    if ~isempty(colors)
        args = {'Color', colors{i}};
    else
        args = {};
    end
    h(i) = xline(vals(i), linespec, labels(i), args{:}, extraArgs{:});
    hold on;
end

if ~holding, hold off; end

end