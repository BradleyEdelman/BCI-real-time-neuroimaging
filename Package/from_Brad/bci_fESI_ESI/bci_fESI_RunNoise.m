function [hObject,handles]=bci_fESI_RunNoise(hObject,handles)

set(hObject,'userdata',1);

SetSystem=get(handles.SetSystem,'userdata');
if isequal(SetSystem,0)
    set(hObject,'backgroundcolor','red','userdata',0);
    fprintf(2,'MUST SET SYSTEM PARAMATERS TO COLLECT SENSOR TRAINING DATA\n');
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
    noiserun='01';
    DatSaveFile=strcat(sessiondir,'\NOISE',noiserun,'.mat');
    while exist(DatSaveFile,'file')
        k=k+1;
        noiserun=num2str(k);
        if size(noiserun,2)<2
            noiserun=strcat('0',noiserun);
        end
        DatSaveFile=strcat(sessiondir,'\NOISE',noiserun,'.mat');
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
            numfreq=size(mwparam.FreqVect,2);
            A=zeros(numfreq,analysiswindowprocess,size(chanidx,1));
            
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
    % INITIALIZE "Dat" DATA STORAGE STRUCTURE
    Dat.eeg=[];
    Dat.psd.Sensor=[];
    Dat.srateextract=hdr.Fs;
    Dat.srateprocess=fsprocess;
    Dat.begsample=[];
    Dat.endsample=[];
    Dat.winsizeextract=analysiswindowextract;
    Dat.winsizeprocess=analysiswindowprocess;
    Dat.eLoc=handles.SYSTEM.Electrodes.current.eLoc;
    Dat.chanidxinclude=handles.SYSTEM.Electrodes.chanidxinclude;
    Dat.numfreq=numfreq;


    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % START REAL TIME STREAMING AND PROCESSING
	Count=0;
	PrevSample=1; endsample=0; win=1; null=0; 

    pause(1)
	while isequal(get(hObject,'userdata'),1)
            
        if null<1000 && isequal(get(handles.Stop,'userdata'),0)
            
            % determine number of samples available in buffer
            hdr=ft_read_header2(filename,'cache',true);
            NewSamples=(hdr.nSamples*hdr.nTrials-endsample);
            
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            %         DETERMINE WHETHER NEW SAMPLES ARE AVAILABLE         %
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            if NewSamples>=updatewindowextract
                
                if isequal(rem(win,5),1)
                    set(handles.noisefile,'backgroundcolor','yellow')
                elseif isequal(rem(win,4),1)
                    set(handles.noisefile,'backgroundcolor','magenta')
                elseif isequal(rem(win,3),1)
                    set(handles.noisefile,'backgroundcolor','cyan')
                elseif isequal(rem(win,2),1)
                    set(handles.noisefile,'backgroundcolor','white')
                else
                    set(handles.noisefile,'backgroundcolor',[1 .7 0])
                end
                drawnow
                
                tic
                
                % SAMPLES TO PROCESS
                begsample=PrevSample+updatewindowextract;
                endsample=begsample+analysiswindowextract-1;
                PrevSample=begsample;

                % Remember up to where the data was read
                Count=Count+1;
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
                            for j=1:numfreq
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
                        ESensor=zeros(size(chanidx,1),numfreq+1);
                        for i=1:numfreq+1
                            if i<=numfreq
                                ESensor(:,i)=squeeze(E(i,:,:));
                            else
                                ESensor(:,i)=sum(ESensor(:,1:numfreq),2);
                            end
                        end                        
                        
                    case 3 % Welch
                    case 4 % DFT
                end

               
                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                %           STORE DATA FROM CURRENT TIME WINDOW           %
                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                Dat(win).eeg=Data;
                Dat(win).psd.Sensor=ESensor;
                Dat(win).begsample=begsample;
                Dat(win).endsample=endsample;
                
                % UPDATE WINDOW COUNT
                win=win+1; null=0;
                
            else
                null=null+1;
            end
            
            
        else % SAVE PARAMETERS/DATA IF BUFFER CONTAINS NO NEW DATA - END RUN
            
            set(hObject,'backgroundcolor','red','userdata',0)
            set(handles.Stop,'backgroundcolor','red')

            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            %                        SAVE DATA FILE                       %
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            fprintf(2,'\n     SAVING .MAT FILE FOR CURRENT NOISE RUN, PLEASE WAIT...\n');
            tic
            save(DatSaveFile,'Dat','-v7.3');
            fprintf(2,'\n     FINISHED - Time elapsed: %.2f seconds\n\n',toc);
            set(handles.noisefile,'string',DatSaveFile);
            set(hObject,'backgroundcolor',[.94 .94 .94])

            Parameters.initials=initials;
            Parameters.session=session;
            Parameters.run=noiserun;
            Parameters.year=year;
            Parameters.month=month;
            Parameters.day=day;
            Parameters.savepath=get(handles.savepath,'string');

            EEGsystemStr=cellstr(get(handles.eegsystem,'string'));
            Parameters.eegsystem=EEGsystemStr{get(handles.eegsystem,'value')};

            Parameters.srate=handles.SYSTEM.fs;
            Parameters.dssrate=handles.SYSTEM.fs/handles.SYSTEM.dsfactor;
            Parameters.chanidxinclude=handles.SYSTEM.Electrodes.chanidxinclude;
            Parameters.chanidxexclude=handles.SYSTEM.Electrodes.chanidxexclude;

            PSDStr=cellstr(get(handles.psd,'string'));
            Parameters.psd=PSDStr{get(handles.psd,'value')};

            Parameters.analysiswindow=get(handles.analysiswindow,'string');
            Parameters.updatewindow=get(handles.updatewindow,'string');
            Parameters.lowcutoff=get(handles.lowcutoff,'string');
            Parameters.highcutoff=get(handles.highcutoff,'string');
            
%             NoiseStr=cellstr(get(handles.noise,'string'));
%             Parameters.noise=NoiseStr{get(handles.noise,'value')};
%             Parameters.noisefile=get(handles.noisefile);
            
            Parameters.eloc.current=handles.SYSTEM.Electrodes.current.eLoc;
            Parameters.eloc.orig=handles.SYSTEM.Electrodes.original.eLoc;

            ParamSaveFile=strcat(sessiondir,'\NOISE_Param.mat');
            save(ParamSaveFile,'Parameters','-v7.3');

            guidata(hObject,handles);
            set(handles.Stop,'userdata',0)
                
        end
            
	end
    
elseif isequal(get(hObject,'userdata'),0)
    
    fprintf(2,'PARAMETERS HAVE NOT BEEN SET\n');
    set(hObject,'backgroundcolor','red','userdata',0)
    
end