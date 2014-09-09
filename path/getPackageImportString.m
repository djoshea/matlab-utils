function importStr = getPackageImportString()

package = getPackage(1);
if isempty(package)
    importStr = '';
else
    importStr = sprintf('%s.*', package);
end

end
