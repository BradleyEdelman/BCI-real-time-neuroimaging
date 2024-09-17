function [hObject,handles]=bci_fESI_RunBCI20170227(hObject,handles)

if isequal(get(handles.SetBCI,'userdata'),1)
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %                   SET UP DISPLAY LABELS/PARAMETERS                  %
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    set(hObject,'backgroundcolor','green','userdata',1)
    [hObject,handles]=bci_fESI_Reset(hObject,handles,{'Stop'},[]);
    
    domain=get(handles.domain,'value');
    vizelec=get(handles.vizelec,'value');
    vizsource=get(handles.vizsource,'value');
    lrvizsource=get(handles.lrvizsource,'value');
    switch domain
        case 1 % None
        case 2 % Sensor
            
            % ELECTRODE VISUALIZATION
            if isequal(vizelec,1)
                SensorX=handles.SYSTEM.Electrodes.current.plotX;
                SensorY=handles.SYSTEM.Electrodes.current.plotY;
                set(handles.Axis3Label,'string','Scalp Activity');
                axes(handles.axes3);
                Plot.Sensor=scatter(SensorX,SensorY,75,...
                    ones(size(handles.SYSTEM.Electrodes.current.eLoc,2),1),'filled');
                view(-90,90); set(gca,'color',[.94 .94 .94]); axis off
            end
            
        case 3 % ESI
            
            % ELECTRODE VISUALIZATION
            if isequal(vizelec,1)
                SensorX=handles.SYSTEM.Electrodes.current.plotX;
                SensorY=handles.SYSTEM.Electrodes.current.plotY;
                set(handles.Axis2Label,'string','Scalp Activity');
                axes(handles.axes2);
                Plot.Sensor=scatter(SensorX,SensorY,75,...
                    ones(size(handles.SYSTEM.Electrodes.current.eLoc,2),1),'filled');
                view(-90,90); set(gca,'color',[.94 .94 .94]); axis off
            end
            
            % LOW RESOLUTION SOURCE VISUALIZATION
            if isequal(lrvizsource,1)
                SourceFaces=handles.ESI.cortexlr.Faces;
                SourceVertices=handles.ESI.cortexlr.Vertices;
                SourceX=SourceVertices(:,1);
                SourceY=SourceVertices(:,2);
                SourceZ=SourceVertices(:,3);
                lrinterp=handles.ESI.lrinterp;
                set(handles.Axis3Label,'string','Cortical Activity');
                axes(handles.axes3);
                Plot.Source=trisurf(SourceFaces,SourceX,SourceY,SourceZ,...
                    zeros(1,size(SourceVertices,1)));
                set(Plot.Source,'FaceColor','interp','EdgeColor','None',...
                    'FaceLighting','gouraud');
                axis equal; axis off; view(-90,90)
                
            % FULL RESOLUTION SOURCE VISUALIZATION
            elseif isequal(vizsource,1)
                SourceFaces=handles.ESI.cortex.Faces;
                SourceVertices=handles.ESI.cortex.Vertices;
                SourceX=SourceVertices(:,1);
                SourceY=SourceVertices(:,2);
                SourceZ=SourceVertices(:,3);
                set(handles.Axis3Label,'string','Cortical Activity');
                axes(handles.axes3);
                Plot.Source=trisurf(SourceFaces,SourceX,SourceY,SourceZ,...
                    zeros(1,size(SourceVertices,1)));
                set(Plot.Source,'FaceColor','interp','EdgeColor','None',...
                    'FaceLighting','gouraud');
                axis equal; axis off; view(-90,90)
            end
    end
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % CONTROL SIGNAL DISPLAY
    
    % NORMALIZER PARAMETERS
    normidx=handles.BCI.normidx;
    gain=zeros(3,1);
    offset=zeros(3,1);
    scale=zeros(3,1);
    for i=1:3
        if ~isequal(normidx(i),0)
            gainvar=strcat('gain',num2str(normidx(i)));
            gain(i)=str2double(get(handles.(gainvar),'string'));
            offsetvar=strcat('offset',num2str(normidx(i)));
            offset(i)=str2double(get(handles.(offsetvar),'string'));
            scalevar=strcat('scale',num2str(normidx(i)));
            scale(i)=str2double(get(handles.(scalevar),'string'));
        end
    end
    maxscale=max(scale);
    
    dispcs=get(handles.dispcs,'value');
    if isequal(dispcs,1)
        set(handles.Axis1Label,'string','Control Signal');
        axes(handles.axes1);
        Plot.CS(1,1)=plot(1:30,zeros(1,30),'k-.'); hold on
        Plot.CS(1,2)=plot(1:30,zeros(1,30),'r');
        Plot.CS(2,1)=plot(1:30,10*maxscale+zeros(1,30),'k-.'); hold on
        Plot.CS(2,2)=plot(1:30,10*maxscale+zeros(1,30),'g');
        Plot.CS(3,1)=plot(1:30,20*maxscale+zeros(1,30),'k-.'); hold on
        Plot.CS(3,2)=plot(1:30,20*maxscale+zeros(1,30),'b');
        hold off; axis off; ylim([-3*maxscale 20*maxscale+3]);
    end
    
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % READ HEADER FOR FIRST TIME TO ESTABLISH BCI2000 DATA PARAMETERS
    filename='buffer://localhost:1972';
    hdr=ft_read_header(filename,'cache',true);
    
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %                       DEFINE SAVE DIRECTORIES                       %
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
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
    
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %                       DETERMINE TASK PARADIGM                       %
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    tasktype=get(handles.tasktype,'value');
    if isequal(tasktype,4) % Noise Run
        DatSaveFile=strcat(rundir,'\',initials,year,month,day,'S',session,'NOISE_WIN');
    else
        DatSaveFile=strcat(rundir,'\',initials,year,month,day,'S',session,'R',run);
    end
    
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %                       ESTABLISH ESI VARIABLES                       %
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    switch domain
        case 1 % None
        case 2 % Sensor
        case 3 % ESI
            
            clusters=handles.ESI.clusters;
            numcluster=size(clusters,2);
            NumVert=size(handles.ESI.cortex.Vertices,1);
            
            noise=get(handles.noise,'value');
            switch noise
                case {1,2} % None or no noise estimation
                    INV=handles.ESI.inv.nomodel;
                case {3,4} % Diagonal or full noise covariance
                    INVreal=handles.ESI.inv.real;
                    INVimag=handles.ESI.inv.imag;
            end
            JPlot=zeros(NumVert,3);
            J=zeros(numcluster,3);
            
    end
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %                   ESTABLISH BCI CONTROL VARIABLES                   %
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    % IDENTIFY DATA WINDOWS
    analysiswindowextract=handles.BCI.analysiswindowextract;
    analysiswindowprocess=handles.BCI.analysiswindowprocess;
    updatewindowextract=handles.BCI.updatewindowextract;
    dsfactor=handles.SYSTEM.dsfactor;
    fsProcess=handles.BCI.fsprocess;
    
    % IDENTIFY CHANNEL INDICES TO INCLUDE
    chanidx=handles.BCI.chanidxinclude;
    
    % IDENTIFY CONTROL WEIGHTS AND CLASSIFICATION RULES
    bcifreqidx=handles.BCI.control.freqidx;
    bciidx=handles.BCI.control.idx;
    bciweight=handles.BCI.control.w;
    
    % INITIATE CONTROL PARAMETERS
    control=zeros(3,1);
    controlnorm=zeros(3,1);
    controlfilt=zeros(3,1);
    controldisp=zeros(3,1);
    targetID=handles.BCI.targetid;
    
    bufferlength=str2double(get(handles.bufferlength,'string'));
    cyclelength=str2double(get(handles.buffercyclelength,'string'));
    
    
    % INITIATE NORMALIZER UPDATE RULES
    task=handles.BCI.task;
    trialcount=ones(3,1);
    switch task
        case '3D'
            dimused=1:3;
        case '2D'
            dimused=1:2;
            trialcount(3)=2;
        case '1D Horizontal'
            dimused=1;
            trialcount(2)=2; trialcount(3)=2;
        case '1D Vertical'
            dimused=2;
            trialcount(1)=2; trialcount(3)=2;
    end
    
    buffervalues=cell(3,1);
    buffervalues{1}=cell(1); buffervalues{2}=cell(1);  buffervalues{3}=cell(1);
    totalbuffer=cell(3,1);
    
    buffervaluesX=cell(1,2); buffervaluesX{1}=cell(1); buffervaluesX{2}=cell(1);
    buffervaluesY=cell(1,2); buffervaluesY{1}=cell(1); buffervaluesY{2}=cell(1);
    totalbufferX=0; totalbufferY=0;
    
    FixNormVal=get(handles.FixNormVal,'value');
    
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %          RECALL FREQUENCY DOMAIN TRANSFORMATION PARAMTERS           %
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    % INTRODUCE FITLER COEFFICIENTS
    a=handles.SYSTEM.filter.a;
    b=handles.SYSTEM.filter.b;
    
    % FREQUENCY TRANSFORMATION
    psd=handles.BCI.psd;
    switch psd
        case 1 % None
        case 2 % Complex Morlet wavelet
            
            MWParam=handles.SYSTEM.mwparam;
            MorWav=handles.SYSTEM.morwav;
            dt=1/MWParam.fs;
            A=zeros(size(MWParam.FreqVect,2),...
                analysiswindowprocess,size(chanidx,1));
            
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
    
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %               INITIALIZE "Dat" DATA STORAGE STRUCTURE               %
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    Dat.eeg=[];
    Dat.psd.sensor=[];
    Dat.psd.source=[];
    Dat.srateextract=hdr.Fs;
    Dat.srateprocess=fsProcess;
    Dat.begsample=[];
    Dat.endsample=[];
    Dat.winsizeextract=analysiswindowextract;
    Dat.winsizeprocess=analysiswindowprocess;
    Dat.eLoc=handles.SYSTEM.Electrodes.current.eLoc;
    Dat.event.bci2event=[];
	Dat.event.event2bci=[];
    Dat.controlsig.orig=[];
    Dat.controlsig.norm=[];
    Dat.controlsig.filt=[];
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %                     INITIALIZE OUTPUT TO BCI2000                    %
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    Event2BCI.type='Signal';
    Event2BCI.sample=1;
    Event2BCI.offset=0;
    Event2BCI.duration=1;

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %               START REAL TIME STREAMING AND PROCESSING              %
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
	Count=0;
	prevsample=1; endsample=0; win=1; null=0;
    
    feedback(1)=0; targetidx(1)=1;
    
    trialwin=1; target=0;
    
    cyclecountX=ones(1,2); cyclecountY=ones(1,2);
    trialwinX=ones(1,2); trialwinY=ones(1,2);
%     TargetXpos=0; TargetYpos=0; CursorXpos=0; CursorYpos=0;
    
	while get(hObject,'userdata')==1
            
        if null<300 && get(handles.Stop,'userdata')==0
            
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
%                 fprintf('processing segment %d from sample %d to %d\n',...
%                  Count,begsample/hdr.Fs,endsample/hdr.Fs);

                % READ DATA FROM BUFFER
                data=ft_read_data(filename,'header',hdr,'begsample',...
                    begsample,'endsample',endsample,'chanindx',chanidx);
                
                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                %                      PREROCESS DATA                     %
                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                % DOWNSAMPLE DATA
                data=data(:,1:dsfactor:end);
                
                % BANDPASS FILTER DATA
                data=filtfilt(b,a,double(data'));
                data=data';
%                 periodogram(Data(1,:),1:size(Data,2),1024,fsProcess)
                
                % MEAN-CORRECT DATA
                data=data-repmat(mean(data,2),[1,size(data,2)]);
                
                % COMMON AVERAGE REFERENCE
                data=data-repmat(mean(data,1),[size(data,1),1]);
                
                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                %                    FREQUENCY TRANSFORM                  %
                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                switch psd
                    case 1 % None
                    case 2 % Complex Morlet Wavelet
                        
                        for i=1:size(data,1)
                            for j=1:size(MWParam.FreqVect,2)
                                A(j,:,i)=conv2(data(i,:),MorWav{j},'same')*dt;
                            end
                        end
                        
                        % Sum across time window
                        Atmp=sum(A,2);
                        
                        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                        %                 SENSOR ANALYSIS                 %
                        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                        % Find magnitude
                        E=abs(Atmp);
                        % Extract frequency(s) of interest and add
                        ESensor=zeros(size(chanidx,1),3);
                        for i=dimused
                            EDim=E(cell2mat(bcifreqidx(i)),:,:);
                            % Sum across frequencies
                            EDim=sum(EDim,1);
                            ESensor(:,i)=squeeze(EDim);
                        end
                        
                        % Update and visualize sensor activity
                        if isequal(vizelec,1) && ~isequal(domain,3)
                            set(Plot.Sensor,'CData',squeeze(sum(sum(E,1),2)));
                        end
                        
                        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                        %                 SOURCE ANALYSIS                 %
                        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                        if isequal(domain,3)
                            
                            for i=dimused
                                % Transform each frequency before taking magntidue  
                                ESourceFreq=Atmp(cell2mat(bcifreqidx(i)),:,:);
                                ErealSourceFreq=squeeze(real(ESourceFreq));
                                EimagSourceFreq=squeeze(imag(ESourceFreq));

                                switch noise
                                    case {1,2} % None or no noise estimation

                                        for j=1:numcluster
                                            Jreal=INV{j}*ErealSourceFreq;
                                            Jimag=INV{j}*EimagSourceFreq;
                                            Jtmp=complex(Jreal,Jimag);
                                            JPlot(clusters{j},i)=abs(Jtmp);
                                            J(j,i)=sum(abs(Jtmp),1);
                                        end

                                    case {3,4} % Diagonal or full noise covariance

                                        for j=1:numcluster
                                            Jreal=INVreal{j}*ErealSourceFreq;
                                            Jimag=INVimag{j}*EimagSourceFreq;
                                            Jtmp=complex(Jreal,Jimag);
                                            JPlot(clusters{j},i)=abs(Jtmp);
                                            J(j,i)=sum(abs(Jtmp),1);
                                        end
                                end
                            end
                            
                            % Update and visualize sensor activity
                            if isequal(vizelec,1)
                                set(Plot.Sensor,'CData',squeeze(sum(sum(E,1),2)));
                            end
                            
                            % Update and visualize source activity
                            if isequal(vizsource,1)
                                JPlot2=sum(JPlot,2);
                                JPlot2(handles.ESI.vertidxexclude)=0;
                                if isequal(lrvizsource,1)
                                    set(Plot.Source,'CData',lrinterp*JPlot2');
                                else
                                    set(Plot.Source,'CData',JPlot2);
                                end
                            end
                            
                        end
                        
                    case 3 % Welch
                    case 4 % DFT
                end
                
                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                %                 COMPUTE CONTROL SIGNAL                  %
                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                switch domain
                    case 1 % None
                    case 2 % Sensor
                        
                        for i=dimused
                            if ~isempty(bciidx{i})
                                control(i)=ESensor(bciidx{i},i)'*bciweight{i};
                            end
                        end
                        
                    case {3,4} % ESI
                        
                        for i=dimused
                            if ~isempty(bciidx{i})
                                control(i)=J(bciidx{i},i)'*bciweight{i};
                            end
                        end
                        
                end
                
                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                %                 READ EVENT FROM BCI2000                 %
                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                BCI2Event=ft_read_event(filename,'header',hdr);
                % DETERMINE STATE OF TRIAL
%                 if isequal(size(BCI2Event),[0 0]) ||...
%                         strcmp(BCI2Event(end).type,'TargetCode') ||...
%                         strcmp(BCI2Event(end).type,'Signal')
%                     output=[0 0 0];
%                     feedback(win+1)=0;
%                 elseif strcmp(BCI2Event(end).type,'TargetCode') &&...
%                         ~isequal(BCI2Event(end).value,0);
%                     target=BCI2Event(end).value;
%                     feedback(win+1)=0;
%                 else
%                     feedback(win+1)=1;
%                 end
                
                if ~isequal(size(BCI2Event),[0 0])
                    type=BCI2Event(end).type;
                    value=BCI2Event(end).value;
                    output=[0 0 0];
                    feedback(win+1)=0;
                    targetidx(win+1)=0;
                    
                    if strcmp(type,'TargetCode') && ~isequal(value,0)
                        target=value;
                        
                    elseif strcmp(type,'TargetCode') && isequal(value,0)
                        
                        
                    elseif strcmp(type,'Feedback') && isequal(value,0)
                        targetidx(win+1)=0;
                        
                    else
                        feedback(win+1)=1;
                        targetidx(win+1)=target;
                    end
                else
                    feedback(win+1)=0;
                    targetidx(win+1)=0;
                end
                
                [feedback(win+1) targetidx(win+1)]
                
                % DETERMINE CURRENT TARGET LOCATION
                if ~isequal(size(BCI2Event),[0 0]) &&...
                        strcmp(BCI2Event(end).type,'TargetCode') &&...
                        ~isequal(BCI2Event(end).value,0);
                    target=BCI2Event(end).value;
                end
                
                
                if isequal(tasktype,2)
                    recentevent=BCI2Event(end-9:end);
                    recenteventtype={recentevent.type};
                    recenteventvalue=cell2mat({recentevent.value});
                        
                    for i=1:size(recentevent,2)
                        if strcmp(recenteventtype{i},'Target_PosX_u')
                            targetXpos=recenteventvalue(i);
                        elseif strcmp(recenteventtype{i},'Target_PosY_u')
                            targetYpos=recenteventvalue(i);
                        elseif strcmp(recenteventtype{i},'Cursor_PosX_u')
                            cursorXpos=recenteventvalue(i);
                        elseif strcmp(recenteventtype(i),'Cursor_PosY_u')
                            cursorYpos=recenteventvalue(i);
                        end
                    end
                    
                    if isequal(win,1)
                        
                        if exist('targetXpos','var') && ~exist('targetYpos','var')
                            targetYpos=round(targetXpos/10)*10;
                            cursorXpos=round(targetXpos/10)*10;
                            cursorYpos=round(targetXpos/10)*10;
                            squsize=round(targetXpos/10)*10*2;
                        elseif exist('targetYpos','var') && ~exist('targetXpos','var')
                            targetXpos=round(targetYpos/10)*10;
                            cursorXpos=round(targetXpos/10)*10;
                            cursorYpos=round(targetXpos/10)*10;
                            squsize=round(targetXpos/10)*10*2;
                        elseif exist('targetYpos','var') && exist('targetXpos','var')
                            cursorXpos=round(mean([targetYpos targetXpos])/10)*10;
                            cursorYpos=round(mean([targetYpos targetXpos])/10)*10;
                            squsize=round(mean([targetYpos targetXpos])/10)*10*2;
                        end
                    end

                    Xdiff=cursorXpos-targetXpos;
                    Ydiff=cursorYpos-targetYpos;

%                     figure(1);
%                     scatter(CursorXpos,CursorYpos,100*pi,'r','filled');
%                     hold on
%                     scatter(TargetXpos,TargetYpos,1600*pi,'b','filled');
%                     hold off
%                     axis([0 squsize 0 squsize]);
                        
                end
                
                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                %                   STORE CONTROL SIGNAL                  %
                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                switch tasktype
                    
                    case 1 % None
                        
                    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                    %                    CONTINUOUS BCI                   %
                    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                    case 2
                        
                        % STORE DURING CURSOR MOVEMENT
                        if isequal(feedback(win+1),1) && isequal(feedback(win),1)
                            
                            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                            %            HORIZONTAL DIMENSION             %
                            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                            if ismember(1,dimused)
                                
                                % CURSOR TO RIGHT OF TARGET (LEFT IMAGINATION)
                                if trialwinX(1)<=cyclelength && Xdiff>0
                                    
                                    buffervaluesX{1}{cyclecountX(1)}(trialwinX(1))=control(1);
                                    trialwinX(1)=trialwinX(1)+1;
                                    
                                elseif trialwinX(1)>cyclelength && Xdiff>0
                                    
                                    mincycleX=min(cyclecountX);
                                    
                                    buffervaluesXpos=horzcat(buffervaluesX{1}{end-mincycleX+1:end});
                                    buffervaluesXneg=horzcat(buffervaluesX{2}{end-mincycleX+1:end});
                                    totalbufferX=[buffervaluesXpos buffervaluesXneg];
                                    totalbufferX(totalbufferX==0)=[];
                                    trialwinX(1)=1;
                                    
                                    cyclecountX(1)=cyclecountX(1)+1;
                                    if cyclecountX(1)>bufferlength
                                        buffervaluesX{1}=circshift(buffervaluesX{1},[0 -1]);
                                        cyclecountX(1)=bufferlength;
                                        buffervaluesX{1}{cyclecountX(1)}=[];
                                    elseif cyclecountX(1)<bufferlength
                                        buffervaluesX{1}{cyclecountX(1)}=[];
                                    end
                                    
                                end
                                
                                % CURSOR TO LEFT OF TARGET (RIGHT IMAGINATION)
                                if trialwinX(2)<=cyclelength && Xdiff<0
                                    
                                    buffervaluesX{2}{cyclecountX(2)}(trialwinX(2))=control(1);
                                    trialwinX(2)=trialwinX(2)+1;
                                    
                                elseif trialwinX(2)>cyclelength && Xdiff<0
                                    
                                    mincycleX=min(cyclecountX);
                                    
                                    buffervaluesXpos=horzcat(buffervaluesX{1}{end-mincycleX+1:end});
                                    buffervaluesXneg=horzcat(buffervaluesX{2}{end-mincycleX+1:end});
                                    totalbufferX=[buffervaluesXpos buffervaluesXneg];
                                    totalbufferX(totalbufferX==0)=[];
                                    trialwinX(2)=1;
                                    
                                    cyclecountX(2)=cyclecountX(2)+1;
                                    if cyclecountX(2)>bufferlength
                                        buffervaluesX{2}=circshift(buffervaluesX{2},[0 -1]);
                                        cyclecountX(2)=bufferlength;
                                        buffervaluesX{2}{cyclecountX(2)}=[];
                                    elseif cyclecountX(2)<bufferlength
                                        buffervaluesX{2}{cyclecountX(2)}=[];
                                    end
                                    
                                end
                                
                            end
                            
                            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                            %             VERTICAL DIMENSION              %
                            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                            if ismember(2,dimused)
                                
                                % CURSOR TO ABOVE TARGET (DOWN IMAGINATION)
                                if trialwinY(1)<=cyclelength && Ydiff>0
                                    
                                    buffervaluesY{1}{cyclecountY(1)}(trialwinY(1))=control(2);
                                    trialwinY(1)=trialwinY(1)+1;
                                    
                                elseif trialwinY(1)>cyclelength && Ydiff>0
                                    
                                    mincycleY=min(cyclecountY);
                                    
                                    buffervaluesYpos=horzcat(buffervaluesY{1}{end-mincycleY+1:end});
                                    buffervaluesYneg=horzcat(buffervaluesY{2}{end-mincycleY+1:end});
                                    totalbufferY=[buffervaluesYpos buffervaluesYneg];
                                    totalbufferY(totalbufferY==0)=[];
                                    trialwinY(1)=1;
                                    
                                    cyclecountY(1)=cyclecountY(1)+1;
                                    if cyclecountY(1)>bufferlength
                                        buffervaluesY{1}=circshift(buffervaluesY{1},[0 -1]);
                                        cyclecountY(1)=bufferlength;
                                        buffervaluesY{1}{cyclecountY(1)}=[];
                                    elseif cyclecountY(1)<bufferlength
                                        buffervaluesY{1}{cyclecountY(1)}=[];
                                    end
                                    
                                end
                                
                                % CURSOR TO BELOW TARGET (UP IMAGINATION)
                                if trialwinY(2)<=cyclelength && Ydiff<0
                                    
                                    buffervaluesY{2}{cyclecountY(2)}(trialwinY(2))=control(2);
                                    trialwinY(2)=trialwinY(2)+1;
                                    
                                elseif trialwinY(2)>cyclelength && Ydiff<0
                                    
                                    mincycleY=min(cyclecountY);
                                    
                                    buffervaluesYpos=horzcat(buffervaluesY{1}{end-mincycleY+1:end});
                                    buffervaluesYneg=horzcat(buffervaluesY{2}{end-mincycleY+1:end});
                                    totalbufferY=[buffervaluesYpos buffervaluesYneg];
                                    totalbufferY(totalbufferY==0)=[];
                                    trialwinY(2)=1;
                                    
                                    cyclecountY(2)=cyclecountY(2)+1;
                                    if cyclecountY(2)>bufferlength
                                        buffervaluesY{2}=circshift(buffervaluesY{2},[0 -1]);
                                        cyclecountY(2)=bufferlength;
                                        buffervaluesY{2}{cyclecountY(2)}=[];
                                    elseif cyclecountY(2)<bufferlength
                                        buffervaluesY{2}{cyclecountY(2)}=[];
                                    end
                                    
                                end
                            
                            end
                        end
                               

                    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                    %                   TRADITIONAL BCI                   %
                    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                    case 3
                        
                        % STORE DURING CURSOR MOVEMENT
                        if isequal(feedback(win+1),1) && isequal(feedback(win),1)

                            if ismember(target,targetID{1})
                                buffervalues{1}{trialcount(1)}(trialwin)=control(1);
                            elseif ismember(target,targetID{2})
                                buffervalues{2}{trialcount(2)}(trialwin)=control(2);
                            elseif ismember(target,targetID{3})
                                buffervalues{3}{trialcount(3)}(trialwin)=control(3);
                            end
                            trialwin=trialwin+1;
                            
                        % UPDATE NORMALIZER AFTER TRIAL ENDS
                        elseif isequal(feedback(win+1),0) && isequal(feedback(win),1) % End of trial

                            if ismember(target,targetID{1})
                                trialcount(1)=trialcount(1)+1;
                                if trialcount(1)>bufferlength 
                                    buffervalues{1}=circshift(buffervalues{1},[0 -1]);
                                    trialcount(1)=bufferlength;
                                    buffervalues{1}{trialcount(1)}=[];
                                end
                            elseif ismember(target,targetID{2})
                                trialcount(2)=trialcount(2)+1;
                                if trialcount(2)>bufferlength
                                    buffervalues{2}=circshift(buffervalues{2},[0 -1]);
                                    trialcount(2)=bufferlength;
                                    buffervalues{2}{trialcount(1)}=[];
                                end
                            elseif ismember(target,targetID{3})
                                trialcount(3)=trialcount(3)+1;
                                if trialcount(3)>bufferlength
                                    buffervalues{3}=circshift(buffervalues{3},[0 -1]);
                                    trialcount(3)=bufferlength;
                                    buffervalues{3}{trialcount(3)}=[];
                                end
                            end

                            for i=dimused
                                totalbuffer{i}=cell2mat(buffervalues{i});
                                totalbuffer{i}(totalbuffer{i}==0)=[];
                            end
                            trialwin=1;

                        end
                end
                
                % DETERMINE IF SUFFICIENT BUFFER DATA HAS BEEN STORED
                if isequal(FixNormVal,1)
                    Go=1;
                else
                    
                    switch tasktype
                        case 1 % None
                        case 2 % Continuous BCI
                            
                            if ismember(1,dimused) && isequal(offset(1),0)
                                if ~isequal(cyclecountX,[1 1])
                                    Go=1;
                                else
                                    Go=0;
                                end
                            elseif ismember(1,dimused) && ~isequal(offset(1),0)
                                Go=1;
                            end
                            
                            if ismember(2,dimused) && isequal(offset(2),0)
                                if ~isequal(cyclecountY,[1 1])
                                    Go=1;
                                else
                                    Go=0;
                                end
                            elseif ismember(2,dimused) && ~isequal(offset(2),0)
                                Go=1;
                            end
                            
                        case 3 % Traditional BCI
                            if ~ismember(1,trialcount); Go=1; else Go=0; end
                    end
                    
                end
                
                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                %                PROCESS CONTROL SIGNAL                   %
                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                T=2;
                if isequal(Go,1) % No control signal for first trial
                    
                    switch tasktype
                        case 1 % None
                        case 2 % Continuous BCI
                            
                            % NORMALIZE CONTROL SIGNAL
                            if isequal(FixNormVal,0)
                                
                                if ~isequal(totalbufferX,0)
                                    
                                    offset(1)=mean(totalbufferX);
                                    gain(1)=1/std(totalbufferX);
                                    
                                end
                                
                                if ~isequal(totalbufferY,0)
                                    
                                    offset(2)=mean(totalbufferY);
                                    gain(2)=1/std(totalbufferY);
                                    
                                end
                                
                            end
                            
                            if ismember(1,dimused)
                                controlnorm(1,win)=scale(1)*(control(1)-offset(1))*gain(1);
                            end
                            
                            if ismember(2,dimused)
                                controlnorm(2,win)=scale(2)*(control(2)-offset(2))*gain(2);
                            end
                            
                            for i=dimused
                                if isequal(win,1)
                                    controlfilt(i)=(1-exp(-1/T))*controlnorm(i,win);
                                else
                                    controlfilt(i)=exp(-1/T)*controlnorm(i,win-1)+(1-exp(-1/T))*controlnorm(i,win);
                                end

                                if isnan(controlfilt(i))
                                    controlfilt(i)=0;
                                elseif controlfilt(i)>5
                                    controlfilt(i)=5;
                                elseif controlfilt(i)<-5
                                    controlfilt(i)=-5;
                                end
                            end
                            
                        case 3 % Traditional BCI
                    
                            % NORMALIZE CONTROL SIGNAL
                            if isequal(FixNormVal,0)
                                for i=dimused
                                    offset(i)=mean(totalbuffer{i});
                                    gain(i)=1/std(totalbuffer{i});
                                end
                            end

                            % FILTER CONTROL SIGNAL
                            for i=dimused
                                controlnorm(i,win)=scale(i)*(control(i)-offset(i))*gain(i);
                                if isequal(win,1)
                                    controlfilt(i)=(1-exp(-1/T))*controlnorm(i,win);
                                else
                                    controlfilt(i)=exp(-1/T)*controlnorm(i,win-1)+(1-exp(-1/T))*controlnorm(i,win);
                                end

                                if isnan(controlfilt(i))
                                    controlfilt(i)=0;
                                elseif controlfilt(i)>5
                                    controlfilt(i)=5;
                                elseif controlfilt(i)<-5
                                    controlfilt(i)=-5;
                                end
                            end
                    end
                    
                else
                    controlnorm(:,win)=zeros(3,1);
                    controlfilt=zeros(3,1);
                end
                
                output=controlfilt; %output(3)=100
                
                % Continuous paradigm only accepts two control dimensions
                if isequal(tasktype,2)
                    output(3)=[];
                end

                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                %           SEND CONTROL SIGNAL BACK TO BCI2000           %
                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                Event2BCI.value=output;
                % Only send control signal during cursor control (feedback)
                if isequal(feedback(win+1),1)
                    ft_write_event(filename,Event2BCI);
                end
                
                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                %              DISPLAY (LINEAR) CONTROL SIGNAL            %
                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                if isequal(dispcs,1)
                    
                    if win>30
                        controldisp=circshift(controldisp,[0 -1]);
                        controldisp(:,end)=controlfilt;
                    else
                        controldisp(:,win)=controlfilt;
                    end
                    
                    set(Plot.CS(1,1),'XData',1:size(controldisp,2),'YData',...
                        zeros(1,size(controldisp,2)));
                    set(Plot.CS(1,2),'XData',1:size(controldisp,2),'YData',...
                        controldisp(1,:),'Color','b');
                    
                    set(Plot.CS(2,1),'XData',1:size(controldisp,2),'YData',...
                        10*maxscale+zeros(1,size(controldisp,2)));
                    set(Plot.CS(2,2),'XData',1:size(controldisp,2),'YData',...
                        10*maxscale+controldisp(2,:),'Color','g');
                    
                    set(Plot.CS(3,1),'XData',1:size(controldisp,2),'YData',...
                        20*maxscale+zeros(1,size(controldisp,2)));
                    set(Plot.CS(3,2),'XData',1:size(controldisp,2),'YData',...
                        20*maxscale+controldisp(3,:),'Color','r');
                    
                end
                
                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                %     STORE (AND SAVE) DATA FROM CURRENT TIME WINDOW      %
                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                Dat.eeg{win}=(data);
                Dat.psd.sensor{win}=squeeze(E)';
                if isequal(domain,3)
                    Dat.psd.source{win}=(J);
                end
                Dat.begsample{win}=begsample;
                Dat.endsample{win}=endsample;
                Dat.controlsig.orig{win}=control;
                Dat.controlsig.norm{win}=controlnorm(:,win);
                Dat.controlsig.filt{win}=controlfilt;
                Dat.feedback{win}=feedback(win);
                Dat.targetidx{win}=targetidx(win);
                Dat.event.bci2event{win}=[];

                if exist('targetXpos','var') && exist('targetYpos','var')
                    Dat.targetpos{win}=[targetXpos targetYpos];
                end

                if exist('cursorXpos','var') && exist('cursorYpos','var')
                    Dat.cursorpos{win}=[cursorXpos cursorYpos];
                end

                if ~isequal(size(BCI2Event),[0 0])
                    if ~exist('PrevBCI2Event','var') ||...
                            ~isequal(PrevBCI2Event,BCI2Event(end))
                        if strcmp(BCI2Event(end).type,'TargetCode') &&...
                                isequal(BCI2Event(end).value,0)
                        else
                            Dat.event.bci2event{win}=BCI2Event(end);
                        end
                    end
                    PrevBCI2Event=BCI2Event(end);
                end
                Dat.event.event2bci{win}=Event2BCI;
                
                win=win+1; null=0;
%                 toc
            else
                null=null+1;
            end
            drawnow
            
            
        else % SAVE PARAMETERS/DATA IF BUFFER CONTAINS NO NEW DATA - END RUN
            
            
            set(hObject,'backgroundcolor','red','userdata',0)
            set(handles.Stop,'backgroundcolor','red')
            drawnow
            
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            % SAVE
            if ~isequal(task,4)
                fprintf(2,'\n     SAVING .MAT FILE FOR CURRENT RUN, PLEASE WAIT...\n');
                tic
                SaveFile=strcat(DatSaveFile,'.mat');
                save(SaveFile,'Dat','-v7.3');
                fprintf(2,'\n     FINISHED - Time elapsed: %.2f seconds\n\n',toc);
            end
            set(hObject,'BackgroundColor',[.94 .94 .94])

            Parameters.initials=initials;
            Parameters.session=session;
            Parameters.run=run;
            Parameters.year=year;
            Parameters.month=month;
            Parameters.day=day;
            Parameters.savepath=get(handles.savepath,'string');

            tasktypestr=get(handles.tasktype,'string');
            Parameters.tasktype=tasktypestr{get(handles.tasktype,'value')};

            domainstr=get(handles.domain,'string');
            Parameters.domain=domainstr{get(handles.domain,'value')};

            eegsystemstr=get(handles.eegsystem,'string');
            Parameters.eegsystem=eegsystemstr{get(handles.eegsystem,'value')};

            Parameters.srate=get(handles.fs,'string');
            Parameters.chanidxinclude=handles.SYSTEM.Electrodes.chanidxinclude;
            Parameters.chanidxexclude=handles.SYSTEM.Electrodes.chanidxexclude;
            
            Parameters.bcifreqidx=bcifreqidx;
            Parameters.bciidx=bciidx;
            Parameters.bciweight=bciweight;

            psdstr=get(handles.psd,'string');
            Parameters.psd=psdstr{get(handles.psd,'value')};

            Parameters.analysiswindow=get(handles.analysiswindow,'string');
            Paramaters.updatewindow=get(handles.updatewindow,'string');
            Parameters.lowcutoff=get(handles.lowcutoff,'string');
            Parameters.highcutoff=get(handles.highcutoff,'string');
            Parameters.cyclelength=get(handles.buffercyclelength,'string');
            Parameters.bufferlength=get(handles.bufferlength,'string');
            Parameters.gain=gain;
            Parameters.offset=offset;
            Parameters.scale=scale;

            for i=1:3
                if ~isequal(normidx(i),0)
                    gainvar=strcat('gain',num2str(normidx(i)));
                    set(handles.(gainvar),'string',num2str(gain(i)));
                    offsetvar=strcat('offset',num2str(normidx(i)));
                    set(handles.(offsetvar),'string',num2str(offset(i)));
                end
            end

            noisestr=get(handles.noise,'string');
            Parameters.noise=noisestr{get(handles.noise,'value')};
            Paramters.noisefile=get(handles.noisefile,'string');
            
            Parameters.cortexfile=get(handles.cortexfile,'string');
            Parameters.cortexlrfile=get(handles.cortexlrfile,'string');
            Parameters.vizsource=get(handles.vizsource,'value');
            Parameters.lrvizsource=get(handles.lrvizsource,'value');
            Parameters.headmodelfile=get(handles.headmodelfile,'string');
            Parameters.fmrifile=get(handles.fmrifile,'string');
            Parameters.eloc.current=handles.SYSTEM.Electrodes.current.eLoc;
            Parameters.eloc.orig=handles.SYSTEM.Electrodes.original.eLoc;

            SaveFile=strcat(rundir,'\',initials,year,month,day,'S',session,'R',run,'Param.mat');
            save(SaveFile,'Parameters','-v7.3');

            run=str2double(run);
            run=run+1;
            Length=size(num2str(run),2);
            if Length<2
                run=strcat('0',num2str(run));
            else
                run=num2str(run);
            end
            set(handles.run,'string',run)

            guidata(hObject,handles);
            set(handles.Stop,'userdata',0)
                
        end
            
	end
    
elseif isequal(get(handles.SetBCI,'userdata'),0)
    
    fprintf(2,'PARAMETERS HAVE NOT BEEN SET\n');
    set(hObject,'backgroundcolor','red','userdata',0)
    
end