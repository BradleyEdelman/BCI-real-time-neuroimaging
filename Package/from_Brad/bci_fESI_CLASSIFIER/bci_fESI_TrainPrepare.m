function [hObject,handles]=bci_fESI_TrainPrepare(hObject,handles)

set(handles.Train,'BackgroundColor',[.94 .94 .94]);
set(hObject,'BackgroundColor','green');
set(hObject,'UserData',1);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% IDENTIFY TRAINING PARAMETERS
% % FILE FORMAT AND CHECK FOR CONSISTENCY
TrainDataFormat=get(handles.TrainDataFormat,'value');
TrainFiles=cellstr(get(handles.TrainData,'String'));
if isempty(TrainFiles)
    fprintf(2,'NO TRAINING FILES UPLOADED - CANNOT TRAIN CLASSIFIER\n');
    set(hObject,'BackgroundColor','red')
    set(hObject,'UserData',2);
else
    switch TrainDataFormat
        case 1 % None
            fprintf(2,'MUST SELECT A TRAINING DATA FORMAT\n');
            set(hObject,'BackgroundColor','red')
            set(hObject,'UserData',2);
        case 2 % BCI2000 ".dat"
            for i=1:size(TrainFiles,1)
                if size(TrainFiles{i},2)<4
                    fprintf(2,'%s NOT OF COMPATIBLE FORMAT\n',TrainFiles{i});
                elseif ~strcmp(TrainFiles{i}(end-3:end),'.dat')
                    fprintf(2,'%s NOT OF COMPATIBLE FORMAT\n',TrainFiles{i});
                    set(hObject,'BackgroundColor','red')
                    set(hObject,'UserData',2);
                end
            end
        case 3 % bci ESI ".mat"
            for i=1:size(TrainFiles,1)
                if size(TrainFiles{i},2)<4
                    fprintf(2,'%s NOT OF COMPATIBLE FORMAT\n',TrainFiles{i});
                elseif ~strcmp(TrainFiles{i}(end-3:end),'.mat')
                    fprintf(2,'%s NOT OF COMPATIBLE FORMAT\n',TrainFiles{i});
                    set(hObject,'BackgroundColor','red')
                    set(hObject,'UserData',2);
                end
            end
    end
end

TrainingScheme=get(handles.TrainingScheme,'Value');
if isequal(TrainingScheme,1)
    fprintf(2,'MUST SELECT A TRAINING SCHEME TO TRAIN DECODER\n');
    set(hObject,'BackgroundColor','red')
    set(hObject,'UserData',2);
end
handles.Regress.trainingscheme=TrainingScheme;

DecoderType=get(handles.DecoderType,'Value');
if isequal(DecoderType,1)
    fprintf(2,'MUST SELECT A DECODER TYPE TO TRAIN DECODER\n');
    set(hObject,'BackgroundColor','red')
    set(hObject,'UserData',2);
end
handles.Regress.decodertype=DecoderType;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% ENSURE THAT THE NECESSARY "DOMAIN-INDEPENDENT" VARIABLES ARE DEFINED
TaskType=get(handles.TaskType,'Value');
switch TaskType
    case {1,2,3,4,5}
        fprintf(2,'TASK TYPE MUST BE SET TO "TRAINING" IN ORDER TO TRAIN CLASSIFIER\n');
        set(hObject,'BackgroundColor','red')
        set(hObject,'UserData',2);
    case 6 % Training
end

EEGsystem=str2double(get(handles.EEGsystem,'String'));
handles.Regress.eegsystem=EEGsystem;
if isequal(EEGsystem,1)
    fprintf(2,'EEG SYSTEM MUST BE SELECTED\n');
    set(hObject,'BackgroundColor','red')
    set(hObject,'UserData',2);
else
    handles.Regress.eegsystem=str2double(EEGsystem);
    fs=str2double(get(handles.fs,'String'));
    handles.Regress.fs=fs;
end

% RegressAll=get(handles.RegressAll,'Value');
% if isequal(RegressAll,1)
%     LowCutoff=1;
%     HighCutoff=40;
% elseif isequal(RegressAll,0)
    LowCutoff=str2double(get(handles.LowCutoff,'String'));
    if isnan(LowCutoff)
        fprintf(2,'LOW BANDPASS FILTER CUTOFF MUST BE DEFINED\n');
        set(hObject,'BackgroundColor','red')
        set(hObject,'UserData',2);
    else
        handles.Regress.lowcutoff=str2double(LowCutoff);
    end

    HighCutoff=str2double(get(handles.HighCutoff,'String'));
    if isnan(HighCutoff)
        fprintf(2,'HIGH BANDPASS FILTER CUTOFF MUST BE DEFINED\n');
        set(hObject,'BackgroundColor','red')
        set(hObject,'UserData',2);
    else
        handles.Regress.highcutoff=str2double(HighCutoff);
    end
% end

% If cutoff freq defined, create filter and frequency transformation param
if exist('LowCutoff','var') && isnumeric(LowCutoff) &&...
        exist('HighCutoff','var') && isnumeric(HighCutoff)
    
    if isfield(handles,'TFParam') && isfield(handles.TFParam,'butterB') &&...
            ~isempty(handles.TFParam.butterB) && isfield(handles.TFParam,'butterA') &&...
            ~isempty(handles.TFParam.butterA)
        handles.Regress.bpfiltb=handles.TFParam.butterB;
        handles.Regress.bpfilta=handles.TFParam.butterA;
    else
        n=4;
        Wn=[LowCutoff HighCutoff]/(fs/2);
        [b,a]=butter(n,Wn);
        handles.Regress.bpfiltb=b;
        handles.Regress.bpfilta=a;
        fprintf(2,'BANDPASS FILTER COEFFICIENTS NOT STORED, CREATING NOW\n');
    end
    
    PSD=get(handles.PSD,'Value');
    handles.Regress.psd=PSD;
    switch PSD
        case 1 % None
        case 2 % Complex Morlet wavelet
%             if isequal(RegressAll,0)
                if isfield(handles,'MWParam') && ~isempty(handles.MWParam)
                    
                    if isfield(handles.MWParam,'Freq') && ~isempty(handles.MWParam.Freq)
                        handles.Regress.MWParam.Freq=handles.MWParam.Freq;
                    else
                        handles.Regress.MWParam.Freq=[LowCutoff HighCutoff];
                    end
                    
                    if isfield(handles.MWParam,'FreqRes') && ~isempty(handles.MWParam.FreqRes)
                        handles.Regress.MWParam.FreqRes=handles.MWParam.FreqRes;
                    else
                        handles.Regress.MWParam.FreqRes=.5;
                    end
                    
                    if isfield(handles.MWParam,'FreqVect') && ~isempty(handles.MWParam.FreqVect)
                        handles.Regress.MWParam.FreqVect=handles.MWParam.FreqVect;
                    else
                        handles.Regress.MWParam.FreqVect=....
                            LowCutOff:handles.handles.Regress.MWParam.FreqRes:HighCutOff;
                    end
                    
                    if isfield(handles.MWParam,'fs') && ~isempty(handles.MWParam.fs)
                        handles.Regress.MWParam.fs=handles.MWParam.fs;
                    elseif ~isequal(EEGsystem,1)
                        handles.Regress.MWParam.fs=str2double(get(handles.fs,'String'));
                    elseif exist('fs','var')
                        handles.Regress.MWParam.fs=fs;
                    end
                    
                else
                    handles.Regress.MWParam.Freq=[LowCutoff HighCutoff];
                    handles.Regress.MWParam.FreqRes=1;
                    handles.Regress.MWParam.FreqVect=...
                        LowCutoff:handles.Regress.MWParam.FreqRes:HighCutoff;
                    handles.Regress.MWParam.fs=fs;
                    handles.Regress.MorWav=bci_fESI_MorWav(handles.Regress.MWParam);
                end
%             else
%                 handles.Regress.MWParam.Freq=[LowCutoff HighCutoff];
%                 handles.Regress.MWParam.FreqRes=1;
%                 handles.Regress.MWParam.FreqVect=...
%                     LowCutoff:handles.Regress.MWParam.FreqRes:HighCutoff;
%                 handles.Regress.MWParam.fs=fs;
%                 handles.Regress.MorWav=bci_fESI_MorWav(handles.Regress.MWParam);
%             end
        case 3 % Welch's PSD
        case 4 % DFT
    end
    
else
    fprintf(2,'CANNOT CREATE BANDPASS FILTER WITHOUT DEFINED BANDPASS CUTOFFS\n');
    set(hObject,'BackgroundColor','red')
    set(hObject,'UserData',2);
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% ENSURE THAT THE NECESSARY "DOMAIN-DEPENDENT" VARIABLES ARE DEFINED
Domain=get(handles.Domain,'value');
handles.Regress.domain=Domain;
switch Domain
    case 1 % None
        
        fprintf(2,'MUST SELECT A DOMAIN TO TRAIN CLASSIFIER\n');
        set(hObject,'BackgroundColor','red')
        set(hObject,'UserData',2);
        
    case 2 % Sensor
        
        SensorRegions=get(handles.SelectSensorRegions,'UserData');
        if size(SensorRegions,1)<1
            fprintf(2,'NO SENSORS SELECTED, MUST SELECT SENSORS TO TRAIN CLASSIFER\n');
            set(hObject,'BackgroundColor','red')
            set(hObject,'UserData',2);
        else
            SensorsInclude=find(SensorRegions==1);
            SensorsExclude=find(SensorRegions==0);
            handles.Regress.sensorsinclude=SensorsInclude;
            
            if isfield(handles,'Electrodes') && isfield(handles.Electrodes,'eLoc2') &&...
                    ~isempty(handles.Electrodes.eLoc2)
                eLoc=handles.Electrodes.eLoc2;
                eLoc(SensorsExclude)=[];
                handles.Regress.eLoc=eLoc;
            else
                fprintf(2,'MUST SELECT EEG SYSTEM TO TRAIN CLASSIFIER\n');
                set(hObject,'BackgroundColor','red')
                set(hObject,'UserData',2);
            end
            
        end
        
    case {3,4} % ESI/fESI
        if isfield(handles,'Inverse') && isfield(handles.Inverse,'Cortex')
            
            BrainRegions=get(handles.SelectBrainRegions,'UserData');
            if size(BrainRegions,1)<1
                fprintf(2,'NO BRAIN REGIONS SELECTED, MUST SELECT BRAIN REGIONS TO TRAIN CLASSIFER\n');
                set(hObject,'BackgroundColor','red')
                set(hObject,'UserData',2);
            else
                BrainRegionsInclude=find(BrainRegions==1);
                BrainRegions=load(get(handles.BrainRegionFile,'String'));
                VerticesInclude={BrainRegions.Scouts(BrainRegionsInclude).Vertices};
                VerticesInclude=sort(horzcat(VerticesInclude{:}),'ascend');

                VerticesExclude=1:BrainRegions.TessNbVertices;
                VerticesExclude(VerticesInclude)=[];

                handles.Regress.brainregionsinclude=BrainRegionsInclude;
                handles.Regress.verticesinclude=VerticesInclude;
                handles.Regress.verticesexclude=VerticesExclude;
            end
            
        else
            fprintf(2,'MUST SET PARAMETERS TO TRAIN CLASSIFIER\n');
            set(hObject,'BackgroundColor','red')
            set(hObject,'UserData',2);
        end
        
        Noise=get(handles.Noise,'Value');
        if isequal(Noise,1)
            fprintf(2,'NOISE COVARIANCE METHOD MUST BE SET TO TRAIN CLASSIFIER\n');
            set(hObject,'BackgroundColor','red')
            set(hObject,'UserData',2);
        elseif isequal(Noise,2)
        else
            
            NoiseDataFile=get(handles.NoiseDataFile,'String');
            if isempty(NoiseDataFile)
                fprintf(2,'NOISE DATA FILE MUST BE SELECTED TO TRAIN CLASSIFIER\n');
                set(hObject,'BackgroundColor','red')
                set(hObject,'UserData',2);
            elseif ~exist(NoiseDataFile,'file')
                fprintf(2,'SELECTED NOISE DATA FILE DOES NOT EXIST, CANNOT TRAIN CLASSIFIER\n');
                set(hObject,'BackgroundColor','red')
                set(hObject,'UserData',2);
            end 
        end
        
end