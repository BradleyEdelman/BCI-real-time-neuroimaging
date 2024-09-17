function varargout = bci_ESI_Continuous(varargin)
% BCI_ESI_CONTINUOUS MATLAB code for bci_ESI_Continuous.fig
%      BCI_ESI_CONTINUOUS, by itself, creates a new BCI_ESI_CONTINUOUS or raises the existing
%      singleton*.
%
%      H = BCI_ESI_CONTINUOUS returns the handle to a new BCI_ESI_CONTINUOUS or the handle to
%      the existing singleton*.
%
%      BCI_ESI_CONTINUOUS('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in BCI_ESI_CONTINUOUS.M with the given input arguments.
%
%      BCI_ESI_CONTINUOUS('Property','value',...) creates a new BCI_ESI_CONTINUOUS or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before bci_ESI_Continuous_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to bci_ESI_Continuous_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help bci_ESI_Continuous

% Last Modified by GUIDE v2.5 18-Oct-2016 10:20:09

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @bci_ESI_Continuous_OpeningFcn, ...
                   'gui_OutputFcn',  @bci_ESI_Continuous_OutputFcn, ...
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


% --- Executes just before bci_ESI_Continuous is made visible.
function bci_ESI_Continuous_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to bci_ESI_Continuous (see VARARGIN)

% Choose default command line output for bci_ESI_Continuous
handles.output = hObject;
% setesi(hObject,'Units','pixels','Position',[50 50 1000 2250]) 

% UIWAIT makes bci_ESI_Continuous wait for user response (see UIRESUME)
% uiwait(handles.bci_ESI_Continuous);
[hObject,handles]=bci_fESI_Reset(hObject,handles,'System',[]);

% ESTABLISH CUSTOM DEFAULT HANDLES
[hObject,handles]=bci_fESI_DefaultHandles(hObject,handles,[]);

% AUTOMATICALLY SET DATE
format shortg
c=clock;
set(handles.year,'backgroundcolor','green','string',num2str(c(1)));
if size(num2str(c(2)),2)<2
    m=strcat('0',num2str(c(2)));
else
    m=num2str(c(2));
end
set(handles.month,'backgroundcolor','green','string',m);
if size(num2str(c(3)),2)<2
    d=strcat('0',num2str(c(3)));
else
    d=num2str(c(3));
end
set(handles.day,'backgroundcolor','green','string',d);

% AUTOMATICALLY SET SAVEPATH
[filepath,filename,fileext]=fileparts(which('bci_ESI_Continuous.m'));
savepath=strcat(filepath,'\Data');
if ~exist(savepath,'dir')
    mkdir(savepath)
end
set(handles.savepath,'backgroundcolor','green','string',savepath)

handles.SYSTEM.rootdir=filepath;


guidata(hObject,handles)


% --- Outputs from this function are returned to the command line.
function varargout = bci_ESI_Continuous_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;

% --- Executes during object creation, after setting all properties.
function test_CreateFcn(hObject, eventdata, handles)
% hObject    handle to bci_ESI_Continuous (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% --- Executes during object creation, after setting all properties.
function uipanel4_CreateFcn(hObject, eventdata, handles)
% hObject    handle to uipanel4 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called  
    
% --- Executes during object creation, after setting all properties.
function uipanel11_CreateFcn(hObject, eventdata, handles)
% hObject    handle to uipanel11 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
% --- Executes during object creation, after setting all properties.

% --- Executes during object creation, after setting all properties.
function uipanel6_CreateFcn(hObject, eventdata, handles)
% hObject    handle to uipanel6 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

function uipanel3_CreateFcn(hObject, eventdata, handles)
% hObject    handle to uipanel3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% --- Executes during object creation, after setting all properties.
function uipanel5_CreateFcn(hObject, eventdata, handles)
% hObject    handle to uipanel5 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% --- Executes during object creation, after setting all properties.
function uipanel8_CreateFcn(hObject, eventdata, handles)
% hObject    handle to uipanel8 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% --- Executes during object creation, after setting all properties.
function uipanel9_CreateFcn(hObject, eventdata, handles)
% hObject    handle to uipanel9 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

function Axis1Label_Callback(hObject, eventdata, handles)
% hObject    handle to Axis1Label (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'string') returns contents of Axis1Label as text
%        str2double(get(hObject,'string')) returns contents of Axis1Label as a double

% --- Executes during object creation, after setting all properties.
function Axis1Label_CreateFcn(hObject, eventdata, handles)
% hObject    handle to Axis1Label (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'backgroundcolor'), get(0,'defaultUicontrolbackgroundcolor'))
    set(hObject,'backgroundcolor','white');
end


function Axis2Label_Callback(hObject, eventdata, handles)
% hObject    handle to Axis2Label (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'string') returns contents of Axis2Label as text
%        str2double(get(hObject,'string')) returns contents of Axis2Label as a double

% --- Executes during object creation, after setting all properties.
function Axis2Label_CreateFcn(hObject, eventdata, handles)
% hObject    handle to Axis2Label (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'backgroundcolor'), get(0,'defaultUicontrolbackgroundcolor'))
    set(hObject,'backgroundcolor','white');
end


function Axis3Label_Callback(hObject, eventdata, handles)
% hObject    handle to Axis3Label (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'string') returns contents of Axis3Label as text
%        str2double(get(hObject,'string')) returns contents of Axis3Label as a double

% --- Executes during object creation, after setting all properties.
function Axis3Label_CreateFcn(hObject, eventdata, handles)
% hObject    handle to Axis3Label (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'backgroundcolor'), get(0,'defaultUicontrolbackgroundcolor'))
    set(hObject,'backgroundcolor','white');
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                           SUBJECT INFORMATION                           %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% --- Executes on button press in LoadESI.
function LoadESI_Callback(hObject, eventdata, handles)
% hObject    handle to LoadESI (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
[hObject,handles]=bci_fESI_Reset(hObject,handles,'ESI',[]);
[hObject,handles]=bci_fESI_Load(hObject,handles,'ESI');
guidata(hObject,handles)

function initials_Callback(hObject, eventdata, handles)
% hObject    handle to initials (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'string') returns contents of initials as text
%        str2double(get(hObject,'string')) returns contents of initials as a double
[hObject,handles]=bci_fESI_Reset(hObject,handles,'System',[]);
[hObject,handles]=bci_fESI_Initials(hObject,handles);
guidata(hObject,handles)

% --- Executes during object creation, after setting all properties.
function initials_CreateFcn(hObject, eventdata, handles)
% hObject    handle to initials (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'backgroundcolor'), get(0,'defaultUicontrolbackgroundcolor'))
    set(hObject,'backgroundcolor','white');
end


function session_Callback(hObject, eventdata, handles)
% hObject    handle to session (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'string') returns contents of session as text
%        str2double(get(hObject,'string')) returns contents of session as a double
% [hObject,handles]=bci_fESI_Session(hObject,handles)
[hObject,handles]=bci_fESI_Reset(hObject,handles,'System',[]);
cfg=struct('varname','SESSION','defaultnum','','lowbound',1);
[hObject,handles]=bci_fESI_EnterNum(hObject,handles,cfg);
guidata(hObject,handles)

% --- Executes during object creation, after setting all properties.
function session_CreateFcn(hObject, eventdata, handles)
% hObject    handle to session (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'backgroundcolor'), get(0,'defaultUicontrolbackgroundcolor'))
    set(hObject,'backgroundcolor','white');
end


function run_Callback(hObject, eventdata, handles)
% hObject    handle to run (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'string') returns contents of run as text
%        str2double(get(hObject,'string')) returns contents of run as a double
[hObject,handles]=bci_fESI_Reset(hObject,handles,'System',[]);
cfg=struct('varname','RUN','defaultnum','','lowbound',1);
[hObject,handles]=bci_fESI_EnterNum(hObject,handles,cfg);
guidata(hObject,handles)

% --- Executes during object creation, after setting all properties.
function run_CreateFcn(hObject, eventdata, handles)
% hObject    handle to run (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'backgroundcolor'), get(0,'defaultUicontrolbackgroundcolor'))
    set(hObject,'backgroundcolor','white')
end


function year_Callback(hObject, eventdata, handles)
% hObject    handle to year (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'string') returns contents of year as text
%        str2double(get(hObject,'string')) returns contents of year as a double
[hObject,handles]=bci_fESI_Reset(hObject,handles,'System',[]);
cfg=struct('varname','YEAR','defaultnum','','lowbound',1,'length',4);
[hObject,handles]=bci_fESI_EnterNum(hObject,handles,cfg);
guidata(hObject,handles)

% --- Executes during object creation, after setting all properties.
function year_CreateFcn(hObject, eventdata, handles)
% hObject    handle to year (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'backgroundcolor'), get(0,'defaultUicontrolbackgroundcolor'))
    set(hObject,'backgroundcolor','white')
end


function month_Callback(hObject, eventdata, handles)
% hObject    handle to month (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'string') returns contents of month as text
%        str2double(get(hObject,'string')) returns contents of month as a double
[hObject,handles]=bci_fESI_Reset(hObject,handles,'System',[]);
cfg=struct('varname','MONTH','defaultnum','','lowbound',1);
[hObject,handles]=bci_fESI_EnterNum(hObject,handles,cfg);
guidata(hObject,handles)

% --- Executes during object creation, after setting all properties.
function month_CreateFcn(hObject, eventdata, handles)
% hObject    handle to month (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'backgroundcolor'), get(0,'defaultUicontrolbackgroundcolor'))
    set(hObject,'backgroundcolor','white');
end


function day_Callback(hObject, eventdata, handles)
% hObject    handle to day (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'string') returns contents of day as text
%        str2double(get(hObject,'string')) returns contents of day as a double
[hObject,handles]=bci_fESI_Reset(hObject,handles,'System',[]);
cfg=struct('varname','DAY','defaultnum','','lowbound',1);
[hObject,handles]=bci_fESI_EnterNum(hObject,handles,cfg);
guidata(hObject,handles)

% --- Executes during object creation, after setting all properties.
function day_CreateFcn(hObject, eventdata, handles)
% hObject    handle to day (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'backgroundcolor'), get(0,'defaultUicontrolbackgroundcolor'))
    set(hObject,'backgroundcolor','white')
end


% --- Executes on button press in savepath.
function savepath_Callback(hObject, eventdata, handles)
% hObject    handle to savepath (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
[hObject,handles]=bci_fESI_Reset(hObject,handles,'System',[]);
OldSavePath=get(hObject,'string');
rootdir=handles.SYSTEM.rootdir;
NewSavePath=uigetdir(rootdir);
if isequal(NewSavePath,0) && isequal(OldSavePath,0)
    set(hObject,'backgroundcolor','red','string','')
elseif isequal(NewSavePath,0) && ~isequal(OldSavePath,0)
    set(hObject,'backgroundcolor','white','string',OldSavePath)
else
    set(hObject,'backgroundcolor','white','string',NewSavePath)
end
guidata(hObject,handles)


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                           SYSTEM PARAMETERS                             %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% --- Executes on selection change in tasktype.
function tasktype_Callback(hObject, eventdata, handles)
% hObject    handle to tasktype (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'string')) returns tasktype contents as cell array
%        contents{get(hObject,'value')} returns selected item from tasktype
[hObject,handles]=bci_fESI_Reset(hObject,handles,'BCI',[]);


% --- Executes during object creation, after setting all properties.
function tasktype_CreateFcn(hObject, eventdata, handles)
% hObject    handle to tasktype (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'backgroundcolor'), get(0,'defaultUicontrolbackgroundcolor'))
    set(hObject,'backgroundcolor','white');
end


% --- Executes on selection change in domain.
function domain_Callback(hObject, eventdata, handles)
% hObject    handle to domain (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'string')) returns domain contents as cell array
%        contents{get(hObject,'value')} returns selected item from domain
[hObject,handles]=bci_fESI_Reset(hObject,handles,'BCI',[]);
[hObject,handles]=bci_fESI_SelectDomain(hObject,handles);
guidata(hObject,handles);

% --- Executes during object creation, after setting all properties.
function domain_CreateFcn(hObject, eventdata, handles)
% hObject    handle to domain (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'backgroundcolor'), get(0,'defaultUicontrolbackgroundcolor'))
    set(hObject,'backgroundcolor','white');
end


% --- Executes on selection change in eegsystem.
function eegsystem_Callback(hObject, eventdata, handles)
% hObject    handle to eegsystem (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'string')) returns eegsystem contents as cell array
%        contents{get(hObject,'value')} returns selected item from eegsystem
[hObject,handles]=bci_fESI_Reset(hObject,handles,'System',[]);
[hObject,handles]=bci_fESI_SelectEEGsystem(hObject,handles);
guidata(hObject,handles)

% --- Executes during object creation, after setting all properties.
function eegsystem_CreateFcn(hObject, eventdata, handles)
% hObject    handle to eegsystem (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'backgroundcolor'), get(0,'defaultUicontrolbackgroundcolor'))
    set(hObject,'backgroundcolor','white');
end


function fs_Callback(hObject, eventdata, handles)
% hObject    handle to fs (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'string') returns contents of fs as text
%        str2double(get(hObject,'string')) returns contents of fs as a double

% --- Executes during object creation, after setting all properties.
function fs_CreateFcn(hObject, eventdata, handles)
% hObject    handle to fs (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'backgroundcolor'), get(0,'defaultUicontrolbackgroundcolor'))
    set(hObject,'backgroundcolor','white')
end

% --- Executes on button press in selectsensors.
function selectsensors_Callback(hObject, eventdata, handles)
% hObject    handle to selectsensors (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
[hObject,handles]=bci_fESI_Reset(hObject,handles,'System',[]);
[hObject,handles]=bci_fESI_SelectSensors(hObject,handles);
guidata(hObject,handles)


% --- Executes on selection change in psd.
function psd_Callback(hObject, eventdata, handles)
% hObject    handle to psd (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'string')) returns psd contents as cell array
%        contents{get(hObject,'value')} returns selected item from psd
[hObject,handles]=bci_fESI_Reset(hObject,handles,'System',[]);
psd=get(hObject,'value');
if isequal(psd,1)
    set(hObject,'backgroundcolor','red')
elseif ismember(psd,2:4)
    set(hObject,'backgroundcolor','white')
end
guidata(hObject,handles)

% --- Executes during object creation, after setting all properties.
function psd_CreateFcn(hObject, eventdata, handles)
% hObject    handle to psd (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'backgroundcolor'), get(0,'defaultUicontrolbackgroundcolor'))
    set(hObject,'backgroundcolor','white')
end


function dsfactor_Callback(hObject, eventdata, handles)
% hObject    handle to dsfactor (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'string') returns contents of dsfactor as text
%        str2double(get(hObject,'string')) returns contents of dsfactor as a double
[hObject,handles]=bci_fESI_Reset(hObject,handles,'System',[]);
cfg=struct('varname','DOWN_SAMPLE_FACTOR','defaultnum','1','lowbound',...
    1,'highbound',8,'length',1);
[hObject,handles]=bci_fESI_EnterNum(hObject,handles,cfg);
guidata(hObject,handles)

% --- Executes during object creation, after setting all properties.
function dsfactor_CreateFcn(hObject, eventdata, handles)
% hObject    handle to dsfactor (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'backgroundcolor'), get(0,'defaultUicontrolbackgroundcolor'))
    set(hObject,'backgroundcolor','white');
end


function lowcutoff_Callback(hObject, eventdata, handles)
% hObject    handle to lowcutoff (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'string') returns contents of lowcutoff as text
%        str2double(get(hObject,'string')) returns contents of lowcutoff as a double
[hObject,handles]=bci_fESI_Reset(hObject,handles,'System',[]);
if ~isempty(get(handles.fs,'string'))
    cfg=struct('varname','LOW_CUTOFF','defaultnum','Low','lowbound',2,'length',3);
    if ~isnan(str2double(get(handles.highcutoff,'string')))
        cfg.highbound=str2double(get(handles.highcutoff,'string'))-2;
    else
        cfg.highbound=round(str2double(get(handles.fs,'string'))/2)-1;
    end
    [hObject,handles]=bci_fESI_EnterNum(hObject,handles,cfg);
else
    set(hObject,'string','')
    set(hObject,'backgroundcolor','white');
end
guidata(hObject,handles);

% --- Executes during object creation, after setting all properties.
function lowcutoff_CreateFcn(hObject, eventdata, handles)
% hObject    handle to lowcutoff (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'backgroundcolor'), get(0,'defaultUicontrolbackgroundcolor'))
    set(hObject,'backgroundcolor','white')
end


function highcutoff_Callback(hObject, eventdata, handles)
% hObject    handle to highcutoff (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'string') returns contents of highcutoff as text
%        str2double(get(hObject,'string')) returns contents of highcutoff as a double
[hObject,handles]=bci_fESI_Reset(hObject,handles,'System',[]);
if ~isempty(get(handles.fs,'string'))
    cfg=struct('varname','HIGH_CUTOFF','defaultnum','High','length',3);
    cfg.highbound=round(str2double(get(handles.fs,'string'))/2)-1;
    if ~isnan(str2double(get(handles.lowcutoff,'string')))
        cfg.lowbound=str2double(get(handles.lowcutoff,'string'))+2;
    else
        cfg.lowbound=2;
    end
    [hObject,handles]=bci_fESI_EnterNum(hObject,handles,cfg);
else
    set(hObject,'backgroundcolor','white','string','')
end
guidata(hObject,handles)


% --- Executes during object creation, after setting all properties.
function highcutoff_CreateFcn(hObject, eventdata, handles)
% hObject    handle to highcutoff (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'backgroundcolor'), get(0,'defaultUicontrolbackgroundcolor'))
    set(hObject,'backgroundcolor','white')
end


% --- Executes on button press in SetSystem.
function SetSystem_Callback(hObject, eventdata, handles)
% hObject    handle to SetSystem (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
[hObject,handles]=bci_fESI_Reset(hObject,handles,'ESI',[]);
[hObject,handles]=bci_fESI_GetInfo(hObject,handles,'SYSTEM');
guidata(hObject,handles)


% --- Executes on button press in LoadSystem.
function LoadSystem_Callback(hObject, eventdata, handles)
% hObject    handle to LoadSystem (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
[hObject,handles]=bci_fESI_Reset(hObject,handles,'System',[]);
[hObject,handles]=bci_fESI_Load(hObject,handles,'SYSTEM');
guidata(hObject,handles)


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                        SOURCE IMAGING PARAMETERS                        %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% --- Executes on button press in DefaultAnatomy.
function DefaultAnatomy_Callback(hObject, eventdata, handles)
% hObject    handle to DefaultAnatomy (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'value') returns toggle state of DefaultAnatomy
domain=get(handles.domain,'value');
if isequal(domain,3)
    [hObject,handles]=bci_fESI_Reset(hObject,handles,'ESI',[]);
end
[hObject,handles]=bci_fESI_DefaultAnatomy(hObject,handles);
guidata(hObject,handles);

% --- Executes on button press in cortexfile.
function cortexfile_Callback(hObject, eventdata, handles)
% hObject    handle to cortexfile (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
domain=get(handles.domain,'value');
if isequal(domain,3)
    [hObject,handles]=bci_fESI_Reset(hObject,handles,'ESI',[]);
end
value=get(hObject,'string');
set(hObject,'backgroundcolor','white')
rootdir=handles.SYSTEM.rootdir;
subj=get(handles.initials,'string');
[filename,pathname]=uigetfile(strcat(rootdir,'\BCI_ready_files\',...
    subj,'\*.mat*'));
if isequal(filename,0) || isequal(pathname,0)
    cortex=value;
    if isequal(domain,3)
        set(handles.cortexfile,'backgroundcolor','red');
    end
else
    cortex=strcat(pathname,filename);
    handles.default.cortexfile=cortex;
end
set(hObject,'string',cortex);
guidata(hObject,handles)

% --- Executes on button press in cortexlrfile.
function cortexlrfile_Callback(hObject, eventdata, handles)
% hObject    handle to cortexlrfile (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
set(hObject,'backgroundcolor','white')
value=get(hObject,'string');
domain=get(handles.domain,'value');
lrvizsource=get(handles.lrvizsource,'value');
rootdir=handles.SYSTEM.rootdir;
subj=get(handles.initials,'string');
[filename,pathname]=uigetfile(strcat(rootdir,'\BCI_ready_files\',...
    subj,'\*.mat*'));
if isequal(filename,0) || isequal(pathname,0)
    cortexlr=value;
    if isequal(domain,3) && isequal(lrvizsource,1)
        set(handles.cortexlrfile,'backgroundcolor','red');
    end
else
    cortexlr=strcat(pathname,filename);
    handles.default.cortexlrfile=cortexlr;
end
set(hObject,'string',cortexlr);
guidata(hObject,handles)


% --- Executes on button press in headmodelfile.
function headmodelfile_Callback(hObject, eventdata, handles)
% hObject    handle to headmodelfile (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
domain=get(handles.domain,'value');
if isequal(domain,3)
    [hObject,handles]=bci_fESI_Reset(hObject,handles,'ESI',[]);
end
value=get(hObject,'string');
set(hObject,'backgroundcolor','white')
subj=get(handles.initials,'string');
[filename,pathname]=uigetfile(strcat('D:\Brad\bci_fESI\brainstorm_db\bci_Continuous\data\',...
    subj,'\*.mat*'));
if isequal(filename,0) || isequal(pathname,0)
    headmodel=value;
    if isequal(domain,3)
        set(handles.headmodelfile,'backgroundcolor','red');
    end
else
    headmodel=strcat(pathname,filename);
    handles.default.headmodelfile=headmodel;
end
set(hObject,'string',headmodel);
guidata(hObject,handles)


% --- Executes on button press in fmrifile.
function fmrifile_Callback(hObject, eventdata, handles)
% hObject    handle to fmrifile (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
domain=get(handles.domain,'value');
if isequal(domain,3)
    [hObject,handles]=bci_fESI_Reset(hObject,handles,'ESI',[]);
end

set(hObject,'backgroundcolor','white')
rootdir=handles.SYSTEM.rootdir;
subj=get(handles.initials,'string');
[filename,pathname]=uigetfile(strcat(rootdir,'\BCI_ready_files\',...
    subj,'\*.gii*'));
if isequal(filename,0) || isequal(pathname,0)
    fmri='';
    if isequal(domain,3)
        set(handles.fmrifile,'backgroundcolor',[1 .7 0]);
    end
else
    fmri=strcat(pathname,filename);
    handles.default.fmrifile=fmri;
end
set(hObject,'string',fmri)
guidata(hObject,handles)


function fMRIWeightDisplay_Callback(hObject, eventdata, handles)
% hObject    handle to fMRIWeightDisplay (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'string') returns contents of fMRIWeightDisplay as text
%        str2double(get(hObject,'string')) returns contents of fMRIWeightDisplay as a double
% If slide bar adjusted, setesi new value in text window...if bci_ESI_Continuous window
% adjusted, adjust slide bar
value=get(handles.fmriweight,'value');
set(hObject,'string',num2str(value));
guidata(hObject,handles)

% --- Executes during object creation, after setting all properties.
function fMRIWeightDisplay_CreateFcn(hObject, eventdata, handles)
% hObject    handle to fMRIWeightDisplay (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'backgroundcolor'), get(0,'defaultUicontrolbackgroundcolor'))
    set(hObject,'backgroundcolor','white');
end


% --- Executes on slider movement.
function fmriweight_Callback(hObject, eventdata, handles)
% hObject    handle to fmriweight (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider
domain=get(handles.domain,'value');
if isequal(domain,3)
    [hObject,handles]=bci_fESI_Reset(hObject,handles,'ESI',[]);
end
value=get(hObject,'value');
% Make sure sider can only be integers betwen 0 and 99
value=round(value);
if isequal(value,100)
    value=99;
end
set(hObject,'value',value);
set(handles.fMRIWeightDisplay,'string',value);
guidata(hObject,handles);

% --- Executes during object creation, after setting all properties.
function fmriweight_CreateFcn(hObject, eventdata, handles)
% hObject    handle to fmriweight (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'backgroundcolor'), get(0,'defaultUicontrolbackgroundcolor'))
    set(hObject,'backgroundcolor',[.9 .9 .9]);
end


function brainregionfile_Callback(hObject, eventdata, handles)
% hObject    handle to brainregionfile (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'string') returns contents of brainregionfile as text
%        str2double(get(hObject,'string')) returns contents of brainregionfile as a double
domain=get(handles.domain,'value');
if isequal(domain,3)
    [hObject,handles]=bci_fESI_Reset(hObject,handles,'ESI',[]);
end
brainregionfile=get(hObject,'string');
set(hObject,'backgroundcolor','white')
rootdir=handles.SYSTEM.rootdir;
subj=get(handles.initials,'string');
[filename,pathname]=uigetfile(strcat(rootdir,'\BCI_ready_files\',...
    subj,'\*.mat*'));
if isequal(filename,0) || isequal(pathname,0)
    if isequal(domain,3)
        set(handles.brainregionfile,'backgroundcolor','red');
    end
else
    brainregionfile=strcat(pathname,filename);
    handles.default.brainregionfile=brainregionfile;
end
set(hObject,'string',brainregionfile);
guidata(hObject,handles)


% --- Executes on button press in selectbrainregions.
function selectbrainregions_Callback(hObject, eventdata, handles)
% hObject    handle to selectbrainregions (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
[hObject,handles]=bci_fESI_Reset(hObject,handles,'ESI',[]);
[hObject,handles]=bci_fESI_SelectBrainRegions(hObject,handles);
guidata(hObject,handles)


% --- Executes on selection change in parcellation.
function parcellation_Callback(hObject, eventdata, handles)
% hObject    handle to parcellation (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'string')) returns parcellation contents as cell array
%        contents{get(hObject,'value')} returns selected item from parcellation
[hObject,handles]=bci_fESI_Reset(hObject,handles,'ESI',[]);
guidata(hObject,handles)

% --- Executes during object creation, after setting all properties.
function parcellation_CreateFcn(hObject, eventdata, handles)
% hObject    handle to parcellation (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'backgroundcolor'), get(0,'defaultUicontrolbackgroundcolor'))
    set(hObject,'backgroundcolor','white')
end


% --- Executes on selection change in esifiles.
function esifiles_Callback(hObject, eventdata, handles)
% hObject    handle to esifiles (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'string')) returns esifiles contents as cell array
%        contents{get(hObject,'value')} returns selected item from esifiles
guidata(hObject,handles)

% --- Executes during object creation, after setting all properties.
function esifiles_CreateFcn(hObject, eventdata, handles)
% hObject    handle to esifiles (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: listbox controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'backgroundcolor'), get(0,'defaultUicontrolbackgroundcolor'))
    set(hObject,'backgroundcolor','white')
end


% --- Executes on button press in AddESI.
function AddESI_Callback(hObject, eventdata, handles)
% hObject    handle to AddESI (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
[hObject,handles]=bci_fESI_Reset(hObject,handles,'ESI',[]);
[hObject,handles]=bci_fESI_DataList(hObject,handles,'Add','esifiles',[]);
guidata(hObject,handles)

% --- Executes on button press in RemoveESI.
function RemoveESI_Callback(hObject, eventdata, handles)
% hObject    handle to RemoveESI (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
[hObject,handles]=bci_fESI_Reset(hObject,handles,'ESI',[]);
[hObject,handles]=bci_fESI_DataList(hObject,handles,'Remove','esifiles',[]);
guidata(hObject,handles)


% --- Executes on button press in ClearESI.
function ClearESI_Callback(hObject, eventdata, handles)
% hObject    handle to ClearESI (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
[hObject,handles]=bci_fESI_Reset(hObject,handles,'ESI',[]);
[hObject,handles]=bci_fESI_DataList(hObject,handles,'Clear','esifiles',[]);
guidata(hObject,handles)


% --- Executes on button press in CopyESI.
function CopyESI_Callback(hObject, eventdata, handles)
% hObject    handle to CopyESI (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
[hObject,handles]=bci_fESI_Reset(hObject,handles,'ESI',[]);
[hObject,handles]=bci_fESI_DataList(hObject,handles,'Copy','esifiles','trainfiles');
guidata(hObject,handles)


% --- Executes on selection change in noise.
function noise_Callback(hObject, eventdata, handles)
% hObject    handle to noise (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'string')) returns noise contents as cell array
%        contents{get(hObject,'value')} returns selected item from noise
[hObject,handles]=bci_fESI_Reset(hObject,handles,'ESI',[]);
[hObject,handles]=bci_fESI_Noise(hObject,handles);
guidata(hObject,handles)

% --- Executes during object creation, after setting all properties.
function noise_CreateFcn(hObject, eventdata, handles)
% hObject    handle to noise (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'backgroundcolor'), get(0,'defaultUicontrolbackgroundcolor'))
    set(hObject,'backgroundcolor','white')
end


% --- Executes on button press in noisefile.
function noisefile_Callback(hObject, eventdata, handles)
% hObject    handle to noisefile (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% domain=get(handles.domain,'value');
% if isequal(domain,3)
%     [hObject,handles]=bci_fESI_Reset(hObject,handles,'ESI',[]);
% end
% value=get(hObject,'string');
% noise=get(handles.noise,'value');
% set(hObject,'backgroundcolor','white')
% Subj=get(handles.initials,'string');
% [filename,pathname]=uigetfile(strcat('D:\Brad\bci_fESI\brainstorm_db\bci_fESI\data\',...
%     Subj,'\*.mat*'));
% if isequal(filename,0) || isequal(pathname,0)
%     noisefile=value;
%     if ismember(domain,[3,4]) && ismember(noise,[3,4])
%         set(handles.noisefile,'backgroundcolor',[1 .7 0]);
%     end
% else
%     noisefile=strcat(pathname,filename);
% end
% set(hObject,'string',noisefile);


[hObject,handles]=bci_fESI_RunNoise(hObject,handles);

guidata(hObject,handles)

% --- Executes on button press in vizsource.
function vizsource_Callback(hObject, eventdata, handles)
% hObject    handle to vizsource (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of vizsource
domain=get(handles.domain,'value');
switch domain
    case {1,2} % None/Sensor
        set(hObject,'value',0);
    case {3,4} % ESI/fESI
        value=get(hObject,'value');
        if isequal(value,0)
            set(handles.lrvizsource,'value',0);
            set(handles.cortexlrfile,'backgroundcolor','white')
        end
end
guidata(hObject,handles)


% --- Executes on button press in lrvizsource.
function lrvizsource_Callback(hObject, eventdata, handles)
% hObject    handle to lrvizsource (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'value') returns toggle state of lrvizsource
domain=get(handles.domain,'value');
if isequal(domain,3)
    [hObject,handles]=bci_fESI_Reset(hObject,handles,'ESI',[]);
    vizsource=get(handles.vizsource,'value');
    if isequal(vizsource,0)
        set(hObject,'value',0);
    end
end

lrvizsource=get(hObject,'value');
cortexlr=get(handles.cortexlrfile,'string');
set(handles.cortexlrfile,'backgroundcolor','white')
if isequal(lrvizsource,1) && isempty(cortexlr)
    set(handles.cortexlrfile,'backgroundcolor','red')
end
guidata(hObject,handles)


% --- Executes on button press in info3.
function info3_Callback(hObject, eventdata, handles)
% hObject    handle to info3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
f=figure('Position', [500, 500, 200, 225]);
set(f,'MenuBar','none','ToolBar','none','color',[.94 .94 .94]);
btn=uicontrol('style','pushbutton','string','Close','Position',...
    [75 10 50 20],'Callback', 'close');
text1=uicontrol('style','text');
set(text1,'string','Low resolution (LR) source visualization recommended over normal visualization','Position',...
    [2 100 196 125])
text2=uicontrol('style','text');
set(text2,'string','Normal source vizualization should only be selected for replay','Position',...
    [2 100 196 50])
text3=uicontrol('style','text');
set(text3,'string','LR visualization can take ~20-30ms and cause processing delays','Position',...
    [2 35 196 50])


% --- Executes on button press in CheckESI.
function CheckESI_Callback(hObject, eventdata, handles)
% hObject    handle to CheckESI (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
[hObject,handles]=bci_fESI_Reset(hObject,handles,'ESI',[]);
[hObject,handles]=bci_fESI_CheckESI(hObject,handles);
guidata(hObject,handles)


% --- Executes on button press in SetESI.
function SetESI_Callback(hObject, eventdata, handles)
% hObject    handle to SetESI (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
[hObject,handles]=bci_fESI_Reset(hObject,handles,'BCI',[1,2]);
[hObject,handles]=bci_fESI_SetESI(hObject,handles);
guidata(hObject,handles) 


% --- Executes on button press in DispElecCurrent.
function DispElecCurrent_Callback(hObject, eventdata, handles)
% hObject    handle to DispElecCurrent (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
if isfield(handles,'SYSTEM') && isfield(handles.SYSTEM,'Electrodes') &&...
        isfield(handles.SYSTEM.Electrodes,'current') &&...
        isfield(handles.SYSTEM.Electrodes.current,'eLoc')
    [hObject,handles]=bci_fESI_Reset(hObject,handles,'None',[1,2]);
    eLoc=handles.SYSTEM.Electrodes.current.eLoc;
    axes(handles.axes3); cla
    set(handles.Axis3Label,'string','Current Electrode Montage');
    hold off; view(2); colorbar off; rotate3d off
    topoplot([],eLoc,'electrodes','ptlabels','headrad',.5);
    set(gcf,'color',[.94 .94 .94]); title('')
else
    fprintf(2,'MUST SELECT EEG SYSTEM TO PLOT ELECTRODES\n');
end

% --- Executes on button press in DispElecOrig.
function DispElecOrig_Callback(hObject, eventdata, handles)
% hObject    handle to DispElecOrig (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
if isfield(handles,'SYSTEM') && isfield(handles.SYSTEM,'Electrodes') &&...
        isfield(handles.SYSTEM.Electrodes,'original') &&...
    isfield(handles.SYSTEM.Electrodes.original,'eLoc') 
    [hObject,handles]=bci_fESI_Reset(hObject,handles,'None',[1,2]);
    eLoc=handles.SYSTEM.Electrodes.original.eLoc;
    axes(handles.axes3); cla
    set(handles.Axis3Label,'string','Original Electrode Montage');
    hold off; view(2); colorbar off; rotate3d off
    topoplot([],eLoc,'electrodes','ptlabels','headrad',.5);
    set(gcf,'color',[.94 .94 .94]); title('')
else
    fprintf(2,'MUST SELECT EEG SYSTEM TO PLOT ELECTRODES\n');
end


function SenSpikes_Callback(hObject, eventdata, handles)
% hObject    handle to SenSpikes (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'string') returns contents of SenSpikes as text
%        str2double(get(hObject,'string')) returns contents of SenSpikes as a double
[hObject,handles]=bci_fESI_Reset(hObject,handles,'None',0);
MaxChan=size(handles.SYSTEM.Electrodes.chanidxinclude,1);
cfg=struct('varname','SPIKES','defaultnum','','lowbound',1,'highbound',MaxChan,'numbers',MaxChan);
[hObject,handles]=bci_fESI_EnterNum(hObject,handles,cfg);
guidata(hObject,handles)

% --- Executes during object creation, after setting all properties.
function SenSpikes_CreateFcn(hObject, eventdata, handles)
% hObject    handle to SenSpikes (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'backgroundcolor'), get(0,'defaultUicontrolbackgroundcolor'))
    set(hObject,'backgroundcolor','white');
end


% --- Executes on button press in TestSource.
function TestSource_Callback(hObject, eventdata, handles)
% hObject    handle to TestSource (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
[hObject,handles]=bci_fESI_Reset(hObject,handles,'None',[]);
[hObject,handles]=bci_fESI_TestSource(hObject,handles);
guidata(hObject,handles)



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                          REGRESSION PARAMETERS                          %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% --- Executes on selection change in traindataformat.
function traindataformat_Callback(hObject, eventdata, handles)
% hObject    handle to traindataformat (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'string')) returns traindataformat contents as cell array
%        contents{get(hObject,'value')} returns selected item from traindataformat
guidata(hObject,handles)

% --- Executes during object creation, after setting all properties.
function traindataformat_CreateFcn(hObject, eventdata, handles)
% hObject    handle to traindataformat (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'backgroundcolor'), get(0,'defaultUicontrolbackgroundcolor'))
    set(hObject,'backgroundcolor','white');
end


% --- Executes on button press in checkvar.
function checkvar_Callback(hObject, eventdata, handles)
% hObject    handle to checkvar (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
[hObject,handles]=bci_fESI_CheckVar(hObject,handles);
guidata(hObject,handles)


% --- Executes on selection change in trainfiles.
function trainfiles_Callback(hObject, eventdata, handles)
% hObject    handle to trainfiles (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'string')) returns trainfiles contents as cell array
%        contents{get(hObject,'value')} returns selected item from trainfiles
% --- Executes during object creation, after setting all properties.

function trainfiles_CreateFcn(hObject, eventdata, handles)
% hObject    handle to trainfiles (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: listbox controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'backgroundcolor'), get(0,'defaultUicontrolbackgroundcolor'))
    set(hObject,'backgroundcolor','white');
end


% --- Executes on button press in AddTrain.
function AddTrain_Callback(hObject, eventdata, handles)
% hObject    handle to AddTrain (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
[hObject,handles]=bci_fESI_DataList(hObject,handles,'Add','trainfiles');
guidata(hObject,handles)


% --- Executes on button press in RemoveTrain.
function RemoveTrain_Callback(hObject, eventdata, handles)
% hObject    handle to RemoveTrain (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
[hObject,handles]=bci_fESI_DataList(hObject,handles,'Remove','trainfiles');
guidata(hObject,handles)


% --- Executes on button press in ClearTrain.
function ClearTrain_Callback(hObject, eventdata, handles)
% hObject    handle to ClearTrain (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
[hObject,handles]=bci_fESI_DataList(hObject,handles,'Clear','trainfiles');
guidata(hObject,handles)


% --- Executes on button press in CopyTrain.
function CopyTrain_Callback(hObject, eventdata, handles)
% hObject    handle to CopyTrain (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
[hObject,handles]=bci_fESI_DataList(hObject,handles,'Copy','trainfiles','esifiles');
guidata(hObject,handles)


% --- Executes on button press in Regression.
function Regression_Callback(hObject, eventdata, handles)
% hObject    handle to Regression (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
[hObject,handles]=bci_fESI_Reset(hObject,handles,'None',[]);
[hObject,handles]=bci_fESI_RegressionSetup(hObject,handles);
guidata(hObject,handles)


% --- Executes on button press in LoadRegress.
function LoadRegress_Callback(hObject, eventdata, handles)
% hObject    handle to LoadRegress (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
[hObject,handles]=bci_fESI_RegressionLoad(hObject,handles);
guidata(hObject,handles)


% --- Executes on selection change in regressvar.
function regressvar_Callback(hObject, eventdata, handles)
% hObject    handle to regressvar (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'string')) returns regressvar contents as cell array
%        contents{get(hObject,'value')} returns selected item from regressvar

% --- Executes during object creation, after setting all properties.
function regressvar_CreateFcn(hObject, eventdata, handles)
% hObject    handle to regressvar (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: listbox controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'backgroundcolor'), get(0,'defaultUicontrolbackgroundcolor'))
    set(hObject,'backgroundcolor','white');
end


% --- Executes on button press in DispRegress.
function DispRegress_Callback(hObject, eventdata, handles)
% hObject    handle to DispRegress (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
[hObject,handles]=bci_fESI_DispRegress(hObject,handles);
guidata(hObject,handles)


% --- Executes on button press in ShowClusters.
function ShowClusters_Callback(hObject, eventdata, handles)
% hObject    handle to ShowClusters (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'value') returns toggle state of ShowClusters
guidata(hObject,handles)


function RegressFreq_Callback(hObject, eventdata, handles)
% hObject    handle to RegressFreq (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'string') returns contents of RegressFreq as text
%        str2double(get(hObject,'string')) returns contents of RegressFreq as a double
cfg=struct('varname','REGRESSION_FREQUENCY','defaultnum','','lowbound',...
    handles.SYSTEM.lowcutoff,'highbound',handles.SYSTEM.highcutoff);
[hObject,handles]=bci_fESI_EnterNum(hObject,handles,cfg);
guidata(hObject,handles)

% --- Executes during object creation, after setting all properties.
function RegressFreq_CreateFcn(hObject, eventdata, handles)
% hObject    handle to RegressFreq (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'backgroundcolor'), get(0,'defaultUicontrolbackgroundcolor'))
    set(hObject,'backgroundcolor','white');
end


% --- Executes on button press in RegressFreqAll.
function RegressFreqAll_Callback(hObject, eventdata, handles)
% hObject    handle to RegressFreqAll (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'value') returns toggle state of RegressFreqAll
guidata(hObject,handles)



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                   BRAIN-COMPUTER INTERFACE PARAMETERS                   %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function analysiswindow_Callback(hObject, eventdata, handles)
% hObject    handle to analysiswindow (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'string') returns contents of analysiswindow as text
%        str2double(get(hObject,'string')) returns contents of analysiswindow as a double
[hObject,handles]=bci_fESI_Reset(hObject,handles,'BCI',[1,2]);
cfg=struct('varname','ANALYSIS_WINDOW','defaultnum','','lowbound',150,...
    'highbound',1000,'length',4);
[hObject,handles]=bci_fESI_EnterNum(hObject,handles,cfg);
guidata(hObject,handles)

% --- Executes during object creation, after setting all properties.
function analysiswindow_CreateFcn(hObject, eventdata, handles)
% hObject    handle to analysiswindow (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'backgroundcolor'), get(0,'defaultUicontrolbackgroundcolor'))
    set(hObject,'backgroundcolor','white');
end


function updatewindow_Callback(hObject, eventdata, handles)
% hObject    handle to updatewindow (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'string') returns contents of updatewindow as text
%        str2double(get(hObject,'string')) returns contents of updatewindow as a double
[hObject,handles]=bci_fESI_Reset(hObject,handles,'BCI',[1,2]);
cfg=struct('varname','UPDATE_WINDOW','defaultnum','','lowbound',60,'length',4);
if ~isempty(get(handles.analysiswindow,'string'))
    cfg.highbound=str2double(get(handles.analysiswindow,'string'));
else
    cfg.highbound=1000;
end
[hObject,handles]=bci_fESI_EnterNum(hObject,handles,cfg);
guidata(hObject,handles)

% --- Executes during object creation, after setting all properties.
function updatewindow_CreateFcn(hObject, eventdata, handles)
% hObject    handle to updatewindow (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'backgroundcolor'), get(0,'defaultUicontrolbackgroundcolor'))
    set(hObject,'backgroundcolor','white');
end


% --- Executes on button press in vizelec.
function vizelec_Callback(hObject, eventdata, handles)
% hObject    handle to vizelec (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'value') returns toggle state of vizelec
guidata(hObject,handles)


% --- Executes on selection change in bcidim1.
function bcidim1_Callback(hObject, eventdata, handles)
% hObject    handle to bcidim1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'string')) returns bcidim1 contents as cell array
%        contents{get(hObject,'value')} returns selected item from bcidim1
[hObject,handles]=bci_fESI_Reset(hObject,handles,'BCI','None');
[hObject,handles]=bci_fESI_BCISelect(hObject,handles,'dim',1);
guidata(hObject,handles)

% --- Executes during object creation, after setting all properties.
function bcidim1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to bcidim1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'backgroundcolor'), get(0,'defaultUicontrolbackgroundcolor'))
    set(hObject,'backgroundcolor','white');
end


% --- Executes on selection change in bcidim2.
function bcidim2_Callback(hObject, eventdata, handles)
% hObject    handle to bcidim2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'string')) returns bcidim2 contents as cell array
%        contents{get(hObject,'value')} returns selected item from bcidim2
[hObject,handles]=bci_fESI_Reset(hObject,handles,'BCI','None');
[hObject,handles]=bci_fESI_BCISelect(hObject,handles,'dim',2);
guidata(hObject,handles)

% --- Executes during object creation, after setting all properties.
function bcidim2_CreateFcn(hObject, eventdata, handles)
% hObject    handle to bcidim2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'backgroundcolor'), get(0,'defaultUicontrolbackgroundcolor'))
    set(hObject,'backgroundcolor','white');
end


% --- Executes on selection change in bcidim3.
function bcidim3_Callback(hObject, eventdata, handles)
% hObject    handle to bcidim3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'string')) returns bcidim3 contents as cell array
%        contents{get(hObject,'value')} returns selected item from bcidim3
[hObject,handles]=bci_fESI_Reset(hObject,handles,'BCI','None');
[hObject,handles]=bci_fESI_BCISelect(hObject,handles,'dim',3);
guidata(hObject,handles)

% --- Executes during object creation, after setting all properties.
function bcidim3_CreateFcn(hObject, eventdata, handles)
% hObject    handle to bcidim3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'backgroundcolor'), get(0,'defaultUicontrolbackgroundcolor'))
    set(hObject,'backgroundcolor','white');
end


% --- Executes on selection change in bcitask1.
function bcitask1_Callback(hObject, eventdata, handles)
% hObject    handle to bcitask1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'string')) returns bcitask1 contents as cell array
%        contents{get(hObject,'value')} returns selected item from bcitask1
[hObject,handles]=bci_fESI_Reset(hObject,handles,'BCI','None');
[hObject,handles]=bci_fESI_BCISelect(hObject,handles,'task',1);
set(handles.bciloc1,'backgroundcolor',[.94 .94 .94],'userdata',[]);
guidata(hObject,handles)

% --- Executes during object creation, after setting all properties.
function bcitask1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to bcitask1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'backgroundcolor'), get(0,'defaultUicontrolbackgroundcolor'))
    set(hObject,'backgroundcolor','white');
end


% --- Executes on selection change in bcitask2.
function bcitask2_Callback(hObject, eventdata, handles)
% hObject    handle to bcitask2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'string')) returns bcitask2 contents as cell array
%        contents{get(hObject,'value')} returns selected item from bcitask2
[hObject,handles]=bci_fESI_Reset(hObject,handles,'BCI','None');
[hObject,handles]=bci_fESI_BCISelect(hObject,handles,'task',2);
set(handles.bciloc2,'backgroundcolor',[.94 .94 .94],'userdata',[]);
guidata(hObject,handles);

% --- Executes during object creation, after setting all properties.
function bcitask2_CreateFcn(hObject, eventdata, handles)
% hObject    handle to bcitask2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'backgroundcolor'), get(0,'defaultUicontrolbackgroundcolor'))
    set(hObject,'backgroundcolor','white');
end


% --- Executes on selection change in bcitask3.
function bcitask3_Callback(hObject, eventdata, handles)
% hObject    handle to bcitask3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'string')) returns bcitask3 contents as cell array
%        contents{get(hObject,'value')} returns selected item from bcitask3
[hObject,handles]=bci_fESI_Reset(hObject,handles,'BCI','None');
[hObject,handles]=bci_fESI_BCISelect(hObject,handles,'task',3);
set(handles.bciloc3,'backgroundcolor',[.94 .94 .94],'userdata',[]);
guidata(hObject,handles)

% --- Executes during object creation, after setting all properties.
function bcitask3_CreateFcn(hObject, eventdata, handles)
% hObject    handle to bcitask3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'backgroundcolor'), get(0,'defaultUicontrolbackgroundcolor'))
    set(hObject,'backgroundcolor','white');
end


% --- Executes on selection change in bcifreq1.
function bcifreq1_Callback(hObject, eventdata, handles)
% hObject    handle to bcifreq1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'string')) returns bcifreq1 contents as cell array
%        contents{get(hObject,'value')} returns selected item from bcifreq1
[hObject,handles]=bci_fESI_Reset(hObject,handles,'BCI','None');
set(hObject,'backgroundcolor',[.94 .94 .94])
set(handles.bciloc1,'backgroundcolor',[.94 .94 .94],'userdata',[]);
guidata(hObject,handles)

% --- Executes during object creation, after setting all properties.
function bcifreq1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to bcifreq1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'backgroundcolor'), get(0,'defaultUicontrolbackgroundcolor'))
    set(hObject,'backgroundcolor','white');
end


% --- Executes on selection change in bcifreq2.
function bcifreq2_Callback(hObject, eventdata, handles)
% hObject    handle to bcifreq2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'string')) returns bcifreq2 contents as cell array
%        contents{get(hObject,'value')} returns selected item from bcifreq2
[hObject,handles]=bci_fESI_Reset(hObject,handles,'BCI','None');
set(hObject,'backgroundcolor',[.94 .94 .94])
set(handles.bciloc2,'backgroundcolor',[.94 .94 .94],'userdata',[]);
guidata(hObject,handles)

% --- Executes during object creation, after setting all properties.
function bcifreq2_CreateFcn(hObject, eventdata, handles)
% hObject    handle to bcifreq2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'backgroundcolor'), get(0,'defaultUicontrolbackgroundcolor'))
    set(hObject,'backgroundcolor','white');
end


% --- Executes on selection change in bcifreq3.
function bcifreq3_Callback(hObject, eventdata, handles)
% hObject    handle to bcifreq3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'string')) returns bcifreq3 contents as cell array
%        contents{get(hObject,'value')} returns selected item from bcifreq3
[hObject,handles]=bci_fESI_Reset(hObject,handles,'BCI','None');
set(hObject,'backgroundcolor',[.94 .94 .94])
set(handles.bciloc3,'backgroundcolor',[.94 .94 .94],'userdata',[]);
guidata(hObject,handles)

% --- Executes during object creation, after setting all properties.
function bcifreq3_CreateFcn(hObject, eventdata, handles)
% hObject    handle to bcifreq3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'backgroundcolor'), get(0,'defaultUicontrolbackgroundcolor'))
    set(hObject,'backgroundcolor','white');
end


% --- Executes on button press in bciloc1.
function bciloc1_Callback(hObject, eventdata, handles)
% hObject    handle to bciloc1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
[hObject,handles]=bci_fESI_Reset(hObject,handles,'BCI','None');
[hObject,handles]=bci_fESI_BCISelectLoc(hObject,handles,1);
guidata(hObject,handles)


% --- Executes on button press in bciloc2.
function bciloc2_Callback(hObject, eventdata, handles)
% hObject    handle to bciloc2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
[hObject,handles]=bci_fESI_Reset(hObject,handles,'BCI','None');
[hObject,handles]=bci_fESI_BCISelectLoc(hObject,handles,2);
guidata(hObject,handles)


% --- Executes on button press in bciloc3.
function bciloc3_Callback(hObject, eventdata, handles)
% hObject    handle to bciloc3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
[hObject,handles]=bci_fESI_Reset(hObject,handles,'BCI','None');
[hObject,handles]=bci_fESI_BCISelectLoc(hObject,handles,3);
guidata(hObject,handles)


% --- Executes on button press in BCIClear1.
function BCIClear1_Callback(hObject, eventdata, handles)
% hObject    handle to BCIClear1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
[hObject,handles]=bci_fESI_Reset(hObject,handles,'BCI','None');
[hObject,handles]=bci_fESI_ResetBCI(hObject,handles,1,'Reset');
guidata(hObject,handles)


% --- Executes on button press in BCIClear2.
function BCIClear2_Callback(hObject, eventdata, handles)
% hObject    handle to BCIClear2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
[hObject,handles]=bci_fESI_Reset(hObject,handles,'BCI','None');
[hObject,handles]=bci_fESI_ResetBCI(hObject,handles,2,'Reset');
guidata(hObject,handles)


% --- Executes on button press in BCIClear3.
function BCIClear3_Callback(hObject, eventdata, handles)
% hObject    handle to BCIClear3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
[hObject,handles]=bci_fESI_Reset(hObject,handles,'BCI','None');
[hObject,handles]=bci_fESI_ResetBCI(hObject,handles,3,'Reset');
guidata(hObject,handles)


function gain1_Callback(hObject, eventdata, handles)
% hObject    handle to gain1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'string') returns contents of gain1 as text
%        str2double(get(hObject,'string')) returns contents of gain1 as a double
cfg=struct('varname','GAIN_1','defaultnum','.01');
[hObject,handles]=bci_fESI_EnterNum(hObject,handles,cfg);
guidata(hObject,handles)

% --- Executes during object creation, after setting all properties.
function gain1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to gain1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'backgroundcolor'), get(0,'defaultUicontrolbackgroundcolor'))
    set(hObject,'backgroundcolor','white');
end


function gain2_Callback(hObject, eventdata, handles)
% hObject    handle to gain2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'string') returns contents of gain2 as text
%        str2double(get(hObject,'string')) returns contents of gain2 as a double
cfg=struct('varname','GAIN_2','defaultnum','.01');
[hObject,handles]=bci_fESI_EnterNum(hObject,handles,cfg);
guidata(hObject,handles)

% --- Executes during object creation, after setting all properties.
function gain2_CreateFcn(hObject, eventdata, handles)
% hObject    handle to gain2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'backgroundcolor'), get(0,'defaultUicontrolbackgroundcolor'))
    set(hObject,'backgroundcolor','white');
end


function gain3_Callback(hObject, eventdata, handles)
% hObject    handle to gain3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'string') returns contents of gain3 as text
%        str2double(get(hObject,'string')) returns contents of gain3 as a double
cfg=struct('varname','GAIN_3','defaultnum','.01');
[hObject,handles]=bci_fESI_EnterNum(hObject,handles,cfg);
guidata(hObject,handles)

% --- Executes during object creation, after setting all properties.
function gain3_CreateFcn(hObject, eventdata, handles)
% hObject    handle to gain3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'backgroundcolor'), get(0,'defaultUicontrolbackgroundcolor'))
    set(hObject,'backgroundcolor','white');
end


function offset1_Callback(hObject, eventdata, handles)
% hObject    handle to offset1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'string') returns contents of offset1 as text
%        str2double(get(hObject,'string')) returns contents of offset1 as a double
cfg=struct('varname','OFFSET_1','defaultnum','0');
[hObject,handles]=bci_fESI_EnterNum(hObject,handles,cfg);
guidata(hObject,handles)

% --- Executes during object creation, after setting all properties.
function offset1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to offset1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'backgroundcolor'), get(0,'defaultUicontrolbackgroundcolor'))
    set(hObject,'backgroundcolor','white');
end


function offset2_Callback(hObject, eventdata, handles)
% hObject    handle to offset2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'string') returns contents of offset2 as text
%        str2double(get(hObject,'string')) returns contents of offset2 as a double
cfg=struct('varname','OFFSET_@','defaultnum','0');
[hObject,handles]=bci_fESI_EnterNum(hObject,handles,cfg);
guidata(hObject,handles)

% --- Executes during object creation, after setting all properties.
function offset2_CreateFcn(hObject, eventdata, handles)
% hObject    handle to offset2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'backgroundcolor'), get(0,'defaultUicontrolbackgroundcolor'))
    set(hObject,'backgroundcolor','white');
end


function offset3_Callback(hObject, eventdata, handles)
% hObject    handle to offset3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'string') returns contents of offset3 as text
%        str2double(get(hObject,'string')) returns contents of offset3 as a double
cfg=struct('varname','OFFSET_3','defaultnum','0');
[hObject,handles]=bci_fESI_EnterNum(hObject,handles,cfg);
guidata(hObject,handles)

% --- Executes during object creation, after setting all properties.
function offset3_CreateFcn(hObject, eventdata, handles)
% hObject    handle to offset3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'backgroundcolor'), get(0,'defaultUicontrolbackgroundcolor'))
    set(hObject,'backgroundcolor','white')
end
guidata(hObject,handles)


function scale1_Callback(hObject, eventdata, handles)
% hObject    handle to scale1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'string') returns contents of scale1 as text
%        str2double(get(hObject,'string')) returns contents of scale1 as a double
cfg=struct('varname','SCALE_1','defaultnum','1');
[hObject,handles]=bci_fESI_EnterNum(hObject,handles,cfg);
guidata(hObject,handles)

% --- Executes during object creation, after setting all properties.
function scale1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to scale1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'backgroundcolor'), get(0,'defaultUicontrolbackgroundcolor'))
    set(hObject,'backgroundcolor','white');
end


function scale2_Callback(hObject, eventdata, handles)
% hObject    handle to scale2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'string') returns contents of scale2 as text
%        str2double(get(hObject,'string')) returns contents of scale2 as a double
cfg=struct('varname','SCALE_2','defaultnum','1');
[hObject,handles]=bci_fESI_EnterNum(hObject,handles,cfg);
guidata(hObject,handles)

% --- Executes during object creation, after setting all properties.
function scale2_CreateFcn(hObject, eventdata, handles)
% hObject    handle to scale2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'backgroundcolor'), get(0,'defaultUicontrolbackgroundcolor'))
    set(hObject,'backgroundcolor','white');
end


function scale3_Callback(hObject, eventdata, handles)
% hObject    handle to scale3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'string') returns contents of scale3 as text
%        str2double(get(hObject,'string')) returns contents of scale3 as a double
cfg=struct('varname','SCALE_3','defaultnum','1');
[hObject,handles]=bci_fESI_EnterNum(hObject,handles,cfg);
guidata(hObject,handles)

% --- Executes during object creation, after setting all properties.
function scale3_CreateFcn(hObject, eventdata, handles)
% hObject    handle to scale3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'backgroundcolor'), get(0,'defaultUicontrolbackgroundcolor'))
    set(hObject,'backgroundcolor','white');
end


% --- Executes on button press in ResetNormSettings.
function ResetNormSettings_Callback(hObject, eventdata, handles)
% hObject    handle to ResetNormSettings (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
[hObject,handles]=bci_fESI_Reset(hObject,handles,{'StartBCI' 'StartTrain' 'Stop'},0);
fields={'gain1','gain2','gain3','offset1','offset2','offset3',...
    'scale1','scale2','scale3'};
values={'0.01','0.01','0.01','0','0','0','1','1','1'};
for i=1:size(fields,2)
    set(handles.(fields{i}),'backgroundcolor',[.94 .94 .94],'string',values{i})
end
guidata(hObject,handles)


function buffercyclelength_Callback(hObject, eventdata, handles)
% hObject    handle to buffercyclelength (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'string') returns contents of buffercyclelength as text
%        str2double(get(hObject,'string')) returns contents of buffercyclelength as a double
[hObject,handles]=bci_fESI_Reset(hObject,handles,{'StartBCI' 'StartTrain' 'Stop'},0);
cfg=struct('varname','CYCLE_LENGTH','defaultnum',50,'lowbound',10,'highbound',5000);
[hObject,handles]=bci_fESI_EnterNum(hObject,handles,cfg);
guidata(hObject,handles)

% --- Executes during object creation, after setting all properties.
function buffercyclelength_CreateFcn(hObject, eventdata, handles)
% hObject    handle to buffercyclelength (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'backgroundcolor'), get(0,'defaultUicontrolbackgroundcolor'))
    set(hObject,'backgroundcolor','white');
end


function bufferlength_Callback(hObject, eventdata, handles)
% hObject    handle to bufferlength (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'string') returns contents of bufferlength as text
%        str2double(get(hObject,'string')) returns contents of bufferlength as a double
[hObject,handles]=bci_fESI_Reset(hObject,handles,{'StartBCI' 'StartTrain' 'Stop'},0);
cfg=struct('varname','BUFFER_LENGTH','defaultnum',5,'lowbound',1,'highbound',20);
[hObject,handles]=bci_fESI_EnterNum(hObject,handles,cfg);
guidata(hObject,handles)

% --- Executes during object creation, after setting all properties.
function bufferlength_CreateFcn(hObject, eventdata, handles)
% hObject    handle to bufferlength (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'backgroundcolor'), get(0,'defaultUicontrolbackgroundcolor'))
    set(hObject,'backgroundcolor','white')
end


% --- Executes on button press in FixNormVal.
function FixNormVal_Callback(hObject, eventdata, handles)
% hObject    handle to FixNormVal (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'value') returns toggle state of FixNormVal
guidata(hObject,handles)


% --- Executes on button press in dispcs.
function dispcs_Callback(hObject, eventdata, handles)
% hObject    handle to dispcs (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'value') returns toggle state of dispcs
guidata(hObject,handles)


% --- Executes on button press in CheckBCI.
function CheckBCI_Callback(hObject, eventdata, handles)
% hObject    handle to CheckBCI (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
[hObject,handles]=bci_fESI_Reset(hObject,handles,'BCI',[]);
[hObject,handles]=bci_fESI_CheckBCI(hObject,handles);
guidata(hObject,handles)

% --- Executes on button press in SetBCI.
function SetBCI_Callback(hObject, eventdata, handles)
% hObject    handle to SetBCI (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
[hObject,handles]=bci_fESI_Reset(hObject,handles,{'StartBCI' 'StartTrain' 'Stop'},[]);
[hObject,handles]=bci_fESI_SetBCI(hObject,handles);
guidata(hObject,handles)


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                          SAVED FILE PARAMETERS                          %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% --- Executes on selection change in savefiles.
function savefiles_Callback(hObject, eventdata, handles)
% hObject    handle to savefiles (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'string')) returns savefiles contents as cell array
%        contents{get(hObject,'value')} returns selected item from savefiles

% --- Executes during object creation, after setting all properties.
function savefiles_CreateFcn(hObject, eventdata, handles)
% hObject    handle to savefiles (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: listbox controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'backgroundcolor'), get(0,'defaultUicontrolbackgroundcolor'))
    set(hObject,'backgroundcolor','white');
end


% --- Executes on button press in DisplaySaved.
function DisplaySaved_Callback(hObject, eventdata, handles)
% hObject    handle to DisplaySaved (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
[hObject,handles]=bci_fESI_DispSaved(hObject,handles);
guidata(hObject,handles);


function LeadFieldFreq_Callback(hObject, eventdata, handles)
% hObject    handle to LeadFieldFreq (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'string') returns contents of LeadFieldFreq as text
%        str2double(get(hObject,'string')) returns contents of LeadFieldFreq as a double
cfg.varname='LEAD_FIELD_FREQUENCY'; cfg.defaultnum='';
cfg.lowbound=handles.ESI.lowcutoff;
cfg.highbound=handles.ESI.highcutoff;
[hObject,handles]=bci_fESI_EnterNum(hObject,handles,cfg);
guidata(hObject,handles)

% --- Executes during object creation, after setting all properties.
function LeadFieldFreq_CreateFcn(hObject, eventdata, handles)
% hObject    handle to LeadFieldFreq (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'backgroundcolor'), get(0,'defaultUicontrolbackgroundcolor'))
    set(hObject,'backgroundcolor','white')
end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                       ONLINE PROCESSING PARAMETERS                      %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% --- Executes on button press in StartBCI.
function StartBCI_Callback(hObject, eventdata, handles)
% hObject    handle to StartBCI (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% get(handles.SetBCI,'userdata')
[hObject,handles]=bci_fESI_RunBCI(hObject,handles);
guidata(hObject,handles)


% --- Executes on button press in StartTrain.
function StartTrain_Callback(hObject, eventdata, handles)
% hObject    handle to StartTrain (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
[hObject,handles]=bci_fESI_RunTrain(hObject,handles);
guidata(hObject,handles)


% --- Executes on button press in Stop.
function Stop_Callback(hObject, eventdata, handles)
% hObject    handle to Stop (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
if isequal(get(handles.Stop,'userdata'),1)
    set(handles.Stop,'userdata',0);
elseif isequal(get(handles.Stop,'userdata'),0)
    set(handles.Stop,'userdata',1);
end
guidata(hObject,handles);


% --- Executes on button press in info1.
function info1_Callback(hObject, eventdata, handles)
% hObject    handle to info1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
f=figure('Position', [500, 500, 200, 100]);
set(f,'MenuBar','none');
set(f,'ToolBar','none');
btn=uicontrol('style','pushbutton','string','Close','Position',...
    [75 10 50 20],'Callback', 'close');
text1=uicontrol('style','text');
set(gcf,'color',[.94 .94 .94]);
set(text1,'string','Vizualizing electrode activity can cost ~10-20ms and cause processing delays','Position',...
    [2 50 196 50])


% --- Executes on button press in info2.
function info2_Callback(hObject, eventdata, handles)
% hObject    handle to info2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
f=figure('Position', [500, 500, 200, 100]);
set(f,'MenuBar','none');
set(f,'ToolBar','none');
set(gcf,'color',[.94 .94 .94]);
btn=uicontrol('style','pushbutton','string','Close','Position',...
    [75 10 50 20],'Callback', 'close');
text1=uicontrol('style','text');
set(text1,'string','Displaying the control signal can cost ~5-10ms and cause processing delays','Position',...
    [2 50 196 50])

% --- Executes on button press in info4.
function info4_Callback(hObject, eventdata, handles)
% hObject    handle to info4 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
f=figure('Position', [500, 500, 200, 100]);
set(f,'MenuBar','none');
set(f,'ToolBar','none');
set(gcf,'color',[.94 .94 .94]);
btn=uicontrol('style','pushbutton','string','Close','Position',...
    [75 10 50 20],'Callback', 'close');
text1=uicontrol('style','text');
set(text1,'string','Indicates size of buffer, in trials, for each dimension in use','Position',...
    [2 50 196 50])


% --- Executes on button press in DispEEG.
function DispEEG_Callback(hObject, eventdata, handles)
% hObject    handle to DispEEG (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
[hObject,handles]=bci_fESI_DispEEG(hObject,handles);
guidata(hObject,handles)

   
% --- Executes on button press in AllChanEEG.
function AllChanEEG_Callback(hObject, eventdata, handles)
% hObject    handle to AllChanEEG (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'value') returns toggle state of AllChanEEG
guidata(hObject,handles)
