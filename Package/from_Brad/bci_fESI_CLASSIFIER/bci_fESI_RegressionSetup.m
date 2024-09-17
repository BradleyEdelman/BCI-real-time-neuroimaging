function [hObject,handles]=bci_fESI_RegressionSetup(hObject,handles)

SetSystem=get(handles.SetSystem,'userdata');
set(hObject,'userdata',1);

if isequal(SetSystem,1)
    
    domain=get(handles.domain,'value');
    switch domain
        case 1 % None
            fprintf(2,'MUST SELECT A DOMAIN TO PERFORM REGRESSION\n');
            set(hObject,'backgroundcolor','red','userdata',0)
        case 2 % Sensor
            DomainField='RegressSensor';
        case 3 % ESI
            DomainField='RegressSource';
            if ~isequal(get(handles.SetESI,'userdata'),1)
                set(hObject,'backgroundcolor','red','userdata',0)
                fprintf(2,'MUST SET ESI PARAMATERS TO RUN REGRESSION IN SOURCE DOMAIN\n');
            end
    end
else
    set(hObject,'backgroundcolor','red','userdata',0)
    fprintf(2,'MUST SET SYSTEM PARAMATERS TO RUN REGRESSION\n');
end


set(hObject,'userdata',1)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% IDENTIFY TRAINING DATA PARAMETERS
% % FILE FORMAT AND CHECK FOR CONSISTENCY
trainfiles=cellstr(get(handles.trainfiles,'string'));
set(hObject,'backgroundcolor',[.94 .94 .94]);
set(handles.RegressFreq,'backgroundcolor','white','string','');

set(hObject,'userdata',1)
if isempty(trainfiles)
    fprintf(2,'NO TRAINING FILES UPLOADED - CANNOT PERFORM REGRESSION\n');
    set(hObject,'backgroundcolor','red','userdata',0)
else
    numfiles=size(trainfiles,1);
    % Extract training file name parts
    for i=1:numfiles
        [filepath{i},filename{i},fileext{i}]=fileparts(trainfiles{i});
    end

    % Check training file compatibility (either .dat or .mat)
    for i=1:numfiles
        if ~strcmp(fileext{i},'.dat') && ~strcmp(fileext{i},'.mat')
            fprintf(2,'TRAINING FILE %s NOT .Dat or .mat (%s)\n',num2str(i),fileext{i});
            set(hObject,'BackgroundColor','red','UserData',0);
        end
    end

    % Check training file consistency (all same file type)
    combinations=combnk(1:numfiles,2);
%     combinations=[1 2;1 3;1 4;2 3;2 4;3 4]
    for i=1:combinations
        if ~strcmp(fileext{combinations(i,1)},fileext{combinations(i,2)});
            fprintf(2,'INCONSISTENCY AMONG TRAINING FILE FORMAT\n');
            set(hObject,'BackgroundColor','red','UserData',0);
        end
    end
end

    
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% COPY FREQUENCY TRANSFORM PARAMETERS
PSD=handles.SYSTEM.psd;
switch PSD
    case 1 % None
    case 2 % Complex Morlet wavelet
        handles.(DomainField).mwparam=handles.SYSTEM.mwparam;
        handles.(DomainField).morwav=handles.SYSTEM.morwav;
    case 3 % Welch's PSD
%             handles.(DomainField).welchparam=...
    case 4 % DFT
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% IDENTIFY CHANNELS AND VERTICES INCLUDED/EXCLUDED IN ANALYSIS
handles.(DomainField).domain=domain;
switch domain
    case 1 % None
    case 2 % Sensor

        eLoc=handles.SYSTEM.Electrodes.current.eLoc;
        handles.(DomainField).eLoc=eLoc;

        ChanIdxInclude=handles.SYSTEM.Electrodes.chanidxinclude;
        ChanIdxExclude=handles.SYSTEM.Electrodes.chanidxexclude;
        handles.(DomainField).chanidxinclude=ChanIdxInclude;
        handles.(DomainField).chanidxexclude=ChanIdxExclude;

    case {3,4} % ESI

%             VertIdxInclude=handles.ESI.vertidxinclude;
        VertIdxInclude=horzcat(handles.ESI.clusters{1:end-1});
%             VertIdxExclude=handles.ESI.vertidxexclude;
        VertIdxExclude=handles.ESI.clusters{end};
        handles.(DomainField).vertidxinclude=VertIdxInclude;
        handles.(DomainField).vertidxexclude=VertIdxExclude;

end


if isequal(get(hObject,'userdata'),1)
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % LOAD DATA AND EXTRACT TIMING PARAMETERS
    trainfiles=cellstr(get(handles.trainfiles,'string'));
    handles.(DomainField).files.train=trainfiles;
    filetype=unique(fileext);
    handles.(DomainField).filetype=filetype;
    
    if strcmp(filetype,'.dat')

        [TrialStruct]=bci_fESI_ExtractBCI2000Parameters(trainfiles);
        [handles,TaskInfo,Data]=bci_fESI_TaskInfo(handles,trainfiles,TrialStruct);

        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%   
        % PROCESS DATA FOR TRAINING
        Data(handles.SYSTEM.Electrodes.chanidxexclude,:)=[];
        % Mean correct
        Data=Data-repmat(mean(Data,2),[1 size(Data,2)]);
        % Common average reference
        Data=Data-repmat(mean(Data,1),[size(Data,1),1]);
        % Bandpass filter
        a=handles.SYSTEM.filter.a;
        b=handles.SYSTEM.filter.b;
        Data=filtfilt(b,a,double(Data'));
        Data=Data';
            
    elseif strcmp(filetype,'.mat')
        
        [handles,TrialInfo]=bci_fESI_BCIESIExtractParamaters(handles,trainfiles);
        [handles,TaskInfo,Data]=bci_fESI_BCIESITaskInfo(handles,trainfiles,TrialInfo);
        TrialStruct=[];    
    end
    
    TargetTypes=unique(cell2mat(TaskInfo(2:end,2)));
    NumTask=size(TargetTypes,1);
    handles.(DomainField).NumTask=NumTask;    

    [hObject,handles]=bci_fESI_RegressionPerform(hObject,handles,TaskInfo,TrialStruct,Data);
    set(hObject,'backgroundcolor','green');

end
