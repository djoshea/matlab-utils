function CutterOption_EvalOverlap(self)

nC = length(self.Clusters);
Overlap = zeros(nC,nC);

Overlap(2:end,1) = 2:nC;
Overlap(1,2:end) = 2:nC;

for iC = 2:nC
    Ci = self.Clusters{iC};
    Overlap(iC,iC) = length(Ci.GetSpikes);
    for jC = (iC+1:nC)
        Cj = self.Clusters{jC};
        Overlap(iC,jC) = length(intersect(Ci.GetSpikes, Cj.GetSpikes));
        Overlap(jC,iC) = Overlap(iC,jC);
    end
end

disp(Overlap);
msgbox(num2str(Overlap, '%4d '), 'Overlap');