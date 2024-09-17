function [TrialStruct]=bci_fESI_ExtractBCI2000Parameters(TrainFiles)

% LOAD THE SELECTED PARAM FILE
for i=1:size(TrainFiles,1)
    
    [fid]=fopen(TrainFiles{i},'r');
    lines={};
    for j=1:140
        lines=[lines;{fgetl(fid)}];
    end

    clear PreRun PreFeed PostFeed ITI MaxFeed StimDur ISIMin ISIMax 
    clear ISI StimName NewStim TrainTaskType Targets TargetsXY
    % EXTRACT THE TRIAL STRUCUTRE
    NewStim=[];
    for j=1:size(lines,1)

        if ~isempty(strfind(lines{j},'PreRunDuration'))
            PreRun=str2double(regexp(lines{j},'.\d+','match'));
            PreRun=PreRun(1);
        elseif ~isempty(strfind(lines{j},'PreFeedbackDuration'))
            PreFeed=str2double(regexp(lines{j},'.\d+','match'));
            PreFeed=PreFeed(1);
        elseif ~isempty(strfind(lines{j},'PostFeedbackDuration'))
            PostFeed=str2double(regexp(lines{j},'.\d+','match'));
            PostFeed=PostFeed(1);
        elseif ~isempty(strfind(lines{j},'ITIDuration'))
            ITI=str2double(regexp(lines{j},'.\d+','match'));
            ITI=ITI(1);
        elseif ~isempty(strfind(lines{j},'MaxFeedbackDuration'))
            MaxFeed=str2double(regexp(lines{j},'.\d+','match'));
            MaxFeed=MaxFeed(1);
        elseif ~isempty(strfind(lines{j},'StimulusDuration'))
            StimDur=str2double(regexp(lines{j},'.\d+','match'));
            StimDur=StimDur(1);
        elseif ~isempty(strfind(lines{j},'ISIMinDuration'))   
            ISIMin=str2double(regexp(lines{j},'.\d+','match'));
            ISIMin=ISIMin(1);
        elseif ~isempty(strfind(lines{j},'ISIMaxDuration'))   
            ISIMax=str2double(regexp(lines{j},'.\d+','match'));
            ISIMax=ISIMax(1);
        elseif ~isempty(strfind(lines{j},'matrix Targets'))
            Targets=str2double(regexp(lines{j},['\d+\.?\d*'],'match'));
            Targets=Targets(8:end);
            TargetsXY(:,1)=Targets(1:6:end);
            TargetsXY(:,2)=Targets(2:6:end);
        elseif ~isempty(strfind(lines{j},'matrix Stimuli'))
            
            if ~isempty(strfind(lines{j},'Rest'))
                NewStim=[NewStim strfind(lines{j},'Rest')];
            end
            
            if ~isempty(strfind(lines{j},'Imagine'))
                NewStim=[NewStim strfind(lines{j},'Imagine')]; 
            end
            
            if ~isempty(strfind(lines{j},'Move'))
                NewStim=[NewStim strfind(lines{j},'Move')];
            end
            
            if ~isempty(strfind(lines{j},'Twist'))
                NewStim=[NewStim strfind(lines{j},'Twist')];
            end
            
            if ~isempty(strfind(lines{j},'Bend'))
                NewStim=[NewStim strfind(lines{j},'Bend')];
            end
            
            NewStim=sort(NewStim,'ascend');
            
            if exist('NewStim','var')
                Spaces=regexp(lines{j},' ');
                Spaces=Spaces(Spaces>NewStim(1));
                for k=1:size(NewStim,2)
                    StimName{1,k}=lines{j}(NewStim(k):Spaces(k)-1);
                end
            end

        elseif ~exist('TrainTaskType','var') && ~isempty(strfind(lines{j},'Stimulus'))
            TrainTaskType='Stimulus';
        elseif ~exist('TrainTaskType','var') && ~isempty(strfind(lines{j},'Cursor'))
            TrainTaskType='Cursor';
        end
    end
    
    if exist('ISIMin','var') && exist('ISIMax','var') && isequal(ISIMin,ISIMax)
        ISI=mean(ISIMin,ISIMax);
    elseif exist('ISIMin','var') && exist('ISIMax','var') && ~isequal(ISIMin,ISIMax)
        error('LENGTH OF ISIMIN AND ISIMAX INCONSISTENT\n')
    end

    if exist('PreRun','var'); 
        if PreRun>100; PreRun=PreRun/1000; end
        TrialStruct(i).prerun=PreRun;
    end

    if exist('PreFeed','var'); 
        if PreFeed>100; PreFeed=PreFeed/1000; end
        TrialStruct(i).prefeed=PreFeed;
    end
    
    if exist('PostFeed','var');
        if PostFeed>100; PostFeed=PostFeed/1000; end
        TrialStruct(i).postfeed=PostFeed;
    end
    if exist('ITI','var');
        if ITI>100; ITI=ITI/1000; end
        TrialStruct(i).iti=ITI; 
    end
    
    if exist('MaxFeed','var');
        if MaxFeed>100; MaxFeed=MaxFeed/1000; end
        TrialStruct(i).maxfeed=MaxFeed;
    end
    
    if exist('StimDur','var');
        if StimDur>100; StimDur=StimDur/1000; end
        TrialStruct(i).stimdur=StimDur;
    end
    
    if exist('TargetsXY','var')
        TrialStruct(i).targetsxy=TargetsXY;
    end
    
    if exist('ISI','var');
        if ISI>100; ISI=ISI/1000; end
        TrialStruct(i).isi=ISI;
    end
    
    if exist('StimName','var'); TrialStruct(i).stimname=StimName; end
    
    if exist('TrainTaskType','var'); TrialStruct(i).tasktype=TrainTaskType; end

end


% CHECK CONSISTENCY OF PARAMETERS ACROSS TRAINING FILES
clear tmp
if isfield(TrialStruct,'tasktype')
    for i=1:size(TrainFiles,1)
        if ~isempty(TrialStruct(i).tasktype)
            tmp{i}=TrialStruct(i).tasktype;
        else
            tmp{i}='';
        end
    end
    tmptasktype=unique(tmp);

    combinations=combnk(1:size(TrialStruct,2),2);
% combinations=[1 2];
    Compare=zeros(size(combinations,1),1);
    for i=1:size(combinations,1)
        if strcmp(tmp(combinations(i,1)),tmp(combinations(i,2)))
            Compare(i)=1;
        else
            Compare(i)=0;
        end
    end
    if ~isequal(sum(Compare),size(combinations,1))
        error('INCONSISTENT TASK TYPE AMONG TRAINING FILES');
    end
    
end

if exist('tmptasktype','var') && strcmp(tmptasktype,'Cursor')
    
    targets=cat(3,TrialStruct.targetsxy);
    [n,m,p]=size(targets);
    a=reshape(targets,n,[],1);
    b=reshape(a(:),n*m,[])';
    c=unique(b,'rows','stable')';
    uniquetargets=reshape(c,n,m,[]);
    
    tottargets=[];
    for i=1:size(uniquetargets,3)
        tottargets=[tottargets;uniquetargets(:,:,i)];
    end
    
    for i=1:size(TrainFiles,1)
        for j=1:size(TrialStruct(i).targetsxy,1)
            for k=1:size(tottargets,1)
                if isequal(TrialStruct(i).targetsxy(j,:),tottargets(k,:))
                    Targs{i}(j)=k;
                end
            end
        end
    end
    TrialStruct(1).targs=Targs;       
    
end

clear tmp
if isfield(TrialStruct,'prerun')
    for i=1:size(TrainFiles,1)
        tmp(i)=TrialStruct(i).prerun;
    end
    if range(tmp)>0
        error('PRERUN DURATION INCONSISTENT AMONG TRAINING FILES');
    end
end

clear tmp
if isfield(TrialStruct,'prefeed')
    for i=1:size(TrainFiles,1)
        if ~isempty(TrialStruct(i).prefeed)
            tmp(i)=TrialStruct(i).prefeed;
        else
            tmp(i)=0;
        end
    end
    if range(tmp)>0
        error('PRE FEEDBACK DURATION INCONSISTENT AMONG TRAINING FILES');
    end
end
    
clear tmp
if isfield(TrialStruct,'postfeed')
    for i=1:size(TrainFiles,1)
        if ~isempty(TrialStruct(i).postfeed)
            tmp(i)=TrialStruct(i).postfeed;
        else
            tmp(i)=0;
        end
    end
    if range(tmp)>0
        error('POST FEEDBACK DURATION INCONSISTENT AMONG TRAINING FILES');
    end
end

clear tmp
if isfield(TrialStruct,'iti')
    for i=1:size(TrainFiles,1)
        if ~isempty(TrialStruct(i).iti)
            tmp(i)=TrialStruct(i).iti;
        else
            tmp(i)=0;
        end
    end
    if range(tmp)>0
        error('ITI DURATION INCONSISTENT AMONG TRAINING FILES');
    end
end

clear tmp
if isfield(TrialStruct,'maxfeed')
    for i=1:size(TrainFiles,1)
        if ~isempty(TrialStruct(i).maxfeed)
            tmp(i)=TrialStruct(i).maxfeed;
        else
            tmp(i)=0;
        end
    end
    if range(tmp)>0
        error('MAX FEEDBACK DURATION INCONSISTENT AMONG TRAINING FILES');
    end
end

clear tmp
if isfield(TrialStruct,'stimdur')
    for i=1:size(TrainFiles,1)
        if ~isempty(TrialStruct(i).stimdur)
            tmp(i)=TrialStruct(i).stimdur;
        else
            tmp(i)=0;
        end
    end
    if range(tmp)>0
        error('STIMULUS DURATION INCONSISTENT AMONG TRAINING FILES');
    end
end

clear tmp
if isfield(TrialStruct,'isi')
    for i=1:size(TrainFiles,1)
        if ~isempty(TrialStruct(i).isi)
            tmp(i)=TrialStruct(i).isi;
        else
            tmp(i)=0;
        end
    end
    if range(tmp)>0
        error('ISI DURATION INCONSISTENT AMONG TRAINING FILES');
    end
end

clear tmp
if isfield(TrialStruct,'stimname')
    for i=1:size(TrainFiles,1)
        if ~isequal(TrialStruct(i).stimname,[])
            tmp(i,:)=TrialStruct(i).stimname;
        else
%             tmp(i,:)=;
        end
    end
    
    for i=1:size(tmp,2)
        if isequal(tmp{1,i},[])
            error('INCONSISTENT TASKS AMONG TRAINING FILES');
        else
            TrialStruct(1).stimname=tmp';
            
%             for j=2:size(tmp,1)
%                 if ~ismember(tmp(1,i),tmp(j,:))
%                     error('INCONSISTENT TASKS AMONG TRAINING FILES');
%                 end
%             end
        end
    end
end

TrialStruct=TrialStruct(1);
        
        
        
        
        
        
        
        
        


