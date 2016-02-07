function names = GetFeatureNames( self )

% returns feature names for display

nF = length(self.Features);
names = cell(nF,1);
for iF = 1:nF
    names{iF} = self.Features{iF}.name;
end

end

