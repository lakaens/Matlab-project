function [rmatrix]=eAngles2rotM(theta,phi,psi)


rmatrix=[cos(theta)*cos(phi) (cos(phi)*sin(theta)*sin(psi))-cos(psi)*sin(phi) cos(phi)*cos(psi)*sin(theta)+sin(phi)*sin(psi);
cos(theta)*sin(phi) sin(phi)*sin(theta)*sin(phi)+cos(psi)*cos(phi) sin(phi)*sin(theta)*cos(psi)-cos(phi)*sin(psi);
-sin(theta) cos(theta)*sin(psi) cos(theta)*cos(psi)];


end