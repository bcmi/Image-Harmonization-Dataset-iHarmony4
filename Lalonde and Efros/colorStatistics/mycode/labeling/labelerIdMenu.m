function varargout = labelerIdMenu(varargin)
% LABELERIDMENU M-file for labelerIdMenu.fig
%      LABELERIDMENU, by itself, creates a new LABELERIDMENU or raises the existing
%      singleton*.
%
%      H = LABELERIDMENU returns the handle to a new LABELERIDMENU or the handle to
%      the existing singleton*.
%
%      LABELERIDMENU('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in LABELERIDMENU.M with the given input arguments.
%
%      LABELERIDMENU('Property','Value',...) creates a new LABELERIDMENU or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before labelerIdMenu_OpeningFunction gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to labelerIdMenu_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help labelerIdMenu

% Last Modified by GUIDE v2.5 25-Jul-2007 11:48:26

global labelerId;
labelerId = 0;

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @labelerIdMenu_OpeningFcn, ...
                   'gui_OutputFcn',  @labelerIdMenu_OutputFcn, ...
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


% --- Executes just before labelerIdMenu is made visible.
function labelerIdMenu_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to labelerIdMenu (see VARARGIN)

% Choose default command line output for labelerIdMenu
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes labelerIdMenu wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = labelerIdMenu_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;



function labelerIdBox_Callback(hObject, eventdata, handles)
% hObject    handle to labelerIdBox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of labelerIdBox as text
%        str2double(get(hObject,'String')) returns contents of labelerIdBox as a double


% --- Executes during object creation, after setting all properties.
function labelerIdBox_CreateFcn(hObject, eventdata, handles)
% hObject    handle to labelerIdBox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in buttonOK.
function buttonOK_Callback(hObject, eventdata, handles)
% hObject    handle to buttonOK (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global labelerId;
labelerId = str2double(get(handles.labelerIdBox, 'String'));
uiresume;
delete(handles.figure1);

