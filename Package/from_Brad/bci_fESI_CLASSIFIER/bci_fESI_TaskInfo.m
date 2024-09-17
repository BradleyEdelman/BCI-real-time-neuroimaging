function [handles,TaskInfo,Data]=bci_fESI_TaskInfo(handles,TrainFiles,TrialStruct)


if strcmp(TrialStruct.tasktype,'Cursor')

    TaskInfo=cell(0);
    TaskInfo{1,1}='Trial';
    TaskInfo{1,2}='Targ';
    TaskInfo{1,3}='Targ Lat';
    TaskInfo{1,4}='Feedback Lat';
    TaskInfo{1,5}='Result';
    TaskInfo{1,6}='Result Lat';
    TaskInfo{1,7}='Result';
    TaskInfo{1,8}='Duration';

    Data=[]; DataEnd=0; TotTrial=0;
    for j=1:size(TrainFiles,1)
        EEG=pop_loadBCI2000(TrainFiles{j},{'TargetCode','ResultCode','Feedback'});

        if j>1 && ~isequal(size(Data,1),size(EEG.data,1))
            fprintf(2,'TRAINING DATA SETS HAVE INCONSISTENT CHANNELS NUMBERS, STOPPING TRAINING\n');
            return
        end

        Data=[Data double(EEG.data)];

        clear Events
        Events(:,1)={EEG.event.type};
        Events(:,2)={EEG.event.position};
        for k=1:size(Events,1)
            Events(k,3)={EEG.event(k).latency+DataEnd};
        end
        DataEnd=size(Data,2);

        NewTrial=find(strcmp(Events(:,1),'TargetCode')); % Trials in current run
        CurrentTrial=size(NewTrial,1);
        NewTrial(end+1)=size(Events,1)+1;

        for k=1:CurrentTrial
            TaskInfo{k+1+TotTrial,1}=k; % Trial Number
            Targettmp=Events{NewTrial(k),2};
            TaskInfo{k+1+TotTrial,2}=TrialStruct.targs{j}(Targettmp); % TargetCode
%             TaskInfo{k+1+TotTrial,2}=Events{NewTrial(k),2}; % TargetCode
            TaskInfo{k+1+TotTrial,3}=Events{NewTrial(k),3}; % TargetCode Latency
            TaskInfo{k+1+TotTrial,4}=Events{NewTrial(k)+1,3}; % Feedback Latency

            if isequal(NewTrial(k+1)-NewTrial(k),3) % Contains target, feedback, and result

                Resulttmp=Events{NewTrial(k)+2,2};
                TaskInfo{k+1+TotTrial,5}=TrialStruct.targs{j}(Resulttmp); % ResultCode
%                 TaskInfo{k+1+TotTrial,5}=Events{NewTrial(k)+2,2}; % ResultCode
                TaskInfo{k+1+TotTrial,6}=Events{NewTrial(k)+2,3}; % ResultCode Latency
                if isequal(TaskInfo{k+1+TotTrial,2},TaskInfo{k+1+TotTrial,5}) % Result Info
                    TaskInfo{k+1+TotTrial,7}='Hit';
                else
                    TaskInfo{k+1+TotTrial,7}='Miss';
                end
                TaskInfo{k+1+TotTrial,8}=TaskInfo{k+1+TotTrial,6}-TaskInfo{k+1+TotTrial,4}; % Trial Duration

            else
                TaskInfo{k+1+TotTrial,5}=0;
                TaskInfo{k+1+TotTrial,6}=TaskInfo{k+1+TotTrial,4}+TrialStruct.maxfeed*handles.SYSTEM.fs; % Abort latency
                TaskInfo{k+1+TotTrial,7}='Abort';
                TaskInfo{k+1+TotTrial,8}=TrialStruct.maxfeed*handles.SYSTEM.fs; % Abort duration
            end
        end
        TotTrial=TotTrial+CurrentTrial; % Total trials in all data sets

    end
    
    % Downsample TaskInfo and Data
    for i=2:size(TaskInfo,1)
        for j=[3 4 6 8]
            TaskInfo{i,j}=ceil(TaskInfo{i,j}/handles.SYSTEM.dsfactor);
        end
    end
    Data=Data(:,1:handles.SYSTEM.dsfactor:end);
    disp(TaskInfo)
    
    Hits=size(find(strcmp(TaskInfo(:,7),'Hit')),1);
    Misses=size(find(strcmp(TaskInfo(:,7),'Miss')),1);
    Aborts=size(find(strcmp(TaskInfo(:,7),'Abort')),1);
    PVC=Hits/(Hits+Misses)*100;
    fprintf('\n Percent Valid Correct: %.2f\n',PVC);
    PTC=Hits/TotTrial*100;
    fprintf('\n Percent Total Correct: %.2f\n',PTC);
    
    TargetTypes=unique(cell2mat(TaskInfo(2:end,2)));
    NumTask=size(TargetTypes,1);

elseif strcmp(TrialStruct.tasktype,'Stimulus')

    TaskInfo=cell(0);
    TaskInfo{1,1}='Trial';
    TaskInfo{1,2}='Targ';
    TaskInfo{1,3}='Stimulus';
    TaskInfo{1,4}='Stim Start';
    TaskInfo{1,5}='Stim End';
    TaskInfo{1,6}='Duration';
    TaskInfo{1,7}='Base Start';
    TaskInfo{1,8}='Base End';
    
    Data=[]; DataEnd=0; TotTrial=0; TotEvents=0;
    for j=1:size(TrainFiles,1)
        EEG=pop_loadBCI2000(TrainFiles{j},{'StimulusCode'});

        if j>1 && ~isequal(size(Data,1),size(EEG.data,1))
            fprintf(2,'TRAINING DATA SETS HAVE INCONSISTENT CHANNELS NUMBERS, STOPPING TRAINING\n');
            return
        end
    
        OldDataLength=size(Data,2);
        Data=[Data double(EEG.data)];

        clear Events
        Events(:,1)={EEG.event.type};
        Events(:,2)={EEG.event.position};
        for k=1:size(Events,1)
            Events(k,3)={EEG.event(k).latency+DataEnd};
        end
        DataEnd=size(Data,2);
    
        NewTrial=find(strcmp(Events(:,1),'StimulusCode')); % Trials in current run
        CurrentTrial=size(NewTrial,1);
        
        for k=1:CurrentTrial
            TaskInfo{k+1+TotTrial,1}=k; % Trial Number
            TaskInfo{k+1+TotTrial,2}=Events{NewTrial(k),2}+TotEvents; % TargetCode
            TaskInfo{k+1+TotTrial,3}=TrialStruct.stimname{TaskInfo{k+1+TotTrial,2}}; % Stimulus
            TaskInfo{k+1+TotTrial,4}=Events{NewTrial(k),3}; % StimulusCode Latency
            TaskInfo{k+1+TotTrial,5}=TaskInfo{k+1+TotTrial,4}+TrialStruct.stimdur*1000-1; % Stimulus End
            TaskInfo{k+1+TotTrial,6}=TrialStruct.stimdur*1000; % Stimulus Duration
            
            if k==1
                TaskInfo{k+1+TotTrial,7}=OldDataLength+1;
            else
                TaskInfo{k+1+TotTrial,7}=TaskInfo{k+TotTrial,5}+1;
            end
            
            TaskInfo{k+1+TotTrial,8}=TaskInfo{k+1+TotTrial,4}-1;

        end
        TotTrial=TotTrial+CurrentTrial; % Total trials in all data sets
        TotEvents=size(unique(cell2mat(Events(:,2))),1);
        
    end
    % Downsample TaskInfo and Data
    for i=2:size(TaskInfo,1)
        for j=4:size(TaskInfo,2)
            TaskInfo{i,j}=ceil(TaskInfo{i,j}/handles.SYSTEM.dsfactor);
        end
    end
    Data=Data(:,1:handles.SYSTEM.dsfactor:end);
    disp(TaskInfo)
    
    TargetTypes=unique(cell2mat(TaskInfo(2:end,2))); 
    NumTask=size(TargetTypes,1);
    
else
    error('BCI2000 .DAT FILES MUST EITHER BE CURSOR OR STIMULUS TASK TYPES\n');
end

