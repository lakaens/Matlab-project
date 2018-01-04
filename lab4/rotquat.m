function [qrotated]=rotquat(q)

q0=q(1);
qv=q(2:4);
qx= [0 -q(4) q(3);q(4) 0 -q(2);-q(3) q(2) 0];
qrotated=((q0^2)-(qv'*qv))*eye(3)+(2*qv*qv')+2*q0*qx;