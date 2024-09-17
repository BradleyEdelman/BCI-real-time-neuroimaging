function [hObject,handles]=bci_fESI_BCISelectLoc(hObject,handles,Dimension)

set(hObject,'backgroundcolor',[.94 .94 .94])

Go=1;
% Specify handle in which to store the locations and weights
handles.BCILoc.CurrentObj=strcat('bciloc',num2str(Dimension));

% Extract frequency of interest
dimfreq=strcat('bcifreq',num2str(Dimension));
freqval=get(handles.(dimfreq),'value');
if isequal(freqval,1)
    Go=0;
end
freqnd=freqval-1;

% Extract task of interest
dimtask=strcat('bcitask',num2str(Dimension));
taskoptions=cellstr(get(handles.(dimtask),'String'));
taskval=get(handles.(dimtask),'value');
if isequal(taskval,1) 
    Go=0;
end

% Extract movement direction of interest
dimmove=strcat('bcidim',num2str(Dimension));
moveoptions=cellstr(get(handles.(dimmove),'String'));
moveval=get(handles.(dimmove),'value');
movetype=moveoptions{moveval};
if isequal(moveval,1)
    Go=0;
end

if isequal(Go,1)

    taskname=taskoptions{taskval};
    taskidx=str2double(regexp(taskname,'\d+','match'));

    domain=get(handles.domain,'value');
    switch domain
        case 1 % None
        case 2 % Sensor
            
            if isfield(handles,'RegressSensor') && isfield(handles.RegressSensor,'sensorfile') &&...
                    ~isempty(handles.RegressSensor.sensorfile)
            
                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                % LOAD ONE-VS-ONE REGRESSION RESULTS FILE
                load(handles.RegressSensor.sensorfile{2}) 

                for i=1:size(handles.RegressSensor.sensorlabel{2},1)
                    if isequal(taskidx,str2num(handles.RegressSensor.sensorlabel{2}(i,:)))
                        taskidx=i;
                    end
                end
                
                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                % STEPWISE LINEAR REGRESSION FOR AUTOMATIC CHANNEL SELECTION
                TrialData=SaveRegressSensor.totdata(freqnd).trialdata;
                Comb=SaveRegressSensor.comb(taskidx,:);
                
                if iscell(TrialData{Comb(1)}') && iscell(TrialData{Comb(2)}')
                    Class1=horzcat(TrialData{Comb(1)}{:})';
                    Class2=horzcat(TrialData{Comb(2)}{:})';
                else
                    Class1=TrialData{Comb(1)}';
                    Class2=TrialData{Comb(2)}';
                end
                X=[Class1;Class2];
                Y=[ones(size(Class1,1),1);-1*ones(size(Class2,1),1)];
                [B,SE,PVAL,INMODEL,STATS,NEXTSTEP,HISTORY]=stepwisefit(X,Y,'penter',.01,'premove',.01);
                Include=find(INMODEL==1);
                if ~isempty(Include)
                    for i=1:size(Include,2)
                        if B(Include(i))>0
                            DataStep(i,:)=[Include(i) 1];
                        else
                            DataStep(i,:)=[Include(i) -1];
                        end
                    end
                end
                
                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                % SAVE BCI PARAMETERS
                handles.BCILoc.TaskInd=taskidx;
                handles.BCILoc.FreqInd=freqnd;
                handles.BCILoc.Rsensor=SaveRegressSensor.R(:,freqnd,taskidx);
                handles.BCILoc.MoveType=movetype;
                
                for i=1:size(handles.BCILoc.Rsensor,1)
                    num{i}=i;
                end
                
                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                % CREATE CHANNEL SELECTION FIGURE
                handles.BCILocFig=figure;
                set(handles.BCILocFig,'MenuBar','none','ToolBar','none','color',[.94 .94 .94]);
                rotate3d on

                % plotting axes
                handles.BCILocAxes=axes('Parent',handles.BCILocFig,'Units','pixels',...
                'HandleVisibility','callback','Position',[10 25 350 370]);
                
                % list of available channels
                handles.list1=uicontrol('Parent',handles.BCILocFig, 'style','listbox','String',...
                    num','Position',[455 195 50 200],'FontSize',9,'Min',1,'Max',size(num,2));
                
                text1=uicontrol('style','text','String',...
                    'Channels','Position',[430 395 100 20],'FontSize',10);
                
                text2=uicontrol('style','text','String',...
                    'Select Channels for BCI','Position',[110 395 340 25],'FontSize',13.5);
                
                % add channels to list button
                btn2=uicontrol('style','pushbutton','String','Add','Position',...
                    [400 165 75 20],'Callback',@myAddSensor);
                
                % remove channels from list button
                btn3=uicontrol('style','pushbutton','String','Remove','Position',...
                    [480 165 75 20],'Callback',@myRemoveSensor);
                
                % save selection and close figure
                btn4=uicontrol('style','pushbutton','String','Save & Close','Position',...
                    [10 10 115 20],'Callback','close');
                
                % select default channels for specific dimensional control
                btn5=uicontrol('style','pushbutton','String','Default Loc/Weight','Position',...
                    [135 10 130 20],'Callback',@myDefaultSensor);
                
                % invert weights if regression tasks switched
                handles.radio=uicontrol('style','radiobutton','String','Invert Weights','Position',...
                    [275 10 105 20],'Callback',@mySensorInvertWeights);
                
                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                % CHECK FOR PREVIOUSLY SAVED CHANNEL SELECTION
                if ~isempty(get(handles.(handles.BCILoc.CurrentObj),'UserData')) ||...
                        isequal(get(handles.(handles.BCILoc.CurrentObj),'UserData'),0)
                    
                    % USE PREVIOUS SELECTION IF AVAILABLE
                    Data=get(handles.(handles.BCILoc.CurrentObj),'UserData');
                    invert=Data(end,1);
                    
                elseif exist('DataStep','var') && ~isempty(DataStep)
                    
                    % USE RESULTS OF STEPWISE LINEAR REGRESSION IF NO PREVIOUS SELECTION
                    Data=DataStep;
                    invert=0;
                    Data(end+1,:)=0;
                    
                else
                    invert=0;
                    Data=[];
                end
                
                % ADD CHANNEL AND WEIGHT SELECTION TO DATA TABLE
                handles.table1=uitable('Data',Data(1:end-1,:),'ColumnName',{'Channel' 'Weight'},'Position',...
                    [400 10 155 150],'ColumnWidth',{50 50});
                
                Rsensor=handles.BCILoc.Rsensor;
                if isequal(invert,1)
                    Rsensor=-1*Rsensor;
                    set(handles.radio,'value',1);
                end
                topoplot(Rsensor,handles.SYSTEM.Electrodes.current.eLoc,'electrodes','numbers','numcontour',0);
                view(0,90); axis xy; rotate3d off;
                set(gcf,'color',[.94 .94 .94]); colorbar; caxis auto;
                caxis([-max(abs(Rsensor)) max(abs(Rsensor))]);
                
                CurrentObj=handles.BCILoc.CurrentObj;
                set(handles.(CurrentObj),'UserData',Data)
                guidata(handles.BCILocFig,handles);
                
            else
                fprintf(2,'MUST PERFORM REGRESSION IN SENSOR DOMAIN IN ORDER TO SET UP SENSOR-BASED BCI\n');
            end



        case 3 % ESI
            
            if isfield(handles,'RegressSource') && isfield(handles.RegressSource,'sourcefile') &&...
                    ~isempty(handles.RegressSource.sourcefile)
            
                load(handles.RegressSource.sourcefile{2}) % Load one-vs-one regress file
                
                for i=1:size(handles.RegressSource.sourcelabel{2},1)
                    if isequal(taskidx,str2num(handles.RegressSource.sourcelabel{2}(i,:)))
                        taskidx=i;
                    end
                end
                
                handles.BCILoc.TaskInd=taskidx;
                handles.BCILoc.FreqInd=freqnd;
                handles.BCILoc.Rcluster=SaveRegressSource.cluster.R(:,freqnd,taskidx);
                handles.BCILoc.MoveType=movetype;
                Rtmp=SaveRegressSource.cluster.R(:,freqnd,taskidx);
                
                TrialData=SaveRegressSource.cluster.totdata(freqnd).trialdata;
                Comb=SaveRegressSource.comb(taskidx,:);
                X=[TrialData{Comb(1)}';TrialData{Comb(2)}'];
                Y=[ones(size(TrialData{Comb(1)},2),1);-1*ones(size(TrialData{Comb(2)},2),1)];
                [B,SE,PVAL,INMODEL,STATS,NEXTSTEP,HISTORY]=stepwisefit(X,Y,'penter',.01,'premove',.01);
                Include=find(INMODEL==1);
                if ~isempty(Include)
                    for i=1:size(Include,2)
                        if B(Include(i))>0
                            DataStep(i,:)=[Include(i) 1];
                        else
                            DataStep(i,:)=[Include(i) -1];
                        end
                    end
                end
                
                Cortex=handles.ESI.cortex;
                R=zeros(1,size(Cortex.Vertices,1));
                clusters=handles.ESI.clusters;
                j=1;
                for i=1:size(Include,2)
                    R(clusters{Include(i)})=repmat(SaveRegressSource.cluster.R(Include(i),freqnd,taskidx),[1 size(clusters{Include(i)},2)]);
                    j=j+1;
                end
                
%                 R=zeros(1,size(Cortex.Vertices,1));
                clusters=handles.ESI.clusters;
                j=1;
                for i=1:size(clusters,2)-1
                    if abs(Rtmp(i))>.0*max(abs(Rtmp))
%                         R(clusters{i})=repmat(SaveRegressSource.cluster.R(i,freqnd,taskidx),[1 size(clusters{i},2)]);
                        num{j}=i;
                        j=j+1;
                    end
                end
                handles.BCILoc.clusteroptions=cell2mat(num);
                
                handles.BCILocFig=figure;
                set(handles.BCILocFig,'MenuBar','none','ToolBar','none','color',[.94 .94 .94]);
                rotate3d on

                % Assigned plotting axes
                handles.BCILocAxes=axes('Parent',handles.BCILocFig,'Units','pixels',...
                'HandleVisibility','callback','Position',[10 25 350 370]);
            
                handles.list1=uicontrol('Parent',handles.BCILocFig, 'style','listbox','String',...
                    num','Position',[455 235 50 160],'FontSize',9,'Min',1,'Max',size(clusters,2)-1);
                
                text1=uicontrol('style','text','String',...
                    'Clusters','Position',[430 395 100 20],'FontSize',10);
                
                text2=uicontrol('style','text','String',...
                    'Select Clusters for BCI','Position',[110 395 340 25],'FontSize',13.5);
                
                btn1=uicontrol('style','pushbutton','String','Show','Position',...
                    [440 200 75 20],'Callback',@myShow);
                
                btn2=uicontrol('style','pushbutton','String','Add','Position',...
                    [400 165 75 20],'Callback',@myAddSource);
                
                btn3=uicontrol('style','pushbutton','String','Remove','Position',...
                    [480 165 75 20],'Callback',@myRemoveSource);
                
                btn4=uicontrol('style','pushbutton','String','Save & Close','Position',...
                    [10 10 115 20],'Callback','close');
                
                btn5=uicontrol('style','pushbutton','String','Default Loc/Weight','Position',...
                    [135 10 130 20],'Callback',@myDefaultSource);
                
                handles.radio=uicontrol('style','radiobutton','String','Invert Weights','Position',...
                    [275 10 105 20],'Callback',@mySourceInvertWeights);
                
                if ~isempty(get(handles.(handles.BCILoc.CurrentObj),'UserData')) ||...
                        isequal(get(handles.(handles.BCILoc.CurrentObj),'UserData'),0)
                    
                    Data=get(handles.(handles.BCILoc.CurrentObj),'UserData');
                    
                    R=zeros(1,size(Cortex.Vertices,1));
                    for i=1:size(Data,1)-1
                        R(clusters{Data(i,1)})=repmat(Data(i,2),[1 size(clusters{Data(i,1)},2)]);
                    end
                    invert=Data(end,1);
                    
                elseif exist('DataStep','var') && ~isempty(DataStep)
                    
                    Data=DataStep;
                    invert=0;
                    Data(end+1,:)=0;
                    
                else
                    invert=0;
                    Data=[];
                end
                handles.table1=uitable('Data',Data(1:end-1,:),'ColumnName',{'Cluster' 'Weight'},'Position',...
                    [400 10 155 150],'ColumnWidth',{50 50});
                
                if isequal(invert,1)
                    set(handles.radio,'value',1)
                end
                
                h=trisurf(Cortex.Faces,Cortex.Vertices(:,1),...
                    Cortex.Vertices(:,2),Cortex.Vertices(:,3),R);
                set(h,'FaceColor','interp','EdgeColor','None','FaceLighting','gouraud');
                axis equal; axis off; view(-90,90); caxis auto; rotate3d on;
                light; h2=light; lightangle(h2,90,-90); h3=light;lightangle(h3,-90,30);
                cmap=jet(128); cmap(63:65,:)=repmat([.85 .85 .85],[3 1]); colormap(cmap)
                colorbar; caxis auto; caxis([-max(abs(R)) max(abs(R))]);
                
                CurrentObj=handles.BCILoc.CurrentObj;
                set(handles.(CurrentObj),'UserData',Data)
                guidata(handles.BCILocFig,handles);
                
            else 
                fprintf(2,'MUST PERFORM REGRESSION IN SOURCE DOMAIN IN ORDER TO SET UP SOURCE-BASED BCI\n');
            end
    end
else
    fprintf(2,'MUST SELECT BOTH A TASK AND FREQUENCY BEFORE CHOOSING LOCATIONS\n');
end



function myShow(ShowH,EventData)
handles=guidata(ShowH);
cla
Cortex=handles.ESI.cortex;
% Cortex=load('M:\brainstorm_db\bci_fESI\anat\BE\tess_cortex_pial_low_fig.mat');
clusters=handles.ESI.clusters;
Rcluster=handles.BCILoc.Rcluster;
ClusterOptions=handles.BCILoc.clusteroptions;

Select=get(handles.list1,'value');
Select=ClusterOptions(Select);
R=zeros(1,size(Cortex.Vertices,1));
for i=1:size(Select,2)
	R(clusters{Select(i)})=repmat(Rcluster(Select(i)),[1 size(clusters{Select(i)},2)]);
end
h=trisurf(Cortex.Faces,Cortex.Vertices(:,1),...
	Cortex.Vertices(:,2),Cortex.Vertices(:,3),R);
set(h,'FaceColor','interp','EdgeColor','None','FaceLighting','gouraud');
axis equal; axis off; view(-90,90); caxis auto; rotate3d on;
light; h2=light; lightangle(h2,90,-90); h3=light;lightangle(h3,-90,30);
cmap=jet(128); cmap(64,:)=repmat([.85 .85 .85],[1 1]); colormap(cmap)
colorbar; caxis auto; caxis([-max(abs(Rcluster(:))) max(abs(Rcluster(:)))]);

function myAddSource(AddH,EventData)
handles=guidata(AddH);

Rcluster=handles.BCILoc.Rcluster;
ClusterOptions=handles.BCILoc.clusteroptions;
Select=get(handles.list1,'value');
Select=ClusterOptions(Select);

Data=get(handles.table1,'Data');
Chan=Data(:,1);
Weights=Data(:,2);

if ~isempty(Data)
    Clusters=Data(:,1);
    Clusters(Clusters==0)=[];
    Clusters=[Clusters;Select(:)];
    UniqueClusters=unique(Clusters);
else
    UniqueClusters=Select(:);
end

clear Data
invert=get(handles.radio,'value');
Data(:,1)=UniqueClusters;
for i=1:size(Data,1)
    if ismember(Data(i,1),Chan)
        idx=find(Chan==Data(i,1));
        Data(i,2)=Weights(idx);
    else
        
        if Rcluster(Data(i,1))>0
            Data(i,2)=1;
        else
            Data(i,2)=-1;
        end
        
        if isequal(invert,1)
            Data(i,2)=-Data(i,2);
        end
        
    end
end


% if isequal(invert,1)
%     Data(:,2)=-1*Data(:,2);
% end
set(handles.table1,'Data',Data)
Data(end+1,:)=invert;

CurrentObj=handles.BCILoc.CurrentObj;
set(handles.(CurrentObj),'UserData',Data)

function myAddSensor(AddH,EventData)
handles=guidata(AddH);

Rsensor=handles.BCILoc.Rsensor;

Select=get(handles.list1,'value');
Data=get(handles.table1,'Data');

if ~isempty(Data)
    Sensors=Data(:,1);
    Sensors(Sensors==0)=[];
    Sensors=[Sensors;Select(:)];
    UniqueSensors=unique(Sensors);
else
    UniqueSensors=Select(:);
end
    
clear Data
Data(:,1)=UniqueSensors;
for i=1:size(Data,1)
    if Rsensor(Data(i,1))>0
        Data(i,2)=1;
    else
        Data(i,2)=-1;
    end
end

invert=get(handles.radio,'value');
if isequal(invert,1)
    Data(:,2)=-1*Data(:,2);
end
set(handles.table1,'Data',Data)
Data(end+1,:)=invert;

CurrentObj=handles.BCILoc.CurrentObj;
set(handles.(CurrentObj),'UserData',Data)


function myRemoveSource(RemoveH,EventData)
handles=guidata(RemoveH);
ClusterOptions=handles.BCILoc.clusteroptions;
Data=get(handles.table1,'Data');
Available=(Data(:,1));

Remove=ClusterOptions(get(handles.list1,'value'));
for i=size(Remove,2):-1:1
    if ismember(Remove(i),Available)
        Data(Available==Remove(i),:)=[];
    end
end
set(handles.table1,'Data',Data)

invert=get(handles.radio,'value');
Data(end+1,:)=invert;

CurrentObj=handles.BCILoc.CurrentObj;
set(handles.(CurrentObj),'UserData',Data)


function myRemoveSensor(RemoveH,EventData)
handles=guidata(RemoveH);
Data=get(handles.table1,'Data');
Available=Data(:,1);

Remove=get(handles.list1,'value');
for i=size(Remove,2):-1:1
    if ismember(Remove(i),Available)
        Data(Available==Remove(i),:)=[];
    end
end
set(handles.table1,'Data',Data)

invert=get(handles.radio,'value');
Data(end+1,:)=invert;

CurrentObj=handles.BCILoc.CurrentObj;
set(handles.(CurrentObj),'UserData',Data)


function myDefaultSource(DefaultH,EventData)
handles=guidata(DefaultH);
movetype=handles.BCILoc.MoveType;

% Check for subject specific hand knob seed vertices
rootdir=handles.SYSTEM.rootdir;
SeedFile=[];
DefaultAnatomy=get(handles.DefaultAnatomy,'value');
if isequal(DefaultAnatomy,1)
    SeedFile=strcat(rootdir,'\from_Brad\bci_fESI_Default_Anatomy\Default_Hand_Knob_Seeds.mat');
else
    Subj=handles.SYSTEM.initials;
    BrainFolder=strcat(rootdir,'\BCI_ready_files\',Subj);
    
    if ~exist(BrainFolder,'dir')
        fprintf(2,'\nSUBJECT SPECIFIC ANATOMY FOLDER DOES NOT EXIST IN ROOT DIRECTORY\n');
    else
        SubjSeedFile=strcat(BrainFolder,'\',Subj,'_Hand_Knob_Seeds.mat');
        if ~exist(SubjSeedFile,'file')
            fprintf(2,'SUBJECT SPECIFIC HAND KNOB SEED FILE DOES NOT EXIST IN SUBJECT DIRECTORY\n');
        else
            SeedFile=SubjSeedFile;
        end
    end
end
    
if ~isempty(SeedFile)
    Seeds=load(SeedFile);
    SeedLabels={Seeds.Scouts.Label};
    SeedVert={Seeds.Scouts.Vertices};
    
    parcellation=get(handles.parcellation,'value');
    if isequal(parcellation,3)
        
        clusters=handles.ESI.clusters;
        Data=zeros(2,2);
        idx=1; lidx=[]; ridx=[];
        for i=1:size(SeedVert,2)

            for j=1:size(SeedVert{i},2)
                for k=1:size(clusters,2)-1

                    if ismember(SeedVert{i}(j),clusters{k})
                        
                        if ~isempty(strfind(SeedLabels{i},'L')) ||...
                                ~isempty(strfind(SeedLabels{i},'Left'))

                            if ~ismember(Data(:,1),k)
                                Data(idx,1)=k;
                                lidx=[lidx idx];
                                idx=idx+1;
                            end

                        elseif ~isempty(strfind(SeedLabels{i},'R')) ||...
                                ~isempty(strfind(SeedLabels{i},'Right'))

                            if ~ismember(Data(:,1),k)
                                Data(idx,1)=k;
                                ridx=[ridx idx];
                                idx=idx+1;
                            end

                        end

                    end
                end
            end

        end

        if strcmp(movetype,'Horizontal')
            Data(lidx,2)=-1;
            Data(ridx,2)=1;
        elseif strcmp(movetype,'Vertical')
            Data(lidx,2)=-1;
            Data(ridx,2)=-1;
        elseif strcmp(movetype,'Depth')
        end

        [X,I]=sort(Data(:,1),'ascend');
        Data(:,1)=Data(I,1);
        Data(:,2)=Data(I,2);

        set(handles.table1,'Data',Data)

        cla
        Cortex=handles.ESI.cortex;

        R=zeros(1,size(Cortex.Vertices,1));
        for i=1:size(Data,1)
            R(clusters{Data(i,1)})=repmat(Data(i,2),[1 size(clusters{Data(i,1)},2)]);
        end
        h=trisurf(Cortex.Faces,Cortex.Vertices(:,1),...
            Cortex.Vertices(:,2),Cortex.Vertices(:,3),R);
        set(h,'FaceColor','interp','EdgeColor','None','FaceLighting','gouraud');
        axis equal; axis off; view(-90,90); caxis auto; rotate3d on;
        light; h2=light; lightangle(h2,90,-90); h3=light;lightangle(h3,-90,30);
        cmap=jet(128); cmap(63:65,:)=repmat([.85 .85 .85],[3 1]); colormap(cmap)
        colorbar; caxis auto; caxis([-max(abs(R(:))) max(abs(R(:)))]);
        
        set(handles.radio,'value',0);
        Data(end+1,:)=0;
        
        CurrentObj=handles.BCILoc.CurrentObj;
        set(handles.(CurrentObj),'UserData',Data)
        
    end
    
end


function myDefaultSensor(DefaultH,EventData)
handles=guidata(DefaultH);
movetype=handles.BCILoc.MoveType;

elabel={handles.RegressSensor.eLoc.labels};
eegsystem=handles.SYSTEM.eegsystem;
switch eegsystem
    case 1 % None
    case 2 % NSL 64
        C3=find(strcmp(elabel,'C3'));
        C4=find(strcmp(elabel,'C4'));
    case 3 % NSL 128
    case 4 % BS 64
        C3=find(strcmp(elabel,'A13'));
        C4=find(strcmp(elabel,'B19'));
    case 5 % BS 128
        C3=find(strcmp(elabel,'D19'));
        C4=find(strcmp(elabel,'B22'));
    case 6 % SG 16
        C3=find(strcmp(elabel,'C3'));
        C4=find(strcmp(elabel,'C4'));
end
% 
% C3=find(strcmp(elabel,'D19'));
% C4=find(strcmp(elabel,'B22'));

Data=zeros(2,2);
Data(1,1)=C3;
Data(2,1)=C4;

if strcmp(movetype,'Horizontal')
    
    Data(1,2)=-1;
    Data(2,2)=1;
    
elseif strcmp(movetype,'Vertical')
    
    Data(1,2)=-1;
    Data(2,2)=-1;
    
elseif strcmp(movetype,'Depth')
    
end
set(handles.table1,'Data',Data)

cla
Rsensor=handles.BCILoc.Rsensor;
topoplot(Rsensor,handles.SYSTEM.Electrodes.current.eLoc,'electrodes','numbers','numcontour',0);
view(0,90); axis xy; rotate3d off;
set(gcf,'color',[.94 .94 .94]); colorbar;
caxis([-max(abs(Rsensor)) max(abs(Rsensor))]);

set(handles.radio,'value',0);
Data(end+1,:)=0;

CurrentObj=handles.BCILoc.CurrentObj;
set(handles.(CurrentObj),'UserData',Data)


function mySensorInvertWeights(SensorInvertH,EventData)
handles=guidata(SensorInvertH);
invert=get(SensorInvertH,'value');

Data=get(handles.table1,'Data');
Data(:,2)=-1*Data(:,2);
set(handles.table1,'Data',Data);

Rsensor=handles.BCILoc.Rsensor;

CurrentObj=handles.BCILoc.CurrentObj;
if isequal(invert,1)
    Rsensor=-1*Rsensor;
    set(handles.(CurrentObj),'value',1);
    Data(end+1,:)=1;
else
    set(handles.(CurrentObj),'value',0);
    Data(end+1,:)=0;
end

cla
topoplot(Rsensor,handles.SYSTEM.Electrodes.current.eLoc,'electrodes','numbers','numcontour',0);
handles.BCILoc.Rsensor=Rsensor;
view(0,90); axis xy; rotate3d off;
set(gcf,'color',[.94 .94 .94]); colorbar;
caxis([-max(abs(Rsensor)) max(abs(Rsensor))]);

set(handles.(CurrentObj),'UserData',Data);


function mySourceInvertWeights(SourceInvertH,EventData)
handles=guidata(SourceInvertH);
invert=get(SourceInvertH,'value');

Data=get(handles.table1,'Data');
Data(:,2)=-1*Data(:,2);
set(handles.table1,'Data',Data);

cla
Cortex=handles.ESI.cortex;
clusters=handles.ESI.clusters;

R=zeros(1,size(Cortex.Vertices,1));
for i=1:size(Data,1)
    R(clusters{Data(i,1)})=repmat(Data(i,2),[1 size(clusters{Data(i,1)},2)]);
end

CurrentObj=handles.BCILoc.CurrentObj;
if isequal(invert,1)
    set(handles.(CurrentObj),'value',1);
    Data(end+1,:)=1;
else
    set(handles.(CurrentObj),'value',0);
    Data(end+1,:)=0;
end

h=trisurf(Cortex.Faces,Cortex.Vertices(:,1),...
    Cortex.Vertices(:,2),Cortex.Vertices(:,3),R);
set(h,'FaceColor','interp','EdgeColor','None','FaceLighting','gouraud');
axis equal; axis off; view(-90,90); caxis auto; rotate3d on;
light; h2=light; lightangle(h2,90,-90); h3=light;lightangle(h3,-90,30);
cmap=jet(128); cmap(63:65,:)=repmat([.85 .85 .85],[3 1]); colormap(cmap)
colorbar; caxis auto; caxis([-max(abs(R(:))) max(abs(R(:)))]);

set(handles.(CurrentObj),'UserData',Data);











