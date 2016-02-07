function OK = EraseTfiles(self)

% OK = EraseTfiles(MCD)
% also erases matching WV and CQ files

MCD = self;
MCS = MClust.GetSettings();

nClust = length(MCD.Clusters);

fc = FindFiles([MCD.TTfn '_*.t*'], 'StartingDirectory', MCD.TTdn, 'CheckSubdirs', 0);
fc = cat(1, fc, FindFiles([MCD.TTfn '_*._t*'], 'StartingDirectory', MCD.TTdn, 'CheckSubdirs', 0));

for iC = 1:length(fc)
    [fd,fn,xt] = fileparts(fc{iC});
    
    fnCQ = fullfile(fd,[fn '-CluQual.mat']);
    fnWV = fullfile(fd,[fn '-wv.mat']);
    
    if exist(fc{iC}, 'file')
        delete(fc{iC});
    end
    if exist(fnCQ, 'file')
        delete(fnCQ);
    end
    if exist(fnWV, 'file')
        delete(fnWV);
    end
end

OK = true;