% clf;
% 
% ma = MultiAxis(gcf);
% ma.reset();
% ma.grid(2,3);
% 
% ma.axis(1,1);
% ylabel('hello');
% ma.axis(1,2);
% title('title');
% ma.axis(2,1);
% ma.axis(2,2);
% ylabel('hello');
% xlabel('hello');
% 
% ma.axis(1, 3);
% xlabel('AutoAxis X');
% ylabel('AutoAxis Y');
% title('Using AutoAxis');
% au = AutoAxis.replace();
% au.axisMargin = [2 2 1 1];
% 
% 
% ma.axis(2, 3);
% xlabel('AutoAxis X');
% ylabel('AutoAxis Y');
% title('Using AutoAxis');
% au = AutoAxis.replace();
% au.axisMargin = [2 2 1 1];
% 
% ma.update();

%% Test auto populate grid

clf;

dataOrig = randn(2, 100);
dataRot = randn(8, 2);
data = dataRot * dataOrig;

ma = MultiAxis(gcf);
ma.reset();

ma.root.grid(2,2);

i = 1;
idx = 1;
labels = 'abcd';

for row = 1:2
    for col = 1:2
        ma.root.axis(row, col);
        plot(data(idx, :), data(idx+1, :), 'o', 'MarkerSize', 4);
        ma.root.label(row, col, labels(i));
        idx = idx + 2;
        i = i+1;
    end
end

ma.root.installAutoAxes('autoAxes', true);
ma.root.rowShareAxisY([1 2]);
ma.root.colShareAxisX([1 2]);
ma.root.rowYLabel(1, 'y label 1');
ma.root.rowYLabel(2, 'y label 2');
ma.root.colXLabel(1, 'x label 1');
ma.root.colXLabel(2, 'x label 2');

ma.update;
ma.installCallbacks();

