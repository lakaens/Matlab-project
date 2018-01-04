function [m]=Eaa2rotMat(u,angle)

%angle=angle*pi/180;
u=[u(1);u(2);u(3)];
modul=(sqrt((u(1)^2)+(u(2)^2)+(u(3)^2)));
u=u/modul;
ux= [0 -u(3) u(2);u(3) 0 -u(1);-u(2) u(1) 0];
m = eye(3) * cosd(angle) + (1-cosd(angle))*(u*u') + ux*sind(angle);

end