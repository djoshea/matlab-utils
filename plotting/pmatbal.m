function [h, hcbar] = pmatbal(m, varargin)

p = inputParser();
p.addParameter('colormap', 'default', @(x) ischar(x) || ismatrix(x) || isa(x, 'function_handle'));
p.addParameter('L', NaN, @isscalar);
p.KeepUnmatched = true;
p.parse(varargin{:});

cmap = p.Results.colormap;
if isa(cmap, 'function_handle')
    cmap = cmap(256);
elseif isstringlike(cmap)
    switch char(cmap)
        case 'default'
            cmap = flipud(TrialDataUtilities.Color.cbrewer('div', 'RdBu', 256));
        case 'reverse'
            cmap = TrialDataUtilities.Color.cbrewer('div', 'RdBu', 256);
        case 'RdBk'
            cmap = [103 0 31;112 0 31;121 1 32;130 3 33;138 5 34;146 8 35;154 10 36;161 14 38;167 17 40;173 20 41;178 24 43;183 28 45;187 34 47;191 40 50;195 48 54;198 56 57;201 64 61;204 72 65;208 81 69;211 89 73;214 96 77;217 103 81;221 110 86;224 117 91;228 125 96;231 132 101;235 139 107;238 146 112;240 152 118;242 159 124;244 165 130;245 171 136;247 177 143;248 183 150;249 189 157;250 194 164;251 200 172;251 205 179;252 210 186;253 215 193;253 219 199;253 224 206;254 228 213;254 233 220;254 238 228;254 242 235;255 246 241;255 250 247;255 253 251;255 254 254;255 255 255;254 254 254;252 252 252;249 249 249;246 246 246;241 241 241;237 237 237;232 232 232;228 228 228;224 224 224;220 220 220;217 217 217;213 213 213;210 210 210;206 206 206;202 202 202;198 198 198;194 194 194;190 190 190;186 186 186;182 182 182;177 177 177;172 172 172;167 167 167;162 162 162;157 157 157;151 151 151;146 146 146;140 140 140;135 135 135;129 129 129;124 124 124;118 118 118;112 112 112;106 106 106;100 100 100;94 94 94;88 88 88;83 83 83;77 77 77;72 72 72;66 66 66;61 61 61;56 56 56;51 51 51;46 46 46;41 41 41;36 36 36;31 31 31;26 26 26] / 255;
        case 'balance'
            cmap = TrialDataUtilities.Color.cmocean('balance');
        otherwise
            cmap = TrialDataUtilities.Color.cbrewer('div', cmap, 256);
    end
end

% visualize a matrix using pcolor

[h, hcbar] = pmat(m, p.Unmatched);
colormap(cmap);
L = abs(p.Results.L);
if isnan(L)
    L = gather(max(abs(m(:))));
end
caxis([-L-eps L+eps]);
