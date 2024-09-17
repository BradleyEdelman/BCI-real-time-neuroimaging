function [hObject,handles]=bci_fESI_SelectSensors(hObject,handles)

set(hObject,'backgroundcolor',[.94 .94 .94]);

eegsystem=get(handles.eegsystem,'value');
if ~isequal(eegsystem,1)
    
    % Create figure
    handles.regionssensorfig=figure('MenuBar','none','ToolBar','none','color',[.94 .94 .94]);
    eLoc=handles.Electrodes.original.eLoc;
    NumSensor=size(eLoc,2);
    
    % Figure title
    txt1=uicontrol('style','text','string',...
            'Select sensors for training data','position',[105 395 350 25],'FontSize',13.5);
    
    % Close button
    btn1=uicontrol('style','pushbutton','string','Save & Close','position',...
        [10 10 125 20],'Callback',@myClose);
    
    % All electrodes
    btn2=uicontrol('style','pushbutton','string','All','position',...
        [200 10 50 20],'Callback',@myAll);
    
    % Minus outer rings
    btn3=uicontrol('style','pushbutton','string','Minus Rings','position',...
        [260 10 100 20],'Callback',@myMinusRings);
    
    % Motor parietal electrodes
    btn4=uicontrol('style','pushbutton','string','Motor Parietal',...
        'position',[370 10 100 20],'Callback',@myMotorParietal);
    
    % Motor electrodes
    btn5=uicontrol('style','pushbutton','string','Motor','position',...
        [480 10 100 20],'Callback',@myMotor);
    
    % Assign plotting axes
    handles.RegionsAxes=axes('Parent',handles.regionssensorfig,'Units','pixels',...
        'HandleVisibility','callback','position',[177.5+(ceil(size(eLoc,2)/20))*20 30 372.5 365]); axis off
    
    % Resize figure if needed
    Pos=get(handles.regionssensorfig,'position');
    Pos(3)=Pos(3)+(ceil(NumSensor/20))*20;
    set(handles.regionssensorfig,'position',Pos)

    % Plot all channels
    topoplot([],eLoc,'electrodes','ptlabels');
    set(handles.regionssensorfig,'color',[.94 .94 .94]);
    if isfield(handles,'regionssensor') && ~isempty(handles.regionssensor)
        handles.regionssensor.radio(NumSensor+1:end)=[];
    end
    
    for i=1:NumSensor

        if i<=20; x=15;
        elseif i>20 && i<=40; x=60;
        elseif i>40 && i<=60; x=105;
        elseif i>60 && i<=80; x=155;
        elseif i>80 && i<=100; x=200;
        elseif i>100 && i<=120; x=245;
        elseif i>120; x=290;
        end

        y=rem(i,20);
        if y==0; y=20; end

        handles.regionssensor.radio(i)=uicontrol('Style','radiobutton','Callback',...
        @myRadio,'Units','pixels','position',[x,395-y*17.5,50,20],...
        'string',eLoc(i).labels,'value',1,'FontSize',9);
        
    end
    
    % Check if sensors have already been selected - if so, plot
    if isequal(size(get(hObject,'userdata'),1),NumSensor) && ~isequal(get(hObject,'userdata'),zeros(NumSensor,1))
        OldRadioVal=get(hObject,'userdata');
        for i=1:size(get(hObject,'userdata'),1)
            set(handles.regionssensor.radio(i),'value',OldRadioVal(i));
        end
        
        j=1; eLoctmp=eLoc(1);
        for i=1:size(OldRadioVal,1)
            if isequal(OldRadioVal(i),1)
                eLoctmp(j)=eLoc(i);
                j=j+1;
            end
        end
        cla
        topoplot([],eLoctmp,'electrodes','ptlabels');
        set(handles.regionssensorfig,'color',[.94 .94 .94]);
    end

    guidata(handles.regionssensorfig,handles)
    
else
    fprintf(2,'MUST SELECT AN EEG SYSTEM TO SELECT CHANNELS\n');
end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% HELPER FUNCTIONS
function myClose(CloseH,EventData)
handles=guidata(CloseH);
set(handles.selectsensors,'userdata',cell2mat(get(handles.regionssensor.radio,'value')))
close(handles.regionssensorfig)



function myRadio(RadioH,EventData)
handles=guidata(RadioH);

if isfield(handles,'Electrodes') &&...
        isfield(handles.Electrodes,'current') &&...
        ~isempty(handles.Electrodes.current)
    set(handles.regionssensorfig,'MenuBar','none','ToolBar','none','color',[.94 .94 .94])
    eLoc=handles.Electrodes.current.eLoc; Plot=1;
else
    fprintf(2,'MUST SELECT AN EEG SYSTEM TO SELECT CHANNELS\n'); 
end

if isequal(Plot,1)
    RegionOnOff=cell2mat(get(handles.regionssensor.radio,'value'));
    
    j=1; eLoctmp=eLoc(1);
    for i=1:size(RegionOnOff,1)
        if isequal(RegionOnOff(i),1)
            eLoctmp(j)=eLoc(i);
            j=j+1;
        end
    end
    
    cla
    topoplot([],eLoctmp,'electrodes','ptlabels','emarker',{'.','k',[],1});
    set(handles.regionssensorfig,'color',[.94 .94 .94]);
end
set(handles.selectsensors,'userdata',cell2mat(get(handles.regionssensor.radio,'value')))
guidata(RadioH,handles);



function myAll(AllH,EventData)
handles=guidata(AllH);

eLoc=handles.Electrodes.original.eLoc;
for i=1:size(eLoc,2)
    set(handles.regionssensor.radio(i),'value',1);
end

cla
topoplot([],eLoc,'electrodes','ptlabels','emarker',{'.','k',[],1});
set(handles.regionssensorfig,'color',[.94 .94 .94]);
set(handles.selectsensors,'userdata',cell2mat(get(handles.regionssensor.radio,'value')))
guidata(AllH,handles);



function myMinusRings(MinusH,EventData)
handles=guidata(MinusH);

eLoc=handles.Electrodes.original.eLoc;

eegsystem=get(handles.eegsystem,'value');
switch eegsystem
    case 1 % None
    case 2 % Neuroscan 64
        AutoRemove=[];
    case 3 % Neuroscan 128
        AutoRemove=[];
    case 4 % BioSemi 64
        AutoRemove=[1:2,7:8,15:16,23:25,27:29,33:35,42:43,52:53,60:62,64];
    case 5 % BioSemi 128
        AutoRemove=[11:14,24:27,40:43,46:47,57:60,70:73,79:82,92:95,...
            102:105,118:121,127:128];
    case 6 % Signal Generator
        AutoRemove=[];
end

for i=1:size(eLoc,2)
    set(handles.regionssensor.radio(i),'value',1);
end

for i=1:size(AutoRemove,2)
    set(handles.regionssensor.radio(AutoRemove(i)),'value',0);
end
eLoctmp=eLoc;
eLoctmp(AutoRemove)=[];

cla
topoplot([],eLoctmp,'electrodes','ptlabels','emarker',{'.','k',[],1});
set(handles.regionssensorfig,'color',[.94 .94 .94]);
set(handles.selectsensors,'userdata',cell2mat(get(handles.regionssensor.radio,'value')))
guidata(MinusH,handles);



function myMotorParietal(MotorParietalH,EventData)
handles=guidata(MotorParietalH);

eLoc=handles.Electrodes.original.eLoc;

eegsystem=get(handles.eegsystem,'value');
switch eegsystem
    case 1 % None
    case 2 % Neuroscan 64
        AutoRemove=[];
    case 3 % Neuroscan 128
        AutoRemove=[];
    case 4 % BioSemi 64
        AutoRemove=[1:3,6:8,15:16,22:30,33:37,41:43,52:53,59:64];
    case 5 % BioSemi 128
        AutoRemove=[8:17,21:30,37:47,57:60,68:74,77:84,90:96,100:105,...
            118:121,125:128];
    case 6 % Signal Generator
        AutoRemove=[];
end

for i=1:size(eLoc,2)
    set(handles.regionssensor.radio(i),'value',1);
end

for i=1:size(AutoRemove,2)
    set(handles.regionssensor.radio(AutoRemove(i)),'value',0);
end
eLoctmp=eLoc;
eLoctmp(AutoRemove)=[];

cla
topoplot([],eLoctmp,'electrodes','ptlabels','emarker',{'.','k',[],1});
set(handles.regionssensorfig,'color',[.94 .94 .94]);
set(handles.selectsensors,'userdata',cell2mat(get(handles.regionssensor.radio,'value')))
guidata(MotorParietalH,handles);


function myMotor(MotorH,EventData)
handles=guidata(MotorH);

eLoc=handles.Electrodes.original.eLoc;

eegsystem=get(handles.eegsystem,'value');
switch eegsystem
    case 1 % None
    case 2 % Neuroscan 64
        AutoRemove=[];
    case 3 % Neuroscan 128
        AutoRemove=[];
    case 4 % BioSemi 64
        AutoRemove=[1:8,15:16,20:31,33:43,52:53,57:64];
    case 5 % BioSemi 128
        AutoRemove=[7:18,20:31,36:47,57:60,67:74,76:85,89:96,99:105,...
            118:121,125:128];
    case 6 % Signal Generator
        AutoRemove=[];
end

for i=1:size(eLoc,2)
    set(handles.regionssensor.radio(i),'value',1);
end

for i=1:size(AutoRemove,2)
    set(handles.regionssensor.radio(AutoRemove(i)),'value',0);
end
eLoctmp=eLoc;
eLoctmp(AutoRemove)=[];

cla
topoplot([],eLoctmp,'electrodes','ptlabels','emarker',{'.','k',[],1});
set(handles.regionssensorfig,'color',[.94 .94 .94]);
set(handles.selectsensors,'userdata',cell2mat(get(handles.regionssensor.radio,'value')))
guidata(MotorH,handles);




