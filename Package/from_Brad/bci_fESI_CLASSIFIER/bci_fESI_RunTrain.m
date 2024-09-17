function [hObject,handles]=bci_fESI_RunTrain(hObject,handles)

set(hObject,'userdata',1);

SetSystem=get(handles.SetSystem,'userdata');
if isequal(SetSystem,0)
    set(hObject,'backgroundcolor','red','userdata',0);
    fprintf(2,'MUST SET SYSTEM PARAMATERS TO COLLECT SENSOR TRAINING DATA\n');
end

domain=get(handles.domain,'value');
switch domain
    case 1 % None
        
        fprintf(2,'MUST SELECT A DOMAIN TO COLLECT TRAINING DATA\n');
        set(hObject,'backgroundcolor','red','userdata',0)
        
    case 2 % Sensor

    case 3 % ESI
        
        SetESI=get(handles.SetESI,'userdata');
        if isequal(SetESI,0)
            set(hObject,'backgroundcolor','red','userdata',0);
            fprintf(2,'MUST SET ESI PARAMATERS TO COLLECT SOURCE TRAINING DATA\n');
        end
        
end


if isequal(get(hObject,'userdata'),1)
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % SET UP DISPLAY LABELS/PARAMETERS
    set(hObject,'backgroundcolor','green','userdata',1)
    [hObject,handles]=bci_fESI_Reset(hObject,handles,{'Stop'},[]);
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % READ HEADER FOR FIRST TIME TO ESTABLISH BCI2000 DATA PARAMETERS
    filename='buffer://localhost:1972';
    hdr=ft_read_header(filename,'cache',true);

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % DEFINE SAVE DIRECTORIES
    initials=handles.SYSTEM.initials;
    year=handles.SYSTEM.year;
    month=handles.SYSTEM.month;
    day=handles.SYSTEM.day;
    session=handles.SYSTEM.session;
    subdir=handles.SYSTEM.subdir;
    if ~exist(subdir,'dir')
        mkdir(subdir)
    end
    
    sessiondir=handles.SYSTEM.sessiondir;
    if ~exist(sessiondir,'dir')
        mkdir(sessiondir)
    end
    
    run=get(handles.run,'string');
    rundir=strcat(sessiondir,'\',initials,year,month,day,'S',session,'R',run);
    if ~exist(rundir,'dir')
        mkdir(rundir)
    end

    k=1;
    trainrun='01';
    datsavefile=strcat(sessiondir,'\TRAINING',trainrun,'.mat');
    while exist(datsavefile,'file')
        k=k+1;
        trainrun=num2str(k);
        if size(trainrun,2)<2
            trainrun=strcat('0',trainrun);
        end
        datsavefile=strcat(sessiondir,'\TRAINING',trainrun,'.mat');
    end
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % ESTABLISH BCI CONTROL PARAMETERS
    
    % Define data windows
    fsextract=str2double(handles.SYSTEM.fs);
    dsfactor=handles.SYSTEM.dsfactor;
    fsprocess=fsextract/dsfactor;
    
    ANALYSISWINDOW=250;
    UPDATEWINDOW=100;
    analysiswindowextract=round(ANALYSISWINDOW/1000*fsextract);
    analysiswindowprocess=round(analysiswindowextract/dsfactor);
    updatewindowextract=round(UPDATEWINDOW/1000*fsextract);
    
    % Identify channel indices to include
    chanidx=handles.SYSTEM.Electrodes.chanidxinclude;

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % RECALL FREQUENCY DOMAIN TRANSFORMATION PARAMTERS
    
    % INTRODUCE FITLER COEFFICIENTS
    a=handles.SYSTEM.filter.a;
    b=handles.SYSTEM.filter.b;
    
    % FREQUENCY TRANSFORMATION
    psd=get(handles.psd,'value');
    switch psd
        case 1 % None
        case 2 % Complex Morlet wavelet
            mwparam=handles.SYSTEM.mwparam;
            morwav=handles.SYSTEM.morwav;
            dt=1/mwparam.fs;
            NumFreq=size(mwparam.FreqVect,2);
            A=zeros(NumFreq,analysiswindowprocess,size(chanidx,1));
            
        case 3 % Welch's PSD
%             WelchParam=handles.TFParam.WelchParam;
%             WelchParam.winsize=BlockSize;
%             w=0:1/WelchParam.freqfact:hdr.Fs/2;
%             LowCutoff=str2double(get(handles.LowCutoff,'string'));
%             HighCutoff=str2double(get(handles.HighCutoff,'string'));
%             FreqInterest=find(w>=LowCutoff & w<=HighCutoff);
        case 4 % DFT
%             nfft=2^(nextpow2(BlockSize)+2);
%             fs=str2double(get(handles.fs,'string'));
%             w=0:fs/(nfft):fs-(fs/nfft);
%             LowCutoff=str2double(get(handles.LowCutoff,'string'));
%             HighCutoff=str2double(get(handles.HighCutoff,'string'));
%             FreqInterest=find(w>=LowCutoff & w<=HighCutoff);
    end
    
    switch domain
        case 1 % None
        case 2 % Sensor
        case 3 % ESI
            
            noise=get(handles.noise,'value');
            switch noise
                case {1,2} % None or no noise estimation
                    INV=handles.ESI.inv.nomodel;
                case {3,4} % Diagonal or full noise covariance
                    INVreal=handles.ESI.inv.real;
                    INVimag=handles.ESI.inv.imag;
            end
    end

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % INITIALIZE "Dat" DATA STORAGE STRUCTURE
    Dat.eeg=[];
    Dat.psd.sensor=[];
    Dat.psd.source=[];
    Dat.srateextract=hdr.Fs;
    Dat.srateprocess=fsprocess;
    Dat.begsample=[];
    Dat.endsample=[];
    Dat.winsizeextract=analysiswindowextract;
    Dat.winsizeprocess=analysiswindowprocess;
    Dat.eLoc=handles.SYSTEM.Electrodes.current.eLoc;
    Dat.chanidxinclude=handles.SYSTEM.Electrodes.chanidxinclude;
    Dat.vertidxinclude=handles.ESI.vertidxinclude;
    Dat.numfreq=NumFreq;
    Dat.event.bci2event=[];
	Dat.event.event2bci=[];
    Dat.performance=[];
    
    Performance.targets=cell(1,2);
    Performance.targets(1,:)={'Trial #','Target #'};

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % START REAL TIME STREAMING AND PROCESSING
	Count=0;
	prevsample=1; endsample=0; win=1; null=0; 
    
    stimidx=0; tottrial=1; stimstatus=zeros(4,1); basestatus(1)=1;
    
    runtype=[];
    
    pause(1)
	while isequal(get(hObject,'userdata'),1)
            
        if null<1000 && isequal(get(handles.Stop,'userdata'),0)
            
            % determine number of samples available in buffer
            hdr=ft_read_header2(filename,'cache',true);
            newsamples=(hdr.nSamples*hdr.nTrials-endsample);
            
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            %         DETERMINE WHETHER NEW SAMPLES ARE AVAILABLE         %
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            if newsamples>=updatewindowextract
                tic
                
                % SAMPLES TO PROCESS
                begsample=prevsample+updatewindowextract;
                endsample=begsample+analysiswindowextract-1;
                prevsample=begsample;

                % Remember up to where the data was read
%                 Count=Count+1;
%                 fprintf('processing segment %d from sample %d to %d\n',Count,begsample/hdr.Fs,endsample/hdr.Fs);

                % READ DATA FROM BUFFER
                Data=ft_read_data(filename,'header',hdr,'begsample',...
                    begsample,'endsample',endsample,'chanindx',chanidx);
                
                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                %                    PROCESS RAW DATA                     %
                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                % DOWNSAMPLE DATA
                Data=Data(:,1:dsfactor:end);
                
                % BANDPASS FILTER DATA
                Data=filtfilt(b,a,double(Data'));
                Data=Data';
%                 figure(2);periodogram(Data(1,:),1:size(Data,2),1024,256)
                
                % MEAN-CORRECT DATA
                Data=Data-repmat(mean(Data,2),[1,size(Data,2)]);
                
                % COMMON AVERAGE REFERENCE
                Data=Data-repmat(mean(Data,1),[size(Data,1),1]);
                
                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                %                   FREQUENCY TRANSFORM                   %
                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                switch psd
                    case 1 % None
                    case 2 % Complex Morlet Wavelet
                        
                        for i=1:size(Data,1)
                            for j=1:NumFreq
                                A(j,:,i)=conv2(Data(i,:),morwav{j},'same')*dt;
                            end
                        end
                        Atmp=sum(A,2);
                        
                        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                        %                 SENSOR ANALYSIS                 %
                        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                        % Find magnitude
                        E=abs(Atmp);
                        % Extract all frequencies and broadband info
                        ESensor=zeros(size(chanidx,1),NumFreq+1);
                        for i=1:NumFreq+1
                            if i<=NumFreq
                                ESensor(:,i)=squeeze(E(i,:,:));
                            else
                                ESensor(:,i)=sum(ESensor(:,1:NumFreq),2);
                            end
                        end

                        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                        %                 SOURCE ANALYSIS                 %
                        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                        if isequal(domain,3)
                            
                            ESource=zeros(size(INV,1),NumFreq+1);
                            for i=1:NumFreq+1
                                
                                if i<=NumFreq
                                    
                                    ESourceFreq=Atmp(i,:,:);
                                    ErealSourceFreq=squeeze(real(ESourceFreq));
                                    EimagSourceFreq=squeeze(imag(ESourceFreq));
                                    switch Noise
                                        case {1,2} % None or no noise estimation

                                            Jreal=INV*ErealSourceFreq;
                                            Jimag=INV*EimagSourceFreq;
                                            J=complex(Jreal,Jimag);
                                            ESource(:,i)=abs(J);

                                        case {3,4} % Diagonal or full noise covariance

                                            Jreal=INVreal*ErealSourceFreq;
                                            Jimag=INVimag*EimagSourceFreq;
                                            J=complex(Jreal,Jimag);
                                            ESource(:,i)=abs(J);
                                            
                                    end
                                else
                                    ESource(:,i)=sum(ESource(:,1:NumFreq),2);
                                end
                            end
                        end
                        
                    case 3 % Welch
                    case 4 % DFT
                end
                
                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                %                 READ EVENT FROM BCI2000                 %
                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                BCI2Event=ft_read_event(filename,'header',hdr);
                % DETERMINE STATE OF TRIAL
                if ~isequal(size(BCI2Event),[0 0])
                    
                    % Determine current target, if any
                    if strcmp(BCI2Event(end).type,'StimulusCode') &&...
                            ~isequal(BCI2Event(end).value,0)
                        stimidx=BCI2Event(end).value;
                        Performance.targets(tottrial+1,1)={num2str(tottrial)};
                        Performance.targets(tottrial+1,2)={num2str(stimidx)};
                        Performance.targets
                        if isempty(runtype)
                            runtype='Stimulus';
                        end
                    elseif size(BCI2Event,2)>1 && strcmp(BCI2Event(end-1).type,'StimulusCode') &&...
                        ~isequal(BCI2Event(end-1).value,0)
                        stimidx=BCI2Event(end-1).value;
                        Performance.targets(tottrial+1,1)={num2str(tottrial)};
                        Performance.targets(tottrial+1,2)={num2str(stimidx)};
                        Performance.targets
                        if isempty(runtype)
                            runtype='Stimulus';
                        end
                    elseif strcmp(BCI2Event(end).type,'TargetCode') &&...
                            ~isequal(BCI2Event(end).value,0)
                        stimidx=BCI2Event(end).value;
                        Performance.targets(tottrial+1,1)={num2str(tottrial)};
                        Performance.targets(tottrial+1,2)={num2str(stimidx)};
                        if isempty(runtype)
                            runtype='Cursor';
                        end
                    end
                    
                    
                    % Differentiate trial from baseline
                    if strcmp(BCI2Event(end).type,'StimulusBegin') &&...
                            isequal(BCI2Event(end).value,0) &&...
                            ~isequal(stimidx,0)
                        
                        stimstatus(stimidx,win+1)=1;
                        basestatus(win+1)=0;
                        
                    elseif strcmp(BCI2Event(end).type,'StimulusCode') &&...
                            isequal(BCI2Event(end).value,0)
                        
                        stimstatus(1:4,win+1)=zeros(4,1);
                        basestatus(win+1)=1;
                        
                    elseif strcmp(BCI2Event(end).type,'Feedback') &&...
                            isequal(BCI2Event(end).value,0)
                        
                        stimstatus(1:4,win+1)=zeros(4,1);
                        basestatus(win+1)=0;
                        
                    elseif strcmp(BCI2Event(end).type,'Feedback') &&...
                            isequal(BCI2Event(end).value,1) &&...
                            ~isequal(stimidx,0)
                        
                        stimstatus(stimidx,win+1)=1;
                        basestatus(win+1)=0;
                        
                    elseif strcmp(BCI2Event(end).type,'TargetCode') &&...
                            isequal(BCI2Event(end).value,0)
                        
                        stimstatus(1:4,win+1)=zeros(4,1);
                        basestatus(win+1)=0;
                        
                    else
                        
                        stimstatus(:,win+1)=zeros(4,1);
                        basestatus(win+1)=1;
                        
                    end
                    
                else
                    
                    stimstatus(:,win+1)=zeros(4,1);
                    basestatus(win+1)=1;
                    
                end     

                % Identify end of trial
                if isequal(1,sum(stimstatus(:,win),1)) && isequal(0,sum(stimstatus(:,win+1),1))
                    tottrial=tottrial+1;
                end
%                 [BaseStatus(win+1),StimStatus(1,win+1),StimStatus(2,win+1)]
                
                
                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                %           STORE DATA FROM CURRENT TIME WINDOW           %
                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                Dat(win).eeg=(Data);
                Dat(win).psd.sensor=ESensor;
                if isequal(domain,3)
                    Dat(win).psd.source=ESource;
                else
                    Dat(win).psd.source=[];
                end
                Dat(win).begsample=begsample;
                Dat(win).endsample=endsample;
                Dat(win).stimstatus=stimstatus(:,win+1);
                Dat(win).basestatus=basestatus(win+1);
                Dat(win).event.bci2event=[];
                
                AcceptedEvents={'StimulusCode','StimulusBegin','TargetCode',...
                    'Feedback'};
                
                if ~isequal(size(BCI2Event),[0 0])
                    if ~exist('PrevBCI2Event','var') ||...
                            ~isequal(PrevBCI2Event,BCI2Event(end))
                        if ismember(BCI2Event(end).type,AcceptedEvents)
                            Dat(win).event.bci2event=BCI2Event(end);
                        end
                    end
                    PrevBCI2Event=BCI2Event(end);
                end

                % UPDATE WINDOW COUNT
                win=win+1; null=0;
%                 toc
                
            else
                null=null+1;
            end
            drawnow
            
        else % SAVE PARAMETERS/DATA IF BUFFER CONTAINS NO NEW DATA - END RUN

            Dat(end).performance=Performance;
            Dat(end).runtype=runtype;
            
            set(hObject,'backgroundcolor','red','userdata',0)
            set(handles.Stop,'backgroundcolor','red')

            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            %                        SAVE DATA FILE                       %
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            fprintf(2,'\n     SAVING .MAT FILE FOR CURRENT TRAINING RUN, PLEASE WAIT...\n');
            tic
            save(datsavefile,'Dat','-v7.3');
            fprintf(2,'\n     FINISHED - Time elapsed: %.2f seconds\n\n',toc);
            trainfiles=cellstr(get(handles.trainfiles,'string'));
            trainfiles=[trainfiles;datsavefile];
            trainfiles=trainfiles(~cellfun('isempty',trainfiles)); 
            set(handles.trainfiles,'string',trainfiles,'value',size(trainfiles,1))
            
            set(hObject,'backgroundcolor',[.94 .94 .94])

            Parameters.initials=initials;
            Parameters.session=session;
            Parameters.run=trainrun;
            Parameters.year=year;
            Parameters.month=month;
            Parameters.day=day;
            Parameters.savepath=get(handles.savepath,'string');

            domainstr=cellstr(get(handles.domain,'string'));
            Parameters.spatdomain=domainstr{get(handles.domain,'value')};

            eegsystemstr=cellstr(get(handles.eegsystem,'string'));
            Parameters.eegsystem=eegsystemstr{get(handles.eegsystem,'value')};

            Parameters.srate=fsprocess;
            Parameters.chanidxinclude=handles.SYSTEM.Electrodes.chanidxinclude;
            Parameters.chanidxexclude=handles.SYSTEM.Electrodes.chanidxexclude;

            psdstr=cellstr(get(handles.psd,'string'));
            Parameters.psd=psdstr{get(handles.psd,'value')};

            Parameters.analysiswindow=get(handles.analysiswindow,'string');
            Parameters.updatewindow=get(handles.updatewindow,'string');
            Parameters.lowcutoff=get(handles.lowcutoff,'string');
            Parameters.highcutoff=get(handles.highcutoff,'string');
            Parameters.bufferlength=get(handles.bufferlength,'string');
            
            noisestr=cellstr(get(handles.noise,'string'));
            Parameters.noise=noisestr{get(handles.noise,'value')};
            Parameters.noisefile=get(handles.noisefile);
            
            Parameters.cortexfile=get(handles.cortexfile,'string');
            Parameters.cortexlrfile=get(handles.cortexlrfile,'string');
            Parameters.vizsource=get(handles.vizsource,'value');
            Parameters.lrvizsource=get(handles.lrvizsource,'value');
            Parameters.headmodelfile=get(handles.headmodelfile,'string');
            Parameters.fmrifile=get(handles.fmrifile,'string');
            Parameters.eloc.current=handles.SYSTEM.Electrodes.current.eLoc;
            Parameters.eloc.orig=handles.SYSTEM.Electrodes.original.eLoc;

            ParamSaveFile=strcat(sessiondir,'\TRAINING_Param.mat');
            save(ParamSaveFile,'Parameters','-v7.3');

            guidata(hObject,handles);
            set(handles.Stop,'userdata',0)
                
        end
            
	end
    
elseif isequal(get(hObject,'userdata'),0)
    
    fprintf(2,'PARAMETERS HAVE NOT BEEN SET\n');
    set(hObject,'backgroundcolor','red','userdata',0)
    
end