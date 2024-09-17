function [hObject,handles]=bci_fESI_RegressionPerform(hObject,handles,TaskInfo,TrialStruct,Data)

SaveFileDir=handles.SYSTEM.savefiledir;

% REMOVE ALL "Regression" VARIABLES FROM DISPLAY LIST - REPOPULATE HERE
regressvar=cell(get(handles.regressvar,'String'));
domain=get(handles.domain,'Value');
switch domain
    case 1 % None
    case 2 % Sensor
        ChanInclude=handles.RegressSensor.chanidxinclude;
        DomainField='RegressSensor';
        for i=size(regressvar,1):-1:1
            if ~isempty(strfind(regressvar{i},'Sensor'))
                regressvar(i)=[];
            end
        end
    case 3 % ESI
        ChanInclude=handles.RegressSource.vertidxinclude;
        NumCluster=size(handles.ESI.clusters,2);
        DomainField='RegressSource';
        for i=size(regressvar,1):-1:1
            if ~isempty(strfind(regressvar{i},'Source'))
                regressvar(i)=[];
            end
        end
end
set(handles.regressvar,'Value',1);

% CHANNEL INDICES MUST BE COLUMN FORMAT
if size(ChanInclude,2)>size(ChanInclude,1)
    ChanInclude=ChanInclude';
end
NumChan=size(ChanInclude,1);

% RECALL FREQUENCY TRANSFORM PARAMETERS
psd=get(handles.psd,'Value');
switch psd
    case 1 % None
    case 2 % Complex Morlet Wavelet
        morwav=handles.(DomainField).morwav;
        FreqVect=handles.(DomainField).mwparam.FreqVect;
        NumFreq=size(FreqVect,2);
        fs=handles.(DomainField).mwparam.fs;
        dt=1/fs;
    case 3 % Welch's PSD
    case 4 % DFT
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% INITIALIZE REGRESSION STORAGE VARIABLES
[NumEEG,NumPnts]=size(Data);
NumTask=handles.(DomainField).NumTask;
combinations=combnk(1:NumTask,2);
NumComb=size(combinations,1);

% one-vs-rest
BOVR=zeros(NumChan,NumFreq,NumTask); RsqOVR=zeros(NumChan,NumFreq,NumTask);
rOVR=zeros(NumChan,NumFreq,NumTask); F_statOVR=zeros(NumChan,NumFreq,NumTask);
t_statOVR=zeros(NumChan,NumFreq,NumTask); p_statOVR=zeros(NumChan,NumFreq,NumTask);
% one-vs-one
BOVO=zeros(NumChan,NumFreq,NumComb); RsqOVO=zeros(NumChan,NumFreq,NumComb);
rOVO=zeros(NumChan,NumFreq,NumTask); F_statOVO=zeros(NumChan,NumFreq,NumTask);
t_statOVO=zeros(NumChan,NumFreq,NumComb); p_statOVO=zeros(NumChan,NumFreq,NumComb);
% one-vs-all
BOVA=zeros(NumChan,NumFreq,NumTask); RsqOVA=zeros(NumChan,NumFreq,NumTask);
rOVA=zeros(NumChan,NumFreq,NumTask); F_statOVA=zeros(NumChan,NumFreq,NumTask);
t_statOVA=zeros(NumChan,NumFreq,NumTask); p_statOVA=zeros(NumChan,NumFreq,NumTask);

% cluster storage variables
if isequal(domain,3)
    % one-vs-rest
    BOVRc=zeros(NumCluster-1,NumFreq,NumTask); RsqOVRc=zeros(NumCluster-1,NumFreq,NumTask);
    rOVRc=zeros(NumCluster-1,NumFreq,NumTask); F_statOVRc=zeros(NumCluster-1,NumFreq,NumTask);
    t_statOVRc=zeros(NumCluster-1,NumFreq,NumTask); p_statOVRc=zeros(NumCluster-1,NumFreq,NumTask);
    % one-vs-one
    BOVOc=zeros(NumCluster-1,NumFreq,NumComb); RsqOVOc=zeros(NumCluster-1,NumFreq,NumComb);
    rOVOc=zeros(NumCluster-1,NumFreq,NumTask); F_statOVOc=zeros(NumCluster-1,NumFreq,NumTask);
    t_statOVOc=zeros(NumCluster-1,NumFreq,NumComb); p_statOVOc=zeros(NumCluster-1,NumFreq,NumComb);
    % one-vs-all
    BOVAc=zeros(NumCluster-1,NumFreq,NumTask); RsqOVAc=zeros(NumCluster-1,NumFreq,NumTask);
    rOVAc=zeros(NumCluster-1,NumFreq,NumTask); F_statOVAc=zeros(NumCluster-1,NumFreq,NumTask);
    t_statOVAc=zeros(NumCluster-1,NumFreq,NumTask); p_statOVAc=zeros(NumCluster-1,NumFreq,NumTask);
end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% POPULATE BCI OPTIONS
% BCI tasks
bcitask1=cell(1,NumComb+1); bcitask2=cell(1,NumComb+1); bcitask3=cell(1,NumComb+1);
for i=1:NumComb
    bcitask1{i+1}=[num2str(combinations(i,1)) '-vs-' num2str(combinations(i,2))];
    bcitask2{i+1}=[num2str(combinations(i,1)) '-vs-' num2str(combinations(i,2))];
    bcitask3{i+1}=[num2str(combinations(i,1)) '-vs-' num2str(combinations(i,2))];
end
bcitask1{end+1}='Custom';
bcitask2{end+1}='Custom';
bcitask3{end+1}='Custom';
set(handles.bcitask1,'String',bcitask1,'Value',1)
set(handles.bcitask2,'String',bcitask2,'Value',1)
set(handles.bcitask3,'String',bcitask3,'Value',1)
handles.(DomainField).bcitask{1}=bcitask1;
handles.(DomainField).bcitask{2}=bcitask2;
handles.(DomainField).bcitask{3}=bcitask3;

% BCI Frequencies
NumFreq=size(handles.SYSTEM.lowcutoff:handles.SYSTEM.highcutoff,2);
bcifreq1=cell(1,NumFreq+1); bcifreq2=cell(1,NumFreq+1); bcifreq3=cell(1,NumFreq+1);
j=0;
for i=1:NumFreq
    bcifreq1{i+1}=handles.SYSTEM.lowcutoff+j;
    bcifreq2{i+1}=handles.SYSTEM.lowcutoff+j;
    bcifreq3{i+1}=handles.SYSTEM.lowcutoff+j;
    j=j+1;
end
set(handles.bcifreq1,'String',bcifreq1,'Value',1)
set(handles.bcifreq2,'String',bcifreq2,'Value',1)
set(handles.bcifreq3,'String',bcifreq3,'Value',1)
handles.(DomainField).bcifreq{1}=bcifreq1;
handles.(DomainField).bcifreq{2}=bcifreq2;
handles.(DomainField).bcifreq{3}=bcifreq3;
    

%%
% ONE FREQUENCY AT A TIME
string=['Performing Regression: ' num2str(handles.(DomainField).mwparam.FreqRes) ' Hz Resolution'];

filetype=handles.(DomainField).filetype;

h=waitbar(NumFreq,string);
for i=1:NumFreq
    waitbar(i/NumFreq)
    
    if strcmp(filetype,'.dat')
    
        % CONVERT FILTERED TIME DATA TO FREQUENCY DOMAIN
        A=zeros(1,NumPnts,NumEEG);
        for j=1:NumEEG
            A(:,:,j)=conv2(Data(j,:),morwav{i},'same')*dt;
        end

        % COMPUTE AMPLITUDE OF FREQUENCY SIGNAL
        switch domain
            case 1 % None
            case 2 % Sensor
                A=squeeze(A)';
                A=abs(A);
                [hObject,handles,BaselineData,TrialData]=...
                    bci_fESI_TrialSections(hObject,handles,TaskInfo,...
                    TrialStruct,A,250/1000*str2double(handles.SYSTEM.fs)/handles.SYSTEM.dsfactor);

                TotDataSensor(i).trialdata=TrialData;%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                TotDataSensor(i).labels=1:NumTask;%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

            case {3,4} % ESI or fESI
                noise=get(handles.noise,'Value');
                switch noise
                    case 1 % None
                    case 2 % No Noise Modeling

                        cluster=handles.ESI.clusters;
                        INV=handles.ESI.inv.nomodel; 

                        A_real=squeeze(real(A))';
                        A_imag=squeeze(imag(A))';
                        A_realcluster=zeros(NumChan,NumPnts);
                        A_imagcluster=zeros(NumChan,NumPnts);
                        A_source=zeros(NumChan,NumPnts);
                        VertIdxStart=1;
                        for j=1:NumCluster-1

                            VertIdx=VertIdxStart:VertIdxStart+size(cluster{j},2)-1;
                            A_realcluster(VertIdx,:)=INV{j}*A_real;
                            A_imagcluster(VertIdx,:)=INV{j}*A_imag;

                            A_source(VertIdx,:)=sqrt(A_realcluster(VertIdx,:).^2+A_imagcluster(VertIdx,:).^2);

                            VertIdxStart=VertIdx(end)+1;
                        end
                        clear A_realcluster A_imagcluster            
                        [hObject,handles,BaselineData,TrialData]=...
                            bci_fESI_TrialSections(hObject,handles,TaskInfo,...
                            TrialStruct,A_source,...
                            250/1000*str2double(handles.SYSTEM.fs)/handles.SYSTEM.dsfactor);

                        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                        if iscell(TrialData) && iscell(BaselineData)
                            for j=1:size(TrialData,2)
                                TrialData{j}=horzcat(TrialData{j}{:});
                            end
                            
                            for j=1:size(BaselineData,2)
                                BaselineData{j}=horzcat(BaselineData{j}{:});
                            end
                        end
                        
                        VertIdxStart=1;
                        for j=1:NumCluster-1
                            VertIdx=VertIdxStart:VertIdxStart+size(cluster{j},2)-1;
                            for k=1:size(TrialData,2)
                                TrialData2{k}(j,:)=mean(TrialData{k}(VertIdx,:),1);
                            end
                            VertIdxStart=VertIdx(end)+1;
                        end

                        TotDataSource(i).trialdata=TrialData2;
                        TotDataSource(i).labels=1:NumTask;  
                        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%  

                    case {3,4} % Diagonal or Full

                        cluster=handles.ESI.clusters;
                        INVreal=handles.ESI.inv.real;
                        INVimag=handles.ESI.inv.imag;

                        A_real=squeeze(real(A))';
                        A_imag=squeeze(imag(A))';
                        A_realcluster=zeros(NumChan,NumPnts);
                        A_imagcluster=zeros(NumChan,NumPnts);
                        A_source=zeros(NumChan,NumPnts);
                        VertIdxStart=1;
                        for j=1:NumCluster-1
                            VertIdx=VertIdxStart:VertIdxStart+size(cluster{j},2)-1;
                            A_realcluster(VertIdx,:)=INVreal{j}*A_real;
                            A_imagcluster(VertIdx,:)=INVimag{j}*A_imag;

                            A_source(VertIdx,:)=sqrt(A_realcluster(VertIdx,:).^2+A_imagcluster(VertIdx,:).^2);

                            VertIdxStart=VertIdx(end)+1;
                        end
                        clear A_realcluster A_imagcluster            
                        [hObject,handles,BaselineData,TrialData]=...
                            bci_fESI_TrialSections(hObject,handles,TaskInfo,...
                            TrialStruct,A_source,...
                            250/1000*str2double(handles.SYSTEM.fs)/handles.SYSTEM.dsfactor);
                        clear A_source
                        
                        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                        if iscell(TrialData) && iscell(BaselineData)
                            for j=1:size(TrialData,2)
                                TrialData{j}=horzcat(TrialData{j}{:});
                            end
                            
                            for j=1:size(BaselineData,2)
                                BaselineData{j}=horzcat(BaselineData{j}{:});
                            end
                        end
                        
                        VertIdxStart=1;
                        for j=1:NumCluster-1
                            VertIdx=VertIdxStart:VertIdxStart+size(cluster{j},2)-1;
                            for k=1:size(TrialData,2)
                                TrialData2{k}(j,:)=mean(TrialData{k}(VertIdx,:),1);
                            end
                            VertIdxStart=VertIdx(end)+1;
                        end
                        
                        TotDataSource(i).trialdata=TrialData2;
                        TotDataSource(i).labels=1:NumTask;
                        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                    
                end
        end
        
    elseif strcmp(filetype,'.mat')
        
        BaselineData=cell(1,NumTask);
        TrialData=cell(1,NumTask);
        ClassData=cell(1,NumTask);
        
        TaskInd=1:NumTask;
        l=[1 1];
        for j=2:size(TaskInfo,1)
            for k=1:NumTask
                if isequal(TaskInfo{j,2},TaskInd(k))
                    BaseStart=TaskInfo{j,3};
                    BaseEnd=TaskInfo{j,4};
                    TrialStart=TaskInfo{j,5};
                    TrialEnd=TaskInfo{j,6};
                    
                    switch domain
                        case 1 % None
                        case 2 % Sensor
                            BaselineData{k}=[BaselineData{k} Data.Sensor(:,BaseStart:BaseEnd,i)];
                            TrialData{k}=[TrialData{k} Data.Sensor(:,TrialStart:TrialEnd,i)];
                    
                            ClassData{k}{l(k)}=Data.Sensor(:,TrialStart:TrialEnd,i);
                        case 3 % Source
                            BaselineData{k}=[BaselineData{k} Data.Source(:,BaseStart:BaseEnd,i)];
                            TrialData{k}=[TrialData{k} Data.Source(:,TrialStart:TrialEnd,i)];
                    
                            ClassData{k}{l(k)}=Data.Source(:,TrialStart:TrialEnd,i);
                    end
                    
                    l(k)=l(k)+1;
                end
            end
        end
        
        for j=1:NumTask
            if isequal(sum(sum(BaselineData{j},1),2),0) || isequal(sum(sum(TrialData{j},1),2),0)
                error('TRAINING DATA FOR %s DOMAIN IS EMPTY',DomainField)
            end
        end
        
        switch domain
            case 1 % None
            case 2 % Sensor
                TotDataSensor(i).trialdata=TrialData;
                TotDataSensor(i).labels=1:NumTask;
                TotDataSensor(i).classdata=ClassData;
            case 3 % Source
                TotDataSource(i).trialdata=TrialData;
                TotDataSource(i).labels=1:NumTask;
                TotDataSource(i).classdata=ClassData;
        end
        
    end
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % ONE-vs-REST (OVR) REGRESSION FOR ALL TASKS AND CHANNELS
    for j=1:NumTask
        for k=1:NumChan
            
            % If trials are windowed
            if iscell(BaselineData{j})
                X1=[]; X2=[];
                % Go through each trial and concatenate windows
                for l=1:size(BaselineData{j},2)
                    X1=[X1;BaselineData{j}{l}(k,:)'];
                    X2=[X2;TrialData{j}{l}(k,:)'];
                end
            else
                % Or select single trial value for each channel
                X1=BaselineData{j}(k,:)';
                X2=TrialData{j}(k,:)';
            end
            
            [stats]=LSRegress(X1,X2);
            BOVR(k,i,j)=stats.B;
            RsqOVR(k,i,j)=stats.Rsq;
            rOVR(k,i,j)=stats.r;
            F_statOVR(k,i,j)=stats.F;
            t_statOVR(k,i,j)=stats.t;
            p_statOVR(k,i,j)=stats.p;
            
        end
        
        % ADD OVR REGRESSION VARIABLE TO DISPLAY LIST
        switch domain
            case 1 % None
            case 2 % Sensor
                newregressvar=['Sensor Task ' num2str(j) ' vs Rest'];
            case {3,4} % ESI or fESI
                newregressvar=['Source Task ' num2str(j) ' vs Rest'];
        end

        if ~ismember(newregressvar,regressvar)
            regressvar=sort(vertcat(regressvar,{newregressvar}));
            set(handles.regressvar,'String',regressvar);
        end
        
        % ALSO FOR EACH CLUSTER
        if isequal(domain,3)
            VertIdxStart=1;
            for k=1:NumCluster-1
                VertIdx=VertIdxStart:VertIdxStart+size(cluster{k},2)-1;
                
                if iscell(BaselineData{j})
                    X1=[]; X2=[];
                    for l=1:size(BaselineData{j},2)
                        X1tmp=sum(BaselineData{j}{l}(VertIdx,:))';
                        X1=[X1;X1tmp];
                        X2tmp=sum(TrialData{j}{l}(VertIdx,:))';
                        X2=[X2;X2tmp];
                    end
                else
                    X1=BaselineData{j}(VertIdx,:); X1=sum(X1,1)'; % sum across cluster
                    X2=TrialData{j}(VertIdx,:); X2=sum(X2,1)';
                end
                
                [stats]=LSRegress(X1,X2);
                BOVRc(k,i,j)=stats.B;
                RsqOVRc(k,i,j)=stats.Rsq;
                rOVRc(k,i,j)=stats.r;
                F_statOVRc(k,i,j)=stats.F;
                t_statOVRc(k,i,j)=stats.t;
                p_statOVRc(k,i,j)=stats.p;
                
                VertIdxStart=VertIdx(end)+1;
            end
            
            newregressvar=['Source Cluster Task ' num2str(j) ' vs Rest'];
            if ~ismember(newregressvar,regressvar)
                regressvar=sort(vertcat(regressvar,{newregressvar}));
                set(handles.regressvar,'String',regressvar);
            end
        end

    end
    
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % ONE-vs-ONE (OVO) REGRESSION FOR ALL CHANNELS AND TASK COMBINATIONS
    for j=1:NumComb

        for k=1:NumChan
            
            ChanVal=cell(1,2);   
            for l=1:2
                % If trials are windowed
                if iscell(TrialData{combinations(j,l)})
                    % Go through each trial and concatenate windows
                    for m=1:size(TrialData{combinations(j,l)},2)
                        ChanVal{l}=[ChanVal{l};TrialData{combinations(j,l)}{m}(k,:)'];
                    end
                else
                    % Or select single trial value for each channel
                    ChanVal{l}=TrialData{combinations(j,l)}(k,:)';
                end
            end
            
            X1=ChanVal{1};
            X2=ChanVal{2};
            
            [stats]=LSRegress(X1,X2);
            BOVO(k,i,j)=stats.B;
            RsqOVO(k,i,j)=stats.Rsq;
            rOVO(k,i,j)=stats.r;
            F_statOVO(k,i,j)=stats.F;
            t_statOVO(k,i,j)=stats.t;
            p_statOVO(k,i,j)=stats.p;
            
        end
        
        % ADD OVO REGRESSION VARIABLE TO DISPLAY LIST
        switch domain
            case 1 % None
            case 2 % Sensor
                newregressvar=['Sensor Task ' num2str(combinations(j,1)) ' vs ' num2str(combinations(j,2))];
            case {3,4} % ESI or fESI
                newregressvar=['Source Task ' num2str(combinations(j,1)) ' vs ' num2str(combinations(j,2))];
        end
        
        if ~ismember(newregressvar,regressvar)
            regressvar=sort(vertcat(regressvar,{newregressvar}));
            set(handles.regressvar,'String',regressvar);
            
        end
        
        % ALSO FOR EACH CLUSTER
        if isequal(domain,3)
            VertIdxStart=1;
            for k=1:NumCluster-1
                VertIdx=VertIdxStart:VertIdxStart+size(cluster{k},2)-1;
                
                ChanVal=cell(1,2);   
                for l=1:2
                    % If trials are windowed
                    if iscell(TrialData{combinations(j,l)})
                        % Go through each trial and concatenate windows
                        for m=1:size(TrialData{combinations(j,l)},2)
                            ChanVal{l}=[ChanVal{l};sum(TrialData{combinations(j,l)}{m}(VertIdx,:),1)'];
                        end
                    else
                        % Or select single trial value for each channel
                        ChanVal{l}=sum(TrialData{combinations(j,l)}(VertIdx,:),1)';
                    end
                end

                X1=ChanVal{1};
                X2=ChanVal{2};

%                 X1=sum(ChanVal{1},2);
%                 X2=sum(ChanVal{2},2);
                
                [stats]=LSRegress(X1,X2);
                BOVOc(k,i,j)=stats.B;
                RsqOVOc(k,i,j)=stats.Rsq;
                rOVOc(k,i,j)=stats.r;
                F_statOVOc(k,i,j)=stats.F;
                t_statOVOc(k,i,j)=stats.t;
                p_statOVOc(k,i,j)=stats.p;
                
                VertIdxStart=VertIdx(end)+1;
            end
            
            newregressvar=['Source Cluster Task ' num2str(combinations(j,1)) ' vs ' num2str(combinations(j,2))];
            if ~ismember(newregressvar,regressvar)
                regressvar=sort(vertcat(regressvar,{newregressvar}));
                set(handles.regressvar,'String',regressvar);
            end
        end
    end
    
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % ONE-vs-ALL (OVA) REGRESSION FOR ALL CHANNELS AND TASK COMBINATIONS
    TaskInd=1:NumTask;
    for j=1:NumTask
        
        One=j; All=TaskInd; All(j)=[];
        
        for k=1:NumChan
            
            ChanVal=cell(1,2);
            % If trials are windowed
            if iscell(TrialData{j})

                % Concatenate all windows for task "One"
                for l=1:size(TrialData{j},2)
                    ChanVal{1}=[ChanVal{1};TrialData{One}{l}(k,:)'];
                end

                % Concatenate all windows for task "All"
                for l=1:size(All,2)
                    for m=1:size(TrialData{All(l)},2)
                        ChanVal{2}=[ChanVal{2};TrialData{All(l)}{m}(k,:)'];
                    end
                end

            else

                % Or select single trial value for each channel
                ChanVal{1}=TrialData{One}(k,:)';
                ChanVal{2}=[];
                for l=1:size(All,2)
                    ChanVal{2}=vertcat(ChanVal{2},TrialData{All(l)}(k,:)');
                end

            end
            
            X1=ChanVal{1};
            X2=ChanVal{2};
            
            [stats]=LSRegress(X1,X2);
            BOVA(k,i,j)=stats.B;
            RsqOVA(k,i,j)=stats.Rsq;
            rOVA(k,i,j)=stats.r;
            F_statOVA(k,i,j)=stats.F;
            t_statOVA(k,i,j)=stats.t;
            p_statOVA(k,i,j)=stats.p;
            
        end
        
        % ADD OVA REGRESSION VARIABLE TO DISPLAY LIST
        switch domain
            case 1 % None
            case 2 % Sensor
                newregressvar=['Sensor Task ' num2str(j) ' vs All'];
            case {3,4} % ESI or fESI
                newregressvar=['Source Task ' num2str(j) ' vs All'];
        end

        if ~ismember(newregressvar,regressvar)
            regressvar=sort(vertcat(regressvar,{newregressvar}));
            set(handles.regressvar,'String',regressvar);
        end
        
        % ALSO FOR EACH CLUSTER
        if isequal(domain,3)
            VertIdxStart=1;
            for k=1:NumCluster-1
                VertIdx=VertIdxStart:VertIdxStart+size(cluster{k},2)-1;
                
                ChanVal=cell(1,2);
                if iscell(TrialData{j})
                    
                    for l=1:size(TrialData{j},2)
                        ChanVal{1}=[ChanVal{1};sum(TrialData{One}{l}(VertIdx,:),1)'];
                    end
                    
                    % Concatenate all windows for task "All"
                    for l=1:size(All,2)
                        for m=1:size(TrialData{All(l)},2)
                            ChanVal{2}=[ChanVal{2};sum(TrialData{All(l)}{m}(VertIdx,:),1)'];
                        end
                    end
                    
                else
                    
                    ChanVal{1}=sum(TrialData{One}(VertIdx,:),1)';
                    ChanVal{2}=[];
                    for l=1:size(All,2)
                        ChanVal{2}=vertcat(ChanVal{2},sum(TrialData{All(l)}(VertIdx,:),1)');
                    end
                    
                end

                X1=ChanVal{1};
                X2=ChanVal{2};

                [stats]=LSRegress(X1,X2);
                BOVAc(k,i,j)=stats.B;
                RsqOVAc(k,i,j)=stats.Rsq;
                rOVAc(k,i,j)=stats.r;
                F_statOVAc(k,i,j)=stats.F;
                t_statOVAc(k,i,j)=stats.t;
                p_statOVAc(k,i,j)=stats.p;
                
                VertIdxStart=VertIdx(end)+1;
            end
            
            newregressvar=['Source Cluster Task ' num2str(j) ' vs All'];
            if ~ismember(newregressvar,regressvar)
                regressvar=sort(vertcat(regressvar,{newregressvar}));
                set(handles.regressvar,'String',regressvar);
            end
        end
        
    end

end
close(h)
set(handles.regressvar,'Value',1)
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% SAVE REGRESSION FILES

% Save OVR regression file
switch domain
    case 1 % None
    case 2 % Sensor
        SaveRegressFile=strcat(SaveFileDir,'\Regression_Sensor_One_vs_Rest.mat');
        SaveRegressSensor.B=BOVR;
        SaveRegressSensor.R=rOVR;
        SaveRegressSensor.Rsq=RsqOVR;
        SaveRegressSensor.R=rOVR;
        SaveRegressSensor.F_stat=F_statOVR;
        SaveRegressSensor.t_stat=t_statOVR;
        SaveRegressSensor.pval=p_statOVR;
        SaveRegressSensor.chaninclude=ChanInclude;
        SaveRegressSensor.label='One-vs-Rest';
        save(SaveRegressFile,'SaveRegressSensor','-v7.3');
        
        handles.RegressSensor.sensorfile{1}=SaveRegressFile;
        handles.RegressSensor.sensorlabel{1}='One-vs-Rest';
    case {3,4} % Source
        SaveRegressFile=strcat(SaveFileDir,'\Regression_Source_One_vs_Rest.mat');
        SaveRegressSource.vert.B=BOVR;
        SaveRegressSource.vert.R=rOVR;
        SaveRegressSource.vert.Rsq=RsqOVR;
        SaveRegressSource.vert.R=rOVR;
        SaveRegressSource.vert.F_stat=F_statOVR;
        SaveRegressSource.vert.t_stat=t_statOVR;
        SaveRegressSource.vert.pval=p_statOVR;
        
        SaveRegressSource.cluster.B=BOVRc;
        SaveRegressSource.cluster.R=rOVRc;
        SaveRegressSource.cluster.Rsq=RsqOVRc;
        SaveRegressSource.cluster.R=rOVRc;
        SaveRegressSource.cluster.F_stat=F_statOVRc;
        SaveRegressSource.cluster.t_stat=t_statOVRc;
        SaveRegressSource.cluster.pval=p_statOVRc;
        
        SaveRegressSource.verticesinclude=ChanInclude;
        SaveRegressSource.label='One-vs-Rest';
        save(SaveRegressFile,'SaveRegressSource','-v7.3');
        
        handles.RegressSource.sourcefile{1}=SaveRegressFile;
        handles.RegressSource.sourcelabel{1}='One-vs-Rest';
end

% Save OVO regression file
switch domain
    case 1 % None
    case 2 % Sensor
        SaveRegressFile=strcat(SaveFileDir,'\Regression_Sensor_One_vs_One.mat');
        SaveRegressSensor.B=BOVO;
        SaveRegressSensor.R=rOVO;
        SaveRegressSensor.Rsq=RsqOVO;
        SaveRegressSensor.R=rOVO;
        SaveRegressSensor.F_stat=F_statOVO;
        SaveRegressSensor.t_stat=t_statOVO;
        SaveRegressSensor.pval=p_statOVO;
        
        SaveRegressSensor.totdata=TotDataSensor;
        
        SaveRegressSensor.chaninclude=ChanInclude;
        SaveRegressSensor.comb=combinations;
        SaveRegressSensor.label='One-vs-One';
        save(SaveRegressFile,'SaveRegressSensor','-v7.3');
        
        handles.RegressSensor.sensorfile{2}=SaveRegressFile;
        handles.RegressSensor.sensorlabel{2}=num2str(combinations);
    case {3,4} % Source
        SaveRegressFile=strcat(SaveFileDir,'\Regression_Source_One_vs_One.mat');
        SaveRegressSource.vert.B=BOVO;
        SaveRegressSource.vert.R=rOVO;
        SaveRegressSource.vert.Rsq=RsqOVO;
        SaveRegressSource.vert.R=rOVO;
        SaveRegressSource.vert.F_stat=F_statOVO;
        SaveRegressSource.vert.t_stat=t_statOVO;
        SaveRegressSource.vert.pval=p_statOVO;
        
        SaveRegressSource.cluster.B=BOVOc;
        SaveRegressSource.cluster.R=rOVOc;
        SaveRegressSource.cluster.Rsq=RsqOVOc;
        SaveRegressSource.cluster.R=rOVOc;
        SaveRegressSource.cluster.F_stat=F_statOVOc;
        SaveRegressSource.cluster.t_stat=t_statOVOc;
        SaveRegressSource.cluster.pval=p_statOVOc;
        
        SaveRegressSource.cluster.totdata=TotDataSource;

        SaveRegressSource.verticesinclude=ChanInclude;
        SaveRegressSource.comb=combinations;
        SaveRegressSource.label='One-vs-One';
        save(SaveRegressFile,'SaveRegressSource','-v7.3');
        
        handles.RegressSource.sourcefile{2}=SaveRegressFile;
        handles.RegressSource.sourcelabel{2}=num2str(combinations);
end

% Save OVA regression file
switch domain
    case 1 % None
    case 2 % Sensor
        SaveRegressFile=strcat(SaveFileDir,'\Regression_Sensor_One_vs_All.mat');
        SaveRegressSensor.B=BOVA;
        SaveRegressSensor.R=rOVA;
        SaveRegressSensor.Rsq=RsqOVA;
        SaveRegressSensor.R=rOVA;
        SaveRegressSensor.F_stat=F_statOVA;
        SaveRegressSensor.t_stat=t_statOVA;
        SaveRegressSensor.pval=p_statOVA;
        SaveRegressSensor.chaninclude=ChanInclude;
        SaveRegressSensor.label='One-vs-ALL';
        save(SaveRegressFile,'SaveRegressSensor','-v7.3');
        
        handles.RegressSensor.sensorfile{3}=SaveRegressFile;
        handles.RegressSensor.sensorlabel{3}='One-vs-All';
    case {3,4} % Source
        SaveRegressFile=strcat(SaveFileDir,'\Regression_Source_One_vs_All.mat');
        SaveRegressSource.vert.B=BOVA;
        SaveRegressSource.vert.R=rOVA;
        SaveRegressSource.vert.Rsq=RsqOVA;
        SaveRegressSource.vert.R=rOVA;
        SaveRegressSource.vert.F_stat=F_statOVA;
        SaveRegressSource.vert.t_stat=t_statOVA;
        SaveRegressSource.vert.pval=p_statOVA;
        
        SaveRegressSource.cluster.Beta=BOVAc;
        SaveRegressSource.cluster.R=rOVAc;
        SaveRegressSource.cluster.Rsq=RsqOVAc;
        SaveRegressSource.cluster.R=rOVAc;
        SaveRegressSource.cluster.F_stat=F_statOVAc;
        SaveRegressSource.cluster.t_stat=t_statOVAc;
        SaveRegressSource.cluster.pval=p_statOVAc;
        
        SaveRegressSource.vert.verticesinclude=ChanInclude;
        SaveRegressSource.label='One-vs-All';
        save(SaveRegressFile,'SaveRegressSource','-v7.3');
        
        handles.RegressSource.sourcefile{3}=SaveRegressFile;
        handles.RegressSource.sourcelabel{3}='One-vs-All';
end

% Save regression parameters
switch domain
    case 1 % None
    case 2 % Sensor
        SaveRegressFile=strcat(SaveFileDir,'\Regression_Sensor_Param.mat');
        RegressSensorParam=handles.RegressSensor;
        save(SaveRegressFile,'RegressSensorParam','-v7.3');
    case 3 % ESI
        SaveRegressFile=strcat(SaveFileDir,'\Regression_Source_Param.mat');
        RegressSourceParam=handles.RegressSource;
        save(SaveRegressFile,'RegressSourceParam','-v7.3');
end



function [stats]=LSRegress(X1,X2)

% Create Model
X1=X1(:); X2=X2(:);
X=[X1;X2]; X=[X ones(size(X,1),1)];
Y=[ones(size(X1,1),1);-1*ones(size(X2,1),1)];
[n,p]=size(X); % n DOF Model, n-p DOF error

% Perform least squares inversion
Bfull=inv(X'*X)*X'*Y;
B=Bfull(1);

Y_hat=X*Bfull; % Estimate
e=Y-Y_hat; % Error
norme=norm(e);
SSE=norme.^2; % Sum of Squared Errors

RSS=norm(Y_hat-repmat(mean(Y),[n,1]))^2; % Regression Sum of Squares
TSS=norm(Y-repmat(mean(Y),[n,1]))^2; % Total Sum of Squares
Rsq=1-SSE/TSS; % Coefficient of correlation

if B>0
    r=sqrt(Rsq);
else
    r=-sqrt(Rsq);
end

rmse=norme/sqrt(n-1); % Standard Error
% Statistics
if p>1
    F_stat=(RSS/(p-1))/(rmse^2);
    t_stat=nan;
    p_stat=1-fcdf(F_stat,p-1,n-p);
else
    F_stat=nan;
    t_stat=B/rmse;
    p_stat=1-tcdf(t_stat,n-1);
end

stats.B=B;
stats.Rsq=Rsq;
stats.r=r;
stats.F=F_stat;
stats.t=t_stat;
stats.p=p_stat;



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% PEARSON CORRELATION COEFFICIENT
% % % % % % str = regstats(Y,X,'linear',{'tstat'}); pp(k,i,j)=str.tstat.pval(2); % Least Squares
% % % % % % 
% % % % % % % By Definition
% % % % % % rtmp=cov(X',Y')/std(X)/std(Y);
% % % % % % rOVO(k,i,j)=rtmp(2,2);
% % % % % % 
% % % % % % % BCI2000 Offline Analysis
% % % % % % X=double(ChanVal{1})'; Y=double(ChanVal{2})';
% % % % % % sum1=sum(X); sum2=sum(Y);
% % % % % % n1=length(X); n2=length(Y);
% % % % % % sumsqu1=sum(X.*X);
% % % % % % sumsqu2=sum(Y.*Y);
% % % % % % G=((sum1+sum2)^2)/(n1+n2);
% % % % % % RsqOVO(k,i,j)=(sum1^2/n1+sum2^2/n2-G)/(sumsqu1+sumsqu2-G);
% % % % % % 
% % % % % % covXY=(sum1*n2-sum2*n1);
% % % % % % if covXY>0
% % % % % %     rOVO(k,i,j)=sqrt(RsqOVO(k,i,j));
% % % % % % elseif covXY<0
% % % % % %     rOVO(k,i,j)=-sqrt(RsqOVO(k,i,j));
% % % % % % end
% % % % % % t_statOVO(k,i,j)=sqrt((n1+n2-2)*RsqOVO(k,i,j)/(1-RsqOVO(k,i,j)));
% % % % % % p_statOVO(k,i,j)=1-tcdf(t_statOVO(k,i,j),round(mean(n1,n1))-1);

