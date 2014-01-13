% Script that is useful for sharing code with others in the lab. It uses fdep to find all
% dependencies for your script/function of interest, and then copies them to a specified
% directory.
% NOTE: Doesn't seem to work on scripts, only on functions
% NOTE2: You need to have the fdep utility, available at
% http://www.mathworks.com/matlabcentral/fileexchange/17291-fdep-a-pedestrian-function-dependencies-finderv
functions = {'nevExtractAnalog'};
shareTo = '~/Desktop/forCora/';


keepDirDepth = 1; % if it finds a dependency function, it will copy that function
                  % over to shareTo. But rather than dumping all the functions in one place, it can go back
                  % by this many directories (0 meaning flat dependencies) in the path of the dependent function
                  % to preserve some structure in your share folder

if shareTo(end) ~= filesep
    shareTo(end+1) = filesep;
end
                  
failList = {}; % keep track of which dependency files did not copy                 
for iFunc = 1 : numel( functions )
    myfunc = functions{iFunc};
    
    % Find the function, cd to it
    d = which( myfunc );
    if isempty( d )
        error( 'Could not find your startFunction. Is it on the MATLAB path?' )
    end
    filesepIdx = find( d == filesep );
    path = d( 1:filesepIdx(end) );
    cd( path );

    %% Call fdep
    p = fdep( myfunc );
    mydep = p.fun;
    % add this fu
    
    % Now loop through these dependencies and copy them
    for iDep = 1 : numel( mydep )
       thisFile = mydep{iDep}; 
       filesepIdx = find( thisFile == filesep );
       keepSubdirs = thisFile( filesepIdx(end-keepDirDepth)+1:filesepIdx(end) );
       fileName = thisFile( filesepIdx(end)+1:end );
       copyTo = [shareTo keepSubdirs];
       if ~isdir( copyTo )
           mkdir( copyTo )
       end
       % copy
       status = copyfile( thisFile, [copyTo fileName] );
       if status
           failList{end+1} = thisFile;
       end
    end

end