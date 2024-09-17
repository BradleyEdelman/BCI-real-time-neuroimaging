function [hObject,handles,BaselineData,TrialData]=bci_fESI_TrialSections(hObject,handles,TaskInfo,TrialStruct,Data,Window)

% BREAK DATA INTO BASELINE AND TASK SEGMENTS FOR EACH TRIAL
NumTrial=size(TaskInfo,1)-1;
if strcmp(TrialStruct.tasktype,'Cursor')
    for j=1:NumTrial
        Base{j}=Data(:,TaskInfo{j+1,3}:TaskInfo{j+1,4});
        Trial{j}=Data(:,TaskInfo{j+1,4}:TaskInfo{j+1,6});
    end
elseif strcmp(TrialStruct.tasktype,'Stimulus')
    for j=1:NumTrial
        Base{j}=Data(:,TaskInfo{j+1,7}:TaskInfo{j+1,4});
        Trial{j}=Data(:,TaskInfo{j+1,4}:TaskInfo{j+1,5});
    end
end


% SUBDIVIDE EACH TRIAL INTO WINDOWED SEGMENTS
if ischar(Window) && strcmp(Window,'Full')
    
    % FULL TRIAL DATA
    for j=1:NumTrial
        Base2(:,j)=sum(Base{j},2);
        Trial2(:,j)=sum(Trial{j},2);
    end
    
elseif isnumeric(Window)
    
    % Identify maximum trial length possible within paradigm
    TaskType=TrialStruct.tasktype;
    switch TaskType
        case 'Cursor'
            MaxDur=TrialStruct.maxfeed*str2double(handles.SYSTEM.fs)/handles.SYSTEM.dsfactor;
        case 'Stimulus'
            MaxDur=TrialStruct.stimdur*str2double(handles.SYSTEM.fs)/handles.SYSTEM.dsfactor;
    end
    MinDur=round(100/1000*str2double(handles.SYSTEM.fs)/handles.SYSTEM.dsfactor);
    
    % 100ms minimum
    if Window>=MinDur && Window<=MaxDur
        
        for j=1:NumTrial

            % Separate Baseline
            StartIdx=1;
            EndIdx=StartIdx+Window-1;
            k=1;
            while EndIdx<size(Base{j},2) % Ignore last window if too small
                Base2{j}(:,k)=sum(Base{j}(:,StartIdx:EndIdx),2);
                StartIdx=EndIdx;
                EndIdx=StartIdx+Window-1;
                k=k+1;
            end

            % Separate Trial
            StartIdx=1;
            EndIdx=StartIdx+Window-1;
            k=1;
            while EndIdx<size(Trial{j},2)
                Trial2{j}(:,k)=sum(Trial{j}(:,StartIdx:EndIdx),2);
                StartIdx=EndIdx;
                EndIdx=StartIdx+Window-1;
                k=k+1;
            end

        end
    end
end

% Separate baseline and trial data into the different tasks
NumTask=size(unique(cell2mat((TaskInfo(2:end,2)))),1);
for j=1:NumTask
    TaskInd=find(cell2mat(TaskInfo(2:end,2))==j);
    BaselineData{j}=Base2(:,TaskInd);
    TrialData{j}=Trial2(:,TaskInd);
end