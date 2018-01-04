function [w]=rotamela(q,p)

p0=p(1);
pv=p(2:4);
q0=q(1);
qv=q(2:4);


w=zeros(4,1);
w(1)= q0*p0-(qv'*pv);
w(2:4)= q0*pv+p0*qv+cross(qv,pv);

end