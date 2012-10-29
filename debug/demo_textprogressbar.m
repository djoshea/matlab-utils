%demo_textprogressbar
%This a demo for textprogressbar script
textprogressbar('calculating outputs: ');
for i=1:100,
    textprogressbar(i/100);
    pause(0.02);
end
textprogressbar('done',true);


textprogressbar('saving data:         ');
for i=1:0.5:80,
    textprogressbar(i/100);
    pause(0.02);
end
textprogressbar('terminated',true);