function varargout = labelingMenu(varargin)
% LABELINGMENU M-file for labelingMenu.fig
%      LABELINGMENU, by itself, creates a new LABELINGMENU or raises the existing
%      singleton*.
%
%      H = LABELINGMENU returns the handle to a new LABELINGMENU or the handle to
%      the existing singleton*.
%
%      LABELINGMENU('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in LABELINGMENU.M with the given input arguments.
%
%      LABELINGMENU('Property','Value',...) creates a new LABELINGMENU or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before labelingMenu_OpeningFunction gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to labelingMenu_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help labelingMenu

% Last Modified by GUIDE v2.5 25-Jul-2007 16:05:32

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @labelingMenu_OpeningFcn, ...
                   'gui_OutputFcn',  @labelingMenu_OutputFcn, ...
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


% --- Executes just before labelingMenu is made visible.
function labelingMenu_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to labelingMenu (see VARARGIN)

% Choose default command line output for labelingMenu
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes labelingMenu wait for user response (see UIRESUME)
% uiwait(handles.figure1);

addpath ../;
setPath;

global infoStruct guiStatus;

% setup GUI status
guiStatus.isPaused = 0;
guiStatus.handles = handles;

minTimeout = 5.0;
maxTimeout = 20.0;

% setup the timers
guiStatus.timerMin = timer('TimerFcn', @timerMin, 'ErrorFcn', @timerMinError, 'StartDelay', minTimeout, ...
    'ExecutionMode', 'singleShot', 'BusyMode', 'error');
guiStatus.timerMax = timer('TimerFcn', @timerMax, 'ErrorFcn', @timerMaxError, 'StartDelay', maxTimeout, ...
    'ExecutionMode', 'fixedSpacing', 'Period', maxTimeout, 'BusyMode', 'error');

guiStatus.demoMode = 0;

if length(varargin) == 1
    fprintf('Starting in DEMO mode... no results will be saved.\n');
    guiStatus.demoMode = varargin{1};
else
    fprintf('Starting in REGULAR mode... all results will be saved.\n');
end

% define the input and output paths
infoStruct.dbBasePath = fullfile(basePath, 'dataset', 'filteredDb');
infoStruct.dbPath = fullfile(infoStruct.dbBasePath, 'Annotation');
infoStruct.imagesPath = fullfile(infoStruct.dbBasePath, 'Images');

% Ask the user for the labeler ID
global labelerId;
h = labelerIdMenu;
uiwait(h);

fprintf('Labeler %d...\n', labelerId);

infoStruct.labelingPath = fullfile(basePath, 'dataset', 'labeling');
infoStruct.outputBasePath = fullfile(infoStruct.labelingPath, sprintf('labeler_%04d', labelerId));
[m,m,m] = mkdir(infoStruct.outputBasePath);

% Read all the files to process
infoStruct.files = dir(fullfile(infoStruct.dbPath, 'image_0*.xml'));
infoStruct.files = {infoStruct.files.name};

% Get the indices
infoStruct.indices = randperm(length(infoStruct.files));
infoStruct.curInd = 0;

% Load first image
showNextImage;
startTimers;



% --- Outputs from this function are returned to the command line.
function varargout = labelingMenu_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on button press in buttonYes.
function buttonYes_Callback(hObject, eventdata, handles)
% hObject    handle to buttonYes (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

time = stopTimers;
saveLabel('r', time);
showNextImage;
startTimers;

% --- Executes on button press in buttonNo.
function buttonNo_Callback(hObject, eventdata, handles)
% hObject    handle to buttonNo (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

time = stopTimers;
saveLabel('u', time);
showNextImage;
startTimers;

% --- Executes on button press in buttonUnknown.
function buttonUnknown_Callback(hObject, eventdata, handles)
% hObject    handle to buttonUnknown (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

time = stopTimers;
saveLabel('o', time);
showNextImage;
startTimers;


function showNextImage

global infoStruct guiStatus;

% read the next unlabelled file
while 1
    infoStruct.curInd = infoStruct.curInd + 1;
    
    if infoStruct.curInd > length(infoStruct.indices)
        h=msgbox('You''re done, thank you very much!!', 'CreateMode', 'Modal');
        uiwait(h);
        delete(guiStatus.handles.figure1);
        
        % we're done!
        return;
    end
    
    imgInfoPath = fullfile(infoStruct.dbPath, infoStruct.files{infoStruct.indices(infoStruct.curInd)});
    imgInfo = loadXML(imgInfoPath);
    
    outXmlPath = fullfile(infoStruct.outputBasePath, imgInfo.file.folder, imgInfo.file.filename);
    if ~exist(outXmlPath, 'file')
        break;
    end 
end

imgPath = fullfile(infoStruct.imagesPath, imgInfo.image.folder, imgInfo.image.filename);
img = imread(imgPath);
image(img, 'Parent', guiStatus.handles.imageFig);


% disable the buttons
set(guiStatus.handles.buttonYes, 'Enable', 'off');
set(guiStatus.handles.buttonNo, 'Enable', 'off');
set(guiStatus.handles.buttonUnknown, 'Enable', 'off');

% startTimers;

%%%%%
function startTimers

global guiStatus;

% start the min timer
start(guiStatus.timerMin);
start(guiStatus.timerMax);
set(guiStatus.timerMax, 'UserData', tic);

%%%%%
function time = stopTimers

global guiStatus;

% stop the timers
stop(guiStatus.timerMin);
stop(guiStatus.timerMax);

% retrieve the time it took to label
time = toc(get(guiStatus.timerMax, 'UserData'));

%%%%%
function saveLabel(label, time)

global infoStruct guiStatus;

imgInfoPath = fullfile(infoStruct.dbPath, infoStruct.files{infoStruct.indices(infoStruct.curInd)});
imgInfo = loadXML(imgInfoPath);

outImgInfo.image = imgInfo.image;
outImgInfo.file = imgInfo.file;

outImgInfo.class.type = label;
outImgInfo.class.time = time;

if ~guiStatus.demoMode
    outImgPath = fullfile(infoStruct.outputBasePath, outImgInfo.file.folder, outImgInfo.file.filename);
    writeXML(outImgPath, outImgInfo);

    fprintf('%.2fs, label: %s, saved %s.\n', time, label, outImgPath);
end


% --- Executes on button press in buttonPause.
function buttonPause_Callback(hObject, eventdata, handles)
% hObject    handle to buttonPause (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

global guiStatus;
% check if we were in the paused status

if guiStatus.isPaused
    % resume
    set(hObject, 'String', 'Pause');
    guiStatus.isPaused = 0;
    
    % re-start the timers
    startTimers;
    
else
    % pause
    set(hObject, 'String', 'Resume');
    guiStatus.isPaused = 1;
    
    % disable the buttons
    set(handles.buttonYes, 'Enable', 'off');
    set(handles.buttonNo, 'Enable', 'off');
    set(handles.buttonUnknown, 'Enable', 'off');
    
    % stop the timers
    stopTimers;
end

% callback called when the minimum-time timer has been expired
function timerMin(obj, event)

global guiStatus;

% enable the buttons
set(guiStatus.handles.buttonYes, 'Enable', 'on');
set(guiStatus.handles.buttonNo, 'Enable', 'on');
set(guiStatus.handles.buttonUnknown, 'Enable', 'on');

% stop the min timer, but leave the other one running
stop(guiStatus.timerMin);


% callback called when the minimum-time timer has been expired
function timerMax(obj, event)

global guiStatus;

% stop(guiStatus.timerMax);

% save the current image to unknown
saveLabel('u', get(guiStatus.timerMax, 'Period'));

% display the next image
showNextImage;

start(guiStatus.timerMin);
set(guiStatus.timerMax, 'UserData', tic);


% --- Executes on button press in buttonQuit.
function buttonQuit_Callback(hObject, eventdata, handles)
% hObject    handle to buttonQuit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

global guiStatus;

stopTimers;

% delete the timers
delete(guiStatus.timerMin);
delete(guiStatus.timerMax);

delete(handles.figure1);


% callback called when the minimum-time timer has been expired
function timerMinError(obj, event)

fprintf('Timer min error!\n');

% callback called when the minimum-time timer has been expired
function timerMaxError(obj, event)

fprintf('Timer max error!\n');



