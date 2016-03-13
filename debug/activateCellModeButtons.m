desktop = com.mathworks.mde.desk.MLDesktop.getInstance;
jEditor = desktop.getGroupContainer('Editor').getTopLevelAncestor;

btns = findjobj(jEditor, 'nomenu', 'class', 'com.mathworks.toolstrip.components.TSButton');

for i = 1:numel(btns)
    btns(i).Enabled = true;
end