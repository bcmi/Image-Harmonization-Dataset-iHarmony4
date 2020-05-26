function userfeedback(packageName, calledFile, minNrOfCalls, minPeriodInDays)
%USERFEEDBACK  Ask user for feedback after frequent function starts.
%   USERFEEDBACK(packageName, calledFile) will open an input dialog asking
%   the user to provide feedback on the package names packageName if called
%   from function calledFile at least 20 times and if the first call was at
%   least 14 days before.
%
%   USERFEEDBACK(packageName, calledFile, minNrOfCalls, minPeriodInDays)
%   will use the numbers minNrOfCalls and minPeriodInDays when to ask for
%   feedback first.
%
%   Markus Buehren
%   Last edited 19.06.2009
%
%   See also INPUTDLG.

askEachTime = 0; % for debugging

error(nargchk(2, 4, nargin, 'struct'))

if ~exist('minNrOfCalls', 'var')
  minNrOfCalls = 20;
end
if ~exist('minPeriodInDays', 'var')
  minPeriodInDays = 14;
end

% build file name
feedbackFileName = fullfile(tempdir2, sprintf('userfeedback_%s.mat', calledFile));

% check if data was saved before
if exist(feedbackFileName, 'file')
  try
    load(feedbackFileName, 'nrOfCalls', 'firstCallTime', 'askedForFeedback');
  catch
    % avoid bothering the user, do nothing
    return
  end
else
  nrOfCalls        = 0;
  firstCallTime    = clock;
  askedForFeedback = false;
end

% update data
nrOfCalls = nrOfCalls + 1;

% check if user shall be asked for feedback
askForFeedbackNow = ~askedForFeedback && nrOfCalls >= minNrOfCalls && etime(clock, firstCallTime) >= minPeriodInDays * 86400; %#ok

% save updated data
askedForFeedback = askForFeedbackNow || askedForFeedback; %#ok
if ~askEachTime
  try %#ok % do not bother the user with error messages
    save(feedbackFileName, 'nrOfCalls', 'firstCallTime', 'askedForFeedback');
  end
end

if askEachTime
  askForFeedbackNow = 1;
end

% ask user for feedback
if askForFeedbackNow
  % start feedback dialog
  introText = sprintf([...
    'You have started the function %s.m for at least %d times. It seems that ', ...
    'the %s package is of help to you!\n\nI am curious about who you are and ', ...
    'what you are using the package for. Thus I would like to ask you for a ', ...
    'short feedback. Put everything you like into the fields below.\n\nOnce you ', ...
    'press OK, the data is sent to my private home page markusbuehren.de. ', ...
    'No private data from your machine will be transmitted.\n\nThis dialog ', ...
    'field should appear only once on this computer. If it should bother you, ', ...
    'remove the line containing the call to function "userfeedback" in ', ...
    'function %s.m.\n\nRegards \nMarkus Buehren'], ...
    calledFile, minNrOfCalls, packageName, calledFile);

  prompt = {sprintf('%s\n\nYour name:', introText), 'The place you live:', ...
    'Your E-mail address:', sprintf(['Your feedback. For example:\n', ...
    '* In which area you are working and which area you are using Matlab for.\n', ...
    '* Which kind of problems you are solving with the %s package.\n', ...
    '* How you like the package and its documentation.', ...
    ], packageName)};
  defaultAnswers = {'', '', '', sprintf('I like the %s package, because ...', packageName)};
  nrOfLines = [1, 1, 1, 4];
  figTitle = sprintf('User feedback on the %s package', packageName);

  try %#ok % do not bother the user with error messages
    feedbackdlg(prompt, figTitle, nrOfLines, defaultAnswers, @sendfeedback);
  end
end

  function sendfeedback(answers)
    % nested function for sending user feedback as callback

    % send feedback to server
    if ~isempty(answers)
      
      % form single line from multi-line inputs
      for answerNr = 1:length(answers)
        if ischar(answers{answerNr}) && size(answers{answerNr}, 1) > 1
          strCell = cellstr(answers{answerNr});
          str = strCell{1};
          for strNr = 2:length(strCell)
            str = [str '\n' strCell{strNr}]; %#ok % The un-escaped \n ends up in a line break in the MySql database
          end
          answers{answerNr} = str;
        end
      end
      
      try %#ok % do not bother the user with error messages
        urlread('http://markusbuehren.de/userfeedback/save.php', 'get', {...
          'package',    packageName, ...
          'name',       answers{1}, ...
          'place',      answers{2}, ...
          'email',      answers{3}, ...
          'feedback',   answers{4}, ...
          'dateMatlab', sprintf('%04d-%02d-%02d %02d:%02d:%02d', round(clock)), ...
          'check',     'Fjgh734F8jQmYYKs'});
      end
    end
  end
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function feedbackdlg(Prompt, Title, NumLines, DefAns, sendfeedbackHandle)
%FEEDBACKDLG Input dialog.
% This is a modified version of Matlab function INPUTDLG. The modification
% is that uiwait will not be called, instead the given function handle is
% called when the OK button is pressed.

NumQuest=numel(Prompt);

WindowStyle = 'normal';
Interpreter = 'none';
Resize      = 'off';

[rw,cl]=size(NumLines);
OneVect = ones(NumQuest,1);
if (rw == 1 & cl == 2) %#ok Handle []
  NumLines=NumLines(OneVect,:);
elseif (rw == 1 & cl == 1) %#ok
  NumLines=NumLines(OneVect);
elseif (rw == 1 & cl == NumQuest) %#ok
  NumLines = NumLines';
elseif (rw ~= NumQuest | cl > 2) %#ok
  error('MATLAB:inputdlg:IncorrectSize', 'NumLines size is incorrect.')
end

%%%%%%%%%%%%%%%%%%%%%%%
%%% Create InputFig %%%
%%%%%%%%%%%%%%%%%%%%%%%
FigWidth=175;
FigHeight=100;
FigPos(3:4)=[FigWidth FigHeight];  %#ok
FigColor=get(0,'DefaultUicontrolBackgroundcolor');

InputFig=dialog(                     ...
  'Visible'          ,'off'      , ...
  'KeyPressFcn'      ,@doFigureKeyPress, ...
  'Name'             ,Title      , ...
  'Pointer'          ,'arrow'    , ...
  'Units'            ,'pixels'   , ...
  'UserData'         ,'Cancel'   , ...
  'Tag'              ,Title      , ...
  'HandleVisibility' ,'callback' , ...
  'Color'            ,FigColor   , ...
  'NextPlot'         ,'add'      , ...
  'WindowStyle'      ,WindowStyle, ...
  'DoubleBuffer'     ,'on'       , ...
  'Resize'           ,Resize       ...
  );
set(InputFig, 'HandleVisibility', 'on', 'CloseRequestFcn', 'closereq');


%%%%%%%%%%%%%%%%%%%%%
%%% Set Positions %%%
%%%%%%%%%%%%%%%%%%%%%
DefOffset    = 5;
DefBtnWidth  = 53;
DefBtnHeight = 23;

TextInfo.Units              = 'pixels'   ;
TextInfo.FontSize           = get(0,'FactoryUIControlFontSize');
TextInfo.FontWeight         = get(InputFig,'DefaultTextFontWeight');
TextInfo.HorizontalAlignment= 'left'     ;
TextInfo.HandleVisibility   = 'callback' ;

StInfo=TextInfo;
StInfo.Style              = 'text'  ;
StInfo.BackgroundColor    = FigColor;

EdInfo=StInfo;
EdInfo.FontWeight      = get(InputFig,'DefaultUicontrolFontWeight');
EdInfo.Style           = 'edit';
EdInfo.BackgroundColor = 'white';

BtnInfo=StInfo;
BtnInfo.FontWeight          = get(InputFig,'DefaultUicontrolFontWeight');
BtnInfo.Style               = 'pushbutton';
BtnInfo.HorizontalAlignment = 'center';

% Add VerticalAlignment here as it is not applicable to the above.
TextInfo.VerticalAlignment  = 'bottom';
TextInfo.Color              = get(0,'FactoryUIControlForegroundColor');

% adjust button height and width
btnMargin=1.4;
ExtControl=uicontrol(InputFig   ,BtnInfo     , ...
  'String'   ,'OK'        , ...
  'Visible'  ,'off'         ...
  );

% BtnYOffset  = DefOffset;
BtnExtent = get(ExtControl,'Extent');
BtnWidth  = max(DefBtnWidth,BtnExtent(3)+8);
BtnHeight = max(DefBtnHeight,BtnExtent(4)*btnMargin);
delete(ExtControl);

% Determine # of lines for all Prompts
TxtWidth=FigWidth-2*DefOffset;
ExtControl=uicontrol(InputFig   ,StInfo     , ...
  'String'   ,''         , ...
  'Position' ,[ DefOffset DefOffset 0.96*TxtWidth BtnHeight ] , ...
  'Visible'  ,'off'        ...
  );

WrapQuest=cell(NumQuest,1);
QuestPos=zeros(NumQuest,4);

for ExtLp=1:NumQuest
  if size(NumLines,2)==2
    [WrapQuest{ExtLp},QuestPos(ExtLp,1:4)]= ...
      textwrap(ExtControl,Prompt(ExtLp),NumLines(ExtLp,2));
  else
    [WrapQuest{ExtLp},QuestPos(ExtLp,1:4)]= ...
      textwrap(ExtControl,Prompt(ExtLp),80);
  end
end % for ExtLp

delete(ExtControl);
QuestWidth =QuestPos(:,3);
QuestHeight=QuestPos(:,4);

TxtHeight=QuestHeight(1)/size(WrapQuest{1,1},1);
EditHeight=TxtHeight*NumLines(:,1);
EditHeight(NumLines(:,1)==1)=EditHeight(NumLines(:,1)==1)+4;

FigHeight=(NumQuest+2)*DefOffset    + ...
  BtnHeight+sum(EditHeight) + ...
  sum(QuestHeight);

TxtXOffset=DefOffset;

QuestYOffset=zeros(NumQuest,1);
EditYOffset=zeros(NumQuest,1);
QuestYOffset(1)=FigHeight-DefOffset-QuestHeight(1);
EditYOffset(1)=QuestYOffset(1)-EditHeight(1);

for YOffLp=2:NumQuest,
  QuestYOffset(YOffLp)=EditYOffset(YOffLp-1)-QuestHeight(YOffLp)-DefOffset;
  EditYOffset(YOffLp)=QuestYOffset(YOffLp)-EditHeight(YOffLp);
end % for YOffLp

EditHandle  = zeros(NumQuest,1);
QuestHandle = zeros(NumQuest,1);

AxesHandle=axes('Parent',InputFig,'Position',[0 0 1 1],'Visible','off');

inputWidthSpecified = false;

for lp=1:NumQuest,
  if ~ischar(DefAns{lp}),
    delete(InputFig);
    error('MATLAB:inputdlg:InvalidInput', 'Default Answer must be a cell array of strings.');
  end

  EditHandle(lp)=uicontrol(InputFig    , ...
    EdInfo      , ...
    'Max'        ,NumLines(lp,1)       , ...
    'Position'   ,[ TxtXOffset EditYOffset(lp) TxtWidth EditHeight(lp) ], ...
    'String'     ,DefAns{lp}           , ...
    'Tag'        ,'Edit'                 ...
    );

  QuestHandle(lp)=text('Parent'     ,AxesHandle, ...
    TextInfo     , ...
    'Position'   ,[ TxtXOffset QuestYOffset(lp)], ...
    'String'     ,WrapQuest{lp}                 , ...
    'Interpreter',Interpreter                   , ...
    'Tag'        ,'Quest'                         ...
    );

  MinWidth = max(QuestWidth(:));
  if (size(NumLines,2) == 2)
    % input field width has been specified.
    inputWidthSpecified = true;
    EditWidth = setcolumnwidth(EditHandle(lp), NumLines(lp,1), NumLines(lp,2));
    MinWidth = max(MinWidth, EditWidth);
  end
  FigWidth=max(FigWidth, MinWidth+2*DefOffset);

end % for lp

% fig width may have changed, update the edit fields if they dont have user specified widths.
if ~inputWidthSpecified
  TxtWidth=FigWidth-2*DefOffset;
  for lp=1:NumQuest
    set(EditHandle(lp), 'Position', [TxtXOffset EditYOffset(lp) TxtWidth EditHeight(lp)]);
  end
end

FigPos=get(InputFig,'Position');

FigWidth=max(FigWidth,2*(BtnWidth+DefOffset)+DefOffset);
FigPos(1)=0;
FigPos(2)=0;
FigPos(3)=FigWidth;
FigPos(4)=FigHeight;

set(InputFig,'Position',getnicedialoglocation(FigPos,get(InputFig,'Units')));

OKHandle=uicontrol(InputFig     ,              ...
  BtnInfo      , ...
  'Position'   ,[ FigWidth-2*BtnWidth-2*DefOffset DefOffset BtnWidth BtnHeight ] , ...
  'KeyPressFcn',@doCallback , ...
  'String'     ,'OK'        , ...
  'Callback'   ,@doCallback , ...
  'Tag'        ,'OK'        , ...
  'UserData'   ,'OK'          ...
  );

setdefaultbutton(InputFig, OKHandle);

CancelHandle=uicontrol(InputFig     ,              ...
  BtnInfo      , ...
  'Position'   ,[ FigWidth-BtnWidth-DefOffset DefOffset BtnWidth BtnHeight ]           , ...
  'KeyPressFcn',@doCallback , ...
  'String'     ,'Cancel'    , ...
  'Callback'   ,@doCallback , ...
  'Tag'        ,'Cancel'    , ...
  'UserData'   ,'Cancel'      ...
  ); %#ok

handles = guihandles(InputFig);
handles.MinFigWidth = FigWidth;
handles.FigHeight   = FigHeight;
handles.TextMargin  = 2*DefOffset;
guidata(InputFig,handles);

% make sure we are on screen
movegui(InputFig)

% if there is a figure out there and it's modal, we need to be modal too
if ~isempty(gcbf) && strcmp(get(gcbf,'WindowStyle'),'modal')
  set(InputFig,'WindowStyle','modal');
end

set(InputFig,'Visible','on');
drawnow;

if ~isempty(EditHandle)
  uicontrol(EditHandle(1));
end

  function doFigureKeyPress(obj, evd) %#ok
    switch(evd.Key)
      case {'return','space'}
        Answer=cell(NumQuest,1);
        for n=1:NumQuest,
          Answer(n)=get(EditHandle(n),{'String'});
        end
        sendfeedbackHandle(Answer);
        delete(gcbf);
      case {'escape'}
        delete(gcbf);
    end
  end

  function doCallback(obj, evd) %#ok
    if ~strcmp(get(obj,'UserData'),'Cancel')
      Answer=cell(NumQuest,1);
      for n=1:NumQuest,
        Answer(n)=get(EditHandle(n),{'String'});
      end
      sendfeedbackHandle(Answer);
    end
    delete(gcbf)
  end
end

% set pixel width given the number of columns
function EditWidth = setcolumnwidth(object, rows, cols)
% Save current Units and String.
old_units = get(object, 'Units');
old_string = get(object, 'String');
old_position = get(object, 'Position');

set(object, 'Units', 'pixels')
set(object, 'String', char(ones(1,cols)*'x'));

new_extent = get(object,'Extent');
if (rows > 1)
  % For multiple rows, allow space for the scrollbar
  new_extent = new_extent + 19; % Width of the scrollbar
end
new_position = old_position;
new_position(3) = new_extent(3) + 1;
set(object, 'Position', new_position);

% reset string and units
set(object, 'String', old_string, 'Units', old_units);

EditWidth = new_extent(3);
end

function figure_size = getnicedialoglocation(figure_size, figure_units)

parentHandle = gcbf;
propName = 'Position';
if isempty(parentHandle)
  parentHandle = 0;
  propName = 'ScreenSize';
end

old_u = get(parentHandle,'Units');
set(parentHandle,'Units',figure_units);
container_size=get(parentHandle,propName);
set(parentHandle,'Units',old_u);

figure_size(1) = container_size(1)  + 1/2*(container_size(3) - figure_size(3));
figure_size(2) = container_size(2)  + 2/3*(container_size(4) - figure_size(4));
end

function setdefaultbutton(figHandle, btnHandle)

if isempty(get(figHandle, 'JavaFrame'))
  % We are running with Native Figures
  useHGDefaultButton(figHandle, btnHandle);
else
  % We are running with Java Figures
  useJavaDefaultButton(figHandle, btnHandle)
end

  function useJavaDefaultButton(figH, btnH)
    % Get a UDD handle for the figure.
    fh = handle(figH);
    % Call the setDefaultButton method on the figure handle
    fh.setDefaultButton(btnH);
  end

  function useHGDefaultButton(figHandle, btnHandle) %#ok
    % First get the position of the button.
    btnPos = getpixelposition(btnHandle);

    % Next calculate offsets.
    leftOffset   = btnPos(1) - 1;
    bottomOffset = btnPos(2) - 2;
    widthOffset  = btnPos(3) + 3;
    heightOffset = btnPos(4) + 3;

    % Create the default button look with a uipanel.
    % Use black border color even on Mac or Windows-XP (XP scheme) since
    % this is in natve figures which uses the Win2K style buttons on Windows
    % and Motif buttons on the Mac.
    h1 = uipanel(get(btnHandle, 'Parent'), 'HighlightColor', 'black', ...
      'BorderType', 'etchedout', 'units', 'pixels', ...
      'Position', [leftOffset bottomOffset widthOffset heightOffset]);

    % Make sure it is stacked on the bottom.
    uistack(h1, 'bottom');
  end
end
