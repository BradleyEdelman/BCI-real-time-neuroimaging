function [handles,TaskInfo,Data]=bci_fESI_BCIESITaskInfo(handles,TrainFiles,TrialInfo)
%%
TaskInfo=cell(0);
TaskInfo{1,1}='Trial';
TaskInfo{1,2}='Targ';
TaskInfo{1,3}='Base Start';
TaskInfo{1,4}='Base End';
TaskInfo{1,5}='Stim Start';
TaskInfo{1,6}='Stim End';
TaskInfo{1,7}='Duration (win)';

Length=TrialInfo.length;
ChanIdxInclude=TrialInfo.chanidxinclude;
VertIdxInclude=TrialInfo.vertidxinclude;
NumFreq=TrialInfo.numfreq;

Data.Sensor=zeros(size(ChanIdxInclude,1),Length);
Data.Source=zeros(size(VertIdxInclude,2),Length);

DataEnd=0; TotTrial=0; TotWindows=0;
for j=1:size(TrainFiles,1)
    
    load(TrainFiles{j})
    Dat2=Dat; clear Dat
    Targets=Dat2(end).performance.targets;
    Targets=str2double(Targets(2:end,2));
    
    StimStatus{j}=cell2mat({Dat2.stimstatus});
    BaseStatus{j}=cell2mat({Dat2.basestatus});
    
    StimType=find(sum(StimStatus{j},2)~=0);
    NumStim=size(StimType,1);
    
    StimStart=[]; StimEnd=[];
    for k=1:NumStim
        StimStart=[StimStart find(diff(StimStatus{j}(k,:))==1)+1];
        StimEnd=[StimEnd find(diff(StimStatus{j}(k,:))==-1)];
    end

    RunType=Dat2(end).runtype;
    
    
    BaseDiff=diff(BaseStatus{j});
    if strcmp(RunType,'Cursor')
        
        StartCount=0;
        for i=1:size(BaseDiff,2)
            if BaseDiff(i)==1
                StartCount=StartCount+1;
            end

            if BaseDiff(i)==-1 && StartCount==0
                BaseDiff(i)=0;
            end
        end
    
        BaseStart=find(BaseDiff==1);
        BaseEnd=find(BaseDiff==-1);
        
    elseif strcmp(RunType,'Stimulus')
            
        %     BaseStart=StimEnd+1;
        BaseStart=find(BaseDiff==1)+1;
        BaseStart=[BaseStart 1];
        %     BaseEnd=StimStart-1;
        BaseEnd=find(BaseDiff==-1);
        BaseEnd=[BaseEnd size(Dat2,2)];
    
    end

    StimStart=sort(StimStart,'ascend');
    StimEnd=sort(StimEnd,'ascend');
    BaseStart=sort(BaseStart,'ascend');
    BaseEnd=sort(BaseEnd,'ascend');
        
    for i=1:size(Targets,1)
        TaskInfo{i+TotTrial+1,1}=i+TotTrial;
        TaskInfo{i+TotTrial+1,2}=Targets(i);
        TaskInfo{i+TotTrial+1,3}=TotWindows+BaseStart(i);
        TaskInfo{i+TotTrial+1,4}=TotWindows+BaseEnd(i);
        TaskInfo{i+TotTrial+1,5}=TotWindows+StimStart(i);
        TaskInfo{i+TotTrial+1,6}=TotWindows+StimEnd(i);
        TaskInfo{i+TotTrial+1,7}=StimEnd(i)-StimStart(i)+1;
    end
    
    % Extract out online processed data
    for i=1:size(Dat2,2)
        PSDSensor=Dat2(i).psd.sensor;
        PSDSource=Dat2(i).psd.source;
        
        for k=1:NumFreq+1
            
            Data.Sensor(:,i+TotWindows,k)=PSDSensor(:,k);
            
            if ~isequal(PSDSource,[])
                Data.Source(:,i+TotWindows,k)=PSDSource(VertIdxInclude,k);
            end
            
        end
    end
    
    TotTrial=TotTrial+size(Targets,1);
    TotWindows=TotWindows+size(Dat2,2);
end


for i=TotTrial:-1:1
    if TaskInfo{i+1,7}==1 || (TaskInfo{i+1,4}-TaskInfo{i+1,3})>50
        TaskInfo(i+1,:)=[];

        for k=size(TaskInfo,1):-1:i
            TaskInfo{k,1}=TaskInfo{k,1}-1;
        end
    end
end

% Reconstruct task timings after trials have been removed
StimStatus2=zeros(NumStim,TotWindows);
BaseStatus2=zeros(1,TotWindows);
for i=2:size(TaskInfo,1)
    StimType=TaskInfo{i,2};
    BaseStatus2(TaskInfo{i,3}:TaskInfo{i,4})=1;
    StimStatus2(StimType,TaskInfo{i,5}:TaskInfo{i,6})=1;
end
    
Plot=[BaseStatus2;StimStatus2];
figure; imagesc(Plot')
title('Task Timings')
ylabel('Time (windows')
colormap(gray)
set(gca,'Xtick',1:1:size(Plot,1),...
    'xticklabel',{'Base' 'Task 1' 'Task 2' 'Task 3' 'Task 4'})

disp(TaskInfo)
    
