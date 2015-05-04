function importStr = getPackageImportString(varargin)

package = getPackage('stackOffset', 1, varargin{:});
if isempty(package)
    importStr = '';
else
    importStr = sprintf('%s.*', package);
end

end
