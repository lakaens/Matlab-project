function varargout = trackBall(varargin)
% TRACKBALL MATLAB code for trackBall.fig
%      TRACKBALL, by itself, creates a new TRACKBALL or raises the existing
%      singleton*.
%
%      H = TRACKBALL returns the handle to a new TRACKBALL or the handle to
%      the existing singleton*.
%
%      TRACKBALL('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in TRACKBALL.M with the given input arguments.
%
%      TRACKBALL('Property','Value',...) creates a new TRACKBALL or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before trackBall_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to trackBall_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help trackBall

% Last Modified by GUIDE v2.5 07-Jan-2018 20:37:03

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @trackBall_OpeningFcn, ...
                   'gui_OutputFcn',  @trackBall_OutputFcn, ...
                   'gui_LayoutFcn',  [] , ...
                   'gui_Callback',   []);
if nargin && ischar(varargin{1})
    gui_State.gui_Callback = str2func(varargin{1});
end

if nargout
    [varargout{1:nargout}] = gui_mainfcn(gui_State, varargin{:});
else
    gui_mainfcn(gui_State, varargin{:});
end
% End initialization code - DO NOT EDIT
end

% --- Executes just before trackBall is made visible.
function trackBall_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to trackBall (see VARARGIN)


set(hObject,'WindowButtonDownFcn',{@my_MouseClickFcn,handles.axes1});
set(hObject,'WindowButtonUpFcn',{@my_MouseReleaseFcn,handles.axes1});
axes(handles.axes1);

handles.Cube=DrawCube(eye(3));

set(handles.axes1,'CameraPosition',...
    [0 0 5],'CameraTarget',...
    [0 0 -5],'CameraUpVector',...
    [0 1 0],'DataAspectRatio',...
    [1 1 1]);

set(handles.axes1,'xlim',[-3 3],'ylim',[-3 3],'visible','off','color','none');

% Choose default command line output for trackBall
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes trackBall wait for user response (see UIRESUME)
% uiwait(handles.figure1);
end

% --- Outputs from this function are returned to the command line.
function varargout = trackBall_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;
end
function my_MouseClickFcn(obj,event,hObject)

handles=guidata(obj);
xlim = get(handles.axes1,'xlim');
ylim = get(handles.axes1,'ylim');
mousepos=get(handles.axes1,'CurrentPoint');
xmouse = mousepos(1,1);
ymouse = mousepos(1,2);

if xmouse > xlim(1) && xmouse < xlim(2) && ymouse > ylim(1) && ymouse < ylim(2)

    set(handles.figure1,'WindowButtonMotionFcn',{@my_MouseMoveFcn,hObject});
    m0=GetMousePosition(xmouse,ymouse);
    setGlobalm0(m0);
    qk1=GetQuaternionFromVectors(m0, m0);
    setGlobalqk1(qk1);
end
guidata(hObject,handles)
end

function my_MouseReleaseFcn(obj,event,hObject)
handles=guidata(hObject);
set(handles.figure1,'WindowButtonMotionFcn','');
guidata(hObject,handles);
end
function my_MouseMoveFcn(obj,event,hObject)

handles=guidata(obj);
xlim = get(handles.axes1,'xlim');
ylim = get(handles.axes1,'ylim');
mousepos=get(handles.axes1,'CurrentPoint');
xmouse = mousepos(1,1);
ymouse = mousepos(1,2);

if xmouse > xlim(1) && xmouse < xlim(2) && ymouse > ylim(1) && ymouse < ylim(2)
    m1=GetMousePosition(xmouse,ymouse);
    r = getGlobalm0;
    dqk=GetQuaternionFromVectors(r, m1);
    qk1 = getGlobalqk1;
    qk=quaternionproduct(dqk,qk1);
    %setGlobalqk(qk);
    %%% DO things
    % use with the proper R matrix to rotate the cube
    R = [1 0 0; 0 -1 0;0 0 -1];
    R=matrixfromquaternion(qk);
    handles.Cube = RedrawCube(R,handles.Cube);
    [t,ph,ps]=rotM2eAngles(R);
    setGlobalt(t);
    setGlobalph(ph);
    setGlobalps(ps);
    [axis,pea]=rotMat2Eaa(R);
    [axisr,angler]=rotMat2Eaa(R);
    rvect=rotationvectorfromepa(axisr,angler);
    %quaternion guide
    q=getGlobalqk;
    set(handles.qk1,'string', qk(1));
    set(handles.qk2,'string', qk(2));
    set(handles.qk3,'string', qk(3));
    set(handles.qk4,'string', qk(4));
    
    %euler angles guide
    tangle=getGlobalt;
    set(handles.ea1,'string', tangle);
    phangle=getGlobalph;
    set(handles.ea2,'string', phangle);
    psangle=getGlobalps;
    set(handles.ea3,'string', psangle);
    
    %rotation matrix guide
    set(handles.RM00, 'string', R(1,1));
    set(handles.RM01, 'string', R(1,2));
    set(handles.RM02, 'string', R(1,3));
    set(handles.RM10, 'string', R(2,1));
    set(handles.RM11, 'string', R(2,2));
    set(handles.RM12, 'string', R(2,3));
    set(handles.RM20, 'string', R(3,1));
    set(handles.RM21, 'string', R(3,2));
    set(handles.RM22, 'string', R(3,3));
    
    %euler angle and axis
    set(handles.EulerPrincipalAngle, 'string', pea);
    set(handles.EPAx1, 'string', axis(1));
    set(handles.EPAx2, 'string', axis(2));
    set(handles.EPAx3, 'string', axis(3));
    
    %rotation vector
    set(handles.rv1, 'string', rvect(1));
    set(handles.rv2, 'string', rvect(2));
    set(handles.rv3, 'string', rvect(3));
end


guidata(hObject,handles);
end

function [a] = GetMousePosition(x, y)

if x^2 + y^2 < 0.5
   a = [x; y; abs(sqrt(1-x^2-y^2))]; 
else
    z=1/(2*abs(sqrt(x^2+y*2)));
    modul=abs(sqrt(x^2+y^2+z^2));
   a = [x; y; z]/abs(modul);
end
end


function [q] = GetQuaternionFromVectors(vec1, vec2)

m = abs(sqrt(2 + 2*dot(vec1, vec2)));
vec3 = (1 / m) * cross(vec1, vec2);
q = [0.5 * m; vec3(1); vec3(2); vec3(3)];

end
function [quaternion]=quaternionproduct(q,p)

q0=q(1);
qv=q(2:4);
p0=p(1);
pv=p(2:4);

quaternion=zeros(4,1);
quaternion(1)= q0*p0-(qv'*pv);
quaternion(2:4)= q0*pv+p0*qv+cross(qv,pv);

end

function setGlobalm0(m0)
global x
x = m0;
end

function r = getGlobalm0
global x
r = x;
end

function setGlobalqk1(qk1)
global t
t = qk1;
end

function s = getGlobalqk1
global t
s = t;
end

function setGlobalqk(qk)
global z
z=qk;
end

function q=getGlobalqk
global z
q=z;
end

function setGlobalt(t)
global theta
theta=t;
end

function tangle=getGlobalt
global theta
tangle=theta;
end

function setGlobalph(ph)
global phi
phi=ph;
end

function phangle=getGlobalph
global phi
phangle=phi;
end

function setGlobalps(ps)
global psi
psi=ps;
end

function psangle=getGlobalps
global psi
psangle=psi;
end

function [MatrixR]=matrixfromquaternion(quaternion)

quaternion=[quaternion(1);quaternion(2);quaternion(3);quaternion(4)];
q0=quaternion(1);
qv=quaternion(2:4);
qx=[0 -qv(3) qv(2);qv(3) 0 -qv(1);-qv(2) qv(1) 0];
MatrixR=(q0^2-(qv'*qv))*eye(3)+(2*(qv*qv'))+(2*(q0*qx));

end
function [quatm]=quatfrommat(matrix)
q0=((1+matrix(1,1)+matrix(2,2)+matrix(3,3))^2)/4;
q1=((1+matrix(1,1)-matrix(2,2)-matrix(3,3))^2)/4;
q2=((1-matrix(1,1)+matrix(2,2)-matrix(3,3))^2)/4;
q3=((1-matrix(1,1)-matrix(2,2)+matrix(3,3))^2)/4;
quatm=[q0;q1;q2;q3];
end
function [theta,phi,psi]=rotM2eAngles(mrotated)

theta=-asind(mrotated(3,1));
ct=cosd(theta);
phi=asind(mrotated(2,1)/ct);
psi=asind(mrotated(3,2)/ct);

end

%from rotated matrix to euler angles
function [axis,pea]=rotMat2Eaa(mrotated)

mrotatedt=mrotated';
pea=(acosd((trace(mrotated)-1)/2));

rot=(mrotated-mrotatedt)/(2*sind(pea));

axis=zeros(3,1);

axis(1,1)=-rot(2,3);
axis(2,1)=rot(1,3);
axis(3,1)=-rot(2,1);

end

%from euler angles to rotated matrix
function [rmatrix]=eAngles2rotM(theta,phi,psi)


rmatrix=[cosd(theta)*cosd(phi) (cosd(phi)*sind(theta)*sind(psi))-cosd(psi)*sind(phi) cosd(phi)*cosd(psi)*sind(theta)+sind(phi)*sind(psi);
cosd(theta)*sind(phi) sind(phi)*sind(theta)*sind(phi)+cosd(psi)*cosd(phi) sind(phi)*sind(theta)*cosd(psi)-cosd(phi)*sind(psi);
-sind(theta) cosd(theta)*sind(psi) cosd(theta)*cosd(psi)];


end
% from angle and axis to matrix
function [m]=Eaa2rotMat(u,angle)

%angle=angle*pi/180;
u=[u(1);u(2);u(3)];
modul=(sqrt((u(1)^2)+(u(2)^2)+(u(3)^2)));
u=u/modul;
ux= [0 -u(3) u(2);u(3) 0 -u(1);-u(2) u(1) 0];
m = eye(3)+sind(angle)*ux+(1-cosd(angle))*ux^2;

end

function [rotvec]=rotationvectorfromepa(u,angle)
rotvec=angle*u;

end


function h = DrawCube(R)

M0 = [    -1  -1 1;   %Node 1
    -1   1 1;   %Node 2
    1   1 1;   %Node 3
    1  -1 1;   %Node 4
    -1  -1 -1;  %Node 5
    -1   1 -1;  %Node 6
    1   1 -1;  %Node 7
    1  -1 -1]; %Node 8

M = (R*M0')';


x = M(:,1);
y = M(:,2);
z = M(:,3);


con = [1 2 3 4;
    5 6 7 8;
    4 3 7 8;
    1 2 6 5;
    1 4 8 5;
    2 3 7 6]';

x = reshape(x(con(:)),[4,6]);
y = reshape(y(con(:)),[4,6]);
z = reshape(z(con(:)),[4,6]);

c = 1/255*[255 248 88;
    0 0 0;
    57 183 225;
    57 183 0;
    255 178 0;
    255 0 0];

h = fill3(x,y,z, 1:6);

for q = 1:length(c)
    h(q).FaceColor = c(q,:);
end
end

function h = RedrawCube(R,hin)

h = hin;
c = 1/255*[255 248 88;
    0 0 0;
    57 183 225;
    57 183 0;
    255 178 0;
    255 0 0];

M0 = [    -1  -1 1;   %Node 1
    -1   1 1;   %Node 2
    1   1 1;   %Node 3
    1  -1 1;   %Node 4
    -1  -1 -1;  %Node 5
    -1   1 -1;  %Node 6
    1   1 -1;  %Node 7
    1  -1 -1]; %Node 8

M = (R*M0')';


x = M(:,1);
y = M(:,2);
z = M(:,3);


con = [1 2 3 4;
    5 6 7 8;
    4 3 7 8;
    1 2 6 5;
    1 4 8 5;
    2 3 7 6]';

x = reshape(x(con(:)),[4,6]);
y = reshape(y(con(:)),[4,6]);
z = reshape(z(con(:)),[4,6]);

for q = 1:6
    h(q).Vertices = [x(:,q) y(:,q) z(:,q)];
    h(q).FaceColor = c(q,:);
end
end



function qk1_Callback(hObject, eventdata, handles)
% hObject    handle to qk1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of qk1 as text
%        str2double(get(hObject,'String')) returns contents of qk1 as a double
q=getGlobalqk;
end


% --- Executes during object creation, after setting all properties.
function qk1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to qk1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
end



function qk2_Callback(hObject, eventdata, handles)
% hObject    handle to qk2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of qk2 as text
%        str2double(get(hObject,'String')) returns contents of qk2 as a double
q=getGlobalqk;
end


% --- Executes during object creation, after setting all properties.
function qk2_CreateFcn(hObject, eventdata, handles)
% hObject    handle to qk2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
end



function qk3_Callback(hObject, eventdata, handles)
% hObject    handle to qk3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of qk3 as text
%        str2double(get(hObject,'String')) returns contents of qk3 as a double
q=getGlobalqk;
end

% --- Executes during object creation, after setting all properties.
function qk3_CreateFcn(hObject, eventdata, handles)
% hObject    handle to qk3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
end


function qk4_Callback(hObject, eventdata, handles)
% hObject    handle to qk4 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of qk4 as text
%        str2double(get(hObject,'String')) returns contents of qk4 as a double
q=getGlobalqk;
end

% --- Executes during object creation, after setting all properties.
function qk4_CreateFcn(hObject, eventdata, handles)
% hObject    handle to qk4 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
end


function ea1_Callback(hObject, eventdata, handles)
% hObject    handle to ea1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of ea1 as text
%        str2double(get(hObject,'String')) returns contents of ea1 as a double
tangle=getGlobalt;

end

% --- Executes during object creation, after setting all properties.
function ea1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to ea1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
end


function ea2_Callback(hObject, eventdata, handles)
% hObject    handle to ea2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of ea2 as text
%        str2double(get(hObject,'String')) returns contents of ea2 as a double
phangle=getGlobalph;

end

% --- Executes during object creation, after setting all properties.
function ea2_CreateFcn(hObject, eventdata, handles)
% hObject    handle to ea2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
end


function ea3_Callback(hObject, eventdata, handles)
% hObject    handle to ea3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of ea3 as text
%        str2double(get(hObject,'String')) returns contents of ea3 as a double
psangle=getGlobalps;
end

% --- Executes during object creation, after setting all properties.
function ea3_CreateFcn(hObject, eventdata, handles)
% hObject    handle to ea3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
end

% --- Executes on button press in EulerButton.
function EulerButton_Callback(hObject, eventdata, handles)
% hObject    handle to EulerButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

theta = str2double(get(handles.ea1, 'string'));
phi = str2double(get(handles.ea2, 'string'));
psi = str2double(get(handles.ea3, 'string'));
R = [1 0 0; 0 -1 0;0 0 -1];
R=eAngles2rotM(theta,phi,psi);

handles.Cube = RedrawCube(R,handles.Cube);
set(handles.RM00, 'string', R(1,1));
    set(handles.RM01, 'string', R(1,2));
    set(handles.RM02, 'string', R(1,3));
    set(handles.RM10, 'string', R(2,1));
    set(handles.RM11, 'string', R(2,2));
    set(handles.RM12, 'string', R(2,3));
    set(handles.RM20, 'string', R(3,1));
    set(handles.RM21, 'string', R(3,2));
    set(handles.RM22, 'string', R(3,3));
     %euler angle and axis
    [axis,pea]=rotMat2Eaa(R);
    set(handles.EulerPrincipalAngle, 'string', pea);
    set(handles.EPAx1, 'string', axis(1));
    set(handles.EPAx2, 'string', axis(2));
    set(handles.EPAx3, 'string', axis(3));
     if isnan(pea)
    pea=0;
    end
    if isnan(axis(1))
    axis(1)=0;
    end
    if isnan(axis(2))
    axis(2)=0;
    end
    if isnan(axis(3))
    axis(3)=0;
    end
    %rotation vector
    rotvec=rotationvectorfromepa(axis,pea);
    set(handles.rv1, 'string', rotvec(1));
    set(handles.rv2, 'string', rotvec(2));
    set(handles.rv3, 'string', rotvec(3));
    if isnan(rotvec(1))
    rotvec(1)=0;
    end
    if isnan(rotvec(2))
    rotvec(2)=0;
    end
    if isnan(rotvec(3))
    rotvec(3)=0;
    end
  %quaternion
    quat=quatfrommat(R);
    set(handles.qk1, 'string', quat(1));
    set(handles.qk2, 'string', quat(2));
    set(handles.qk3, 'string', quat(3));
    set(handles.qk4, 'string', quat(4));
     if isnan(quat(1))
    quat(1)=0;
    end
    if isnan(quat(2))
    quat(2)=0;
    end
    if isnan(quat(3))
    quat(3)=0;
    end
    if isnan(quat(4))
    quat(4)=0;
    end
end


function EulerPrincipalAngle_Callback(hObject, eventdata, handles)
% hObject    handle to EulerPrincipalAngle (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of EulerPrincipalAngle as text
%        str2double(get(hObject,'String')) returns contents of EulerPrincipalAngle as a double
end

% --- Executes during object creation, after setting all properties.
function EulerPrincipalAngle_CreateFcn(hObject, eventdata, handles)
% hObject    handle to EulerPrincipalAngle (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
end


function EPAx1_Callback(hObject, eventdata, handles)
% hObject    handle to EPAx1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of EPAx1 as text
%        str2double(get(hObject,'String')) returns contents of EPAx1 as a double
end

% --- Executes during object creation, after setting all properties.
function EPAx1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to EPAx1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
end


function EPAx2_Callback(hObject, eventdata, handles)
% hObject    handle to EPAx2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of EPAx2 as text
%        str2double(get(hObject,'String')) returns contents of EPAx2 as a double
end

% --- Executes during object creation, after setting all properties.
function EPAx2_CreateFcn(hObject, eventdata, handles)
% hObject    handle to EPAx2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
end


function EPAx3_Callback(hObject, eventdata, handles)
% hObject    handle to EPAx3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of EPAx3 as text
%        str2double(get(hObject,'String')) returns contents of EPAx3 as a double
end

% --- Executes during object creation, after setting all properties.
function EPAx3_CreateFcn(hObject, eventdata, handles)
% hObject    handle to EPAx3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
end

% --- Executes on button press in QuaternionButton.
function QuaternionButton_Callback(hObject, eventdata, handles)
% hObject    handle to QuaternionButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
q1 = str2double(get(handles.qk1, 'string'));
q2 = str2double(get(handles.qk2, 'string'));
q3 = str2double(get(handles.qk3, 'string'));
q4 = str2double(get(handles.qk4, 'string'));

quaternion = [q1;q2;q3;q4];

R = [1 0 0; 0 -1 0;0 0 -1];
R = quat2rotm(quaternion');

handles.Cube = RedrawCube(R,handles.Cube);
set(handles.RM00, 'string', R(1,1));
    set(handles.RM01, 'string', R(1,2));
    set(handles.RM02, 'string', R(1,3));
    set(handles.RM10, 'string', R(2,1));
    set(handles.RM11, 'string', R(2,2));
    set(handles.RM12, 'string', R(2,3));
    set(handles.RM20, 'string', R(3,1));
    set(handles.RM21, 'string', R(3,2));
    set(handles.RM22, 'string', R(3,3));
    %euler angles
    [theta,phi,psi]=rotM2eAngles(R);
    set(handles.ea1, 'string', theta);
    set(handles.ea2, 'string', phi);
    set(handles.ea3, 'string', psi);
    if isnan(theta)
    theta=0;
    end
    if isnan(phi)
    phi=0;
    end
    if isnan(phi)
    phi=0;
    end
    %euler angle and axis
    [axis,pea]=rotMat2Eaa(R);
    set(handles.EulerPrincipalAngle, 'string', pea);
    set(handles.EPAx1, 'string', axis(1));
    set(handles.EPAx2, 'string', axis(2));
    set(handles.EPAx3, 'string', axis(3));
    if isnan(pea)
    pea=0;
    end
    if isnan(axis(1))
    axis(1)=0;
    end
    if isnan(axis(2))
    axis(2)=0;
    end
    if isnan(axis(3))
    axis(3)=0;
    end
    %rotation vector
    rotvec=rotationvectorfromepa(axis,pea);
    set(handles.rv1, 'string', rotvec(1));
    set(handles.rv2, 'string', rotvec(2));
    set(handles.rv3, 'string', rotvec(3));
    if isnan(rotvec(1))
    rotvec(1)=0;
    end
    if isnan(rotvec(2))
    rotvec(2)=0;
    end
    if isnan(rotvec(3))
    rotvec(3)=0;
    end
end

% --- Executes on button press in RotationVectorButton.
function RotationVectorButton_Callback(hObject, eventdata, handles)
% hObject    handle to RotationVectorButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
x = str2double(get(handles.rv1, 'string'));
y = str2double(get(handles.rv2, 'string'));
z = str2double(get(handles.rv3, 'string'));
v=[x,y,z];

R = [1 0 0; 0 -1 0;0 0 -1];
angle=abs(sqrt(x^2+y^2+z^2));
R = Eaa2rotMat(v,angle);

handles.Cube = RedrawCube(R,handles.Cube);

set(handles.RM00, 'string', R(1,1));
    set(handles.RM01, 'string', R(1,2));
    set(handles.RM02, 'string', R(1,3));
    set(handles.RM10, 'string', R(2,1));
    set(handles.RM11, 'string', R(2,2));
    set(handles.RM12, 'string', R(2,3));
    set(handles.RM20, 'string', R(3,1));
    set(handles.RM21, 'string', R(3,2));
    set(handles.RM22, 'string', R(3,3));
    
    %quaternion
    quat=quatfrommat(R);
    set(handles.qk1, 'string', quat(1));
    set(handles.qk2, 'string', quat(2));
    set(handles.qk3, 'string', quat(3));
    set(handles.qk4, 'string', quat(4));
     if isnan(quat(1))
    quat(1)=0;
    end
    if isnan(quat(2))
    quat(2)=0;
    end
    if isnan(quat(3))
    quat(3)=0;
    end
    if isnan(quat(4))
    quat(4)=0;
    end
    %euler angles
    [theta,phi,psi]=rotM2eAngles(R);
    set(handles.ea1, 'string', theta);
    set(handles.ea2, 'string', phi);
    set(handles.ea3, 'string', psi);
      if isnan(theta)
    theta=0;
    end
    if isnan(phi)
    phi=0;
    end
    if isnan(psi)
    psi=0;
    end
    %euler principal angle and axis
    [axis,pea]=rotMat2Eaa(R);
    set(handles.EulerPrincipalAngle, 'string', pea);
    set(handles.EPAx1, 'string', axis(1));
    set(handles.EPAx2, 'string', axis(2));
    set(handles.EPAx3, 'string', axis(3));
    if isnan(pea)
    pea=0;
    end
    if isnan(axis(1))
    axis(1)=0;
    end
    if isnan(axis(2))
    axis(2)=0;
    end
    if isnan(axis(3))
    axis(3)=0;
    end
   
end

% --- Executes on button press in EPAbutton.
function EPAbutton_Callback(hObject, eventdata, handles)
% hObject    handle to EPAbutton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
angle=str2double(get(handles.EulerPrincipalAngle,'string'));

ax1=str2double(get(handles.EPAx1,'string'));
ax2=str2double(get(handles.EPAx2,'string'));
ax3=str2double(get(handles.EPAx3,'string'));

u=[ax1,ax2,ax3];

R = [1 0 0; 0 -1 0;0 0 -1];
R=Eaa2rotMat(u,angle);
handles.Cube = RedrawCube(R,handles.Cube);

set(handles.RM00, 'string', R(1,1));
    set(handles.RM01, 'string', R(1,2));
    set(handles.RM02, 'string', R(1,3));
    set(handles.RM10, 'string', R(2,1));
    set(handles.RM11, 'string', R(2,2));
    set(handles.RM12, 'string', R(2,3));
    set(handles.RM20, 'string', R(3,1));
    set(handles.RM21, 'string', R(3,2));
    set(handles.RM22, 'string', R(3,3));
    %quaternion
    quat=quatfrommat(R);
    set(handles.qk1, 'string', quat(1));
    set(handles.qk2, 'string', quat(2));
    set(handles.qk3, 'string', quat(3));
    set(handles.qk4, 'string', quat(4));
    if isnan(quat(1))
    quat(1)=0;
    end
    if isnan(quat(2))
    quat(2)=0;
    end
    if isnan(quat(3))
    quat(3)=0;
    end
    if isnan(quat(4))
    quat(4)=0;
    end
    %euler angles
    [theta,phi,psi]=rotM2eAngles(R);
    set(handles.ea1, 'string', theta);
    set(handles.ea2, 'string', phi);
    set(handles.ea3, 'string', psi);
     if isnan(theta)
    theta=0;
    end
    if isnan(phi)
    phi=0;
    end
    if isnan(psi)
    psi=0;
    end
     %rotation vector
    rotvec=rotationvectorfromepa(u,angle);
    set(handles.rv1, 'string', rotvec(1));
    set(handles.rv2, 'string', rotvec(2));
    set(handles.rv3, 'string', rotvec(3));
      if isnan(rotvec(1))
    rotvec(1)=0;
    end
    if isnan(rotvec(2))
    rotvec(2)=0;
    end
    if isnan(rotvec(3))
    rotvec(3)=0;
    end
end


function rv3_Callback(hObject, eventdata, handles)
% hObject    handle to rv3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of rv3 as text
%        str2double(get(hObject,'String')) returns contents of rv3 as a double
end

% --- Executes during object creation, after setting all properties.
function rv3_CreateFcn(hObject, eventdata, handles)
% hObject    handle to rv3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
end


function rv2_Callback(hObject, eventdata, handles)
% hObject    handle to rv2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of rv2 as text
%        str2double(get(hObject,'String')) returns contents of rv2 as a double
end

% --- Executes during object creation, after setting all properties.
function rv2_CreateFcn(hObject, eventdata, handles)
% hObject    handle to rv2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
end


function rv1_Callback(hObject, eventdata, handles)
% hObject    handle to rv1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of rv1 as text
%        str2double(get(hObject,'String')) returns contents of rv1 as a double
end

% --- Executes during object creation, after setting all properties.
function rv1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to rv1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
end


% --- Executes on button press in Reset.
function Reset_Callback(hObject, eventdata, handles)
% hObject    handle to Reset (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

R = [1 0 0; 0 -1 0;0 0 1];
handles.Cube = RedrawCube(R,handles.Cube);
set(handles.RM00, 'string', 0);
set(handles.RM01, 'string', 0);
set(handles.RM02, 'string', 0);
set(handles.RM10, 'string', 0);
set(handles.RM11, 'string', 0);
set(handles.RM12, 'string', 0);
set(handles.RM20, 'string', 0);
set(handles.RM21, 'string', 0);
set(handles.RM22, 'string', 0);
%quaternion
    set(handles.qk1, 'string', 0);
    set(handles.qk2, 'string', 0);
    set(handles.qk3, 'string', 0);
    set(handles.qk4, 'string', 0);
    %euler angles
    set(handles.ea1, 'string', 0);
    set(handles.ea2, 'string', 0);
    set(handles.ea3, 'string', 0);
     %rotation vector
    set(handles.rv1, 'string', 0);
    set(handles.rv2, 'string', 0);
    set(handles.rv3, 'string', 0);
      %euler principal angle and axis

    set(handles.EulerPrincipalAngle, 'string',0);
    set(handles.EPAx1, 'string', 0);
    set(handles.EPAx2, 'string', 0);
    set(handles.EPAx3, 'string', 0);
end
