function [vrot]=rotVbyq(v,q)

n=v/sqrt(v(1)^2+v(2)^2+v(3)^2);

v1=[0;n(1);n(2);n(3)];
qm=rotamela(v1,q);
q=[q(1);-q(2);-q(3);-q(4)];
result=rotamela(q,qm);
vrot=[result(2);result(3);result(4)];


end