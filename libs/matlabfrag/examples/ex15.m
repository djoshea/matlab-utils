%% Preamble -- not to appear in userguide
hfig = figure;
set(hfig,'units','centimeters','NumberTitle','off','Name','ex15');
pos = get(hfig,'position');
set(hfig,'position',[pos(1:2),8,6]);

load wind
wind_speed = sqrt(u.^2 + v.^2 + w.^2);

hpatch = patch(isosurface(x,y,z,wind_speed,35));
isonormals(x,y,z,wind_speed,hpatch)
set(hpatch,'FaceColor','red','EdgeColor','none');

[f vt] = reducepatch(isosurface(x,y,z,wind_speed,45),0.05);
daspect([1,1,1]);
hcone = coneplot(x,y,z,u,v,w,vt(:,1),vt(:,2),vt(:,3),2);
set(hcone,'FaceColor','blue','EdgeColor','none');

camproj perspective 
camva(25);

hlight = camlight('headlight');
set(hpatch,'AmbientStrength',.1,...
  'SpecularStrength',1,...
  'DiffuseStrength',1);
set(hcone,'SpecularStrength',1);

hsline = streamline(x,y,z,u,v,w,80,30,11);
xd = get(hsline,'XData');
yd = get(hsline,'YData');
zd = get(hsline,'ZData');
delete(hsline)

i=110;
campos([xd(i),yd(i),zd(i)])
camtarget([xd(i+5)+min(xd)/100,yd(i),zd(i)])
camlight(hlight,'headlight')
set(gca,'xticklabel','','yticklabel','','zticklabel','');
drawnow
%% Everything below appears in userguide
lighting phong;
set(gcf,'Renderer','zbuffer');
text(0,0,0,'smiley','userdata','matlabfrag:\blacksmiley');
drawnow;
matlabfrag('graphics/ex15');
%% The following is excluded from userguide