function [hObject,handles]=bci_fESI_Set(hObject,handles)

set(hObject,'BackgroundColor',[.94 .94 .94])
set(handles.Start,'BackgroundColor',[.94 .94 .94])
set(handles.Stop,'BackgroundColor',[.94 .94 .94])
set(handles.Start,'Value',2);
set(handles.SenSpikes,'String','');

% Define subject information for saving
Initials=get(handles.Initials,'String');
Session=get(handles.Session,'String');
Savepath=get(handles.Savepath,'String');
Year=get(handles.Year,'String');
Month=get(handles.Month,'String');
Day=get(handles.Day,'String');

SubDir=strcat(Savepath,'\',Initials);
handles.save.subdir=SubDir;

SessionDir=strcat(SubDir,'\',Initials,Year,Month,Day,'S',Session);
handles.save.sessiondir=SessionDir;
if ~exist(SessionDir,'dir')
    mkdir(SessionDir)
end
handles.save.sessiondir=SessionDir;

SaveFileDir=strcat(SessionDir,'\Saved');
if ~exist(SaveFileDir,'dir')
    mkdir(SaveFileDir)
end
handles.save.savefiledir=SaveFileDir;

Check=get(handles.Check,'UserData');
if isequal(Check,1)
    
    % Create low order butterworth filter 
    n=4;
    LowCutoff=str2double(get(handles.LowCutoff,'String'));
    HighCutoff=str2double(get(handles.HighCutoff,'String'));
    fs=str2double(get(handles.fs,'String'));
    Wn=[LowCutoff HighCutoff]/(fs/2);
    [b,a]=butter(n,Wn);
    handles.TFParam.butterB=b;
    handles.TFParam.butterA=a;
    
    PSD=get(handles.PSD,'Value');
    switch PSD
        case 1 % None
            
        case 2 % Complex Morlet Wavelet
            
            MWParam.Freq=[LowCutoff HighCutoff];
            MWParam.FreqRes=0.5;
            MWParam.FreqVect=LowCutoff:MWParam.FreqRes:HighCutoff;
            MWParam.fs=str2double(get(handles.fs,'String'));
            MorWav=bci_fESI_MorWav(MWParam);
            handles.TFParam.MWParam=MWParam;
            handles.TFParam.MorWav=MorWav;

        case 3 % Welch's PSD
            
            WelchParam.overlap=0;
            WelchParam.nfft=2^(nextpow2(str2double(get(handles.AnalysisWindow,'String')))+1);
            WelchParam.freqfact=2;
            WelchParam.srate=str2double(get(handles.fs,'String'));
            handles.TFParam.WelchParam=WelchParam;

        case 4 % DFT
            
    end
    
    eLoc=handles.Electrodes.eLoc2;
    ElecChanRemove=handles.Electrodes.ElecChanRemove;
    
    Domain=get(handles.Domain,'Value');
    switch Domain
        case 1 % None
        case 2 % Sensor
            
            axes(handles.axes1); cla
            axes(handles.axes2); cla
            set(handles.Axis1Label,'String','');
            set(handles.Axis2Label,'String','');
            
            axes(handles.axes3); cla; 
            topoplot([],eLoc); view(2); colorbar off
            set(gcf,'color',[.94 .94 .94])
            set(handles.Axis3Label,'String','Scalp Activity');
            title('')
            
        case 3 % ESI
            
            axes(handles.axes2); cla; 
            topoplot([],eLoc); view(2); colorbar off
            set(gcf,'color',[.94 .94 .94])
            set(handles.Axis2Label,'String','Scalp Activity');
            title('')
            
            Cortex=get(handles.Cortex,'String');
            Cortex=load(Cortex);
            Faces=Cortex.Faces; Vertices=Cortex.Vertices;
            axes(handles.axes3)
            set(handles.Axis3Label,'String','Cortical Activity');
            
            LRVizSource=get(handles.LRVizSource,'Value');
            if isequal(LRVizSource,1)
                CortexLR=get(handles.CortexLR,'String');
                CortexLR=load(CortexLR);
                FacesLR=CortexLR.Faces; VerticesLR=CortexLR.Vertices;
                h=trisurf(FacesLR,VerticesLR(:,1),VerticesLR(:,2),VerticesLR(:,3),zeros(1,size(VerticesLR,1)));
                
                NN=bci_fESI_Brain_Interp(Cortex,CortexLR);
                handles.Inverse.CortexLR=CortexLR;
                handles.Inverse.NN=NN;
                handles.Inverse.VerticesLR=VerticesLR;
                handles.Inverse.FacesLR=FacesLR;
                
            else
                h=trisurf(Faces,Vertices(:,1),Vertices(:,2),Vertices(:,3),zeros(1,size(Vertices,1)));
            end
            set(h,'FaceColor','interp','EdgeColor','None','FaceLighting','gouraud');
            axis equal; axis off; view(-90,90)
            cmap1=jet(256);
            newcmap1=repmat([0.85 0.85 0.85],[1 1]);
            newcmap2=cmap1(1:end,:);
            cmap=[newcmap1;newcmap2];
            colormap(cmap); caxis([0 1]);
            light; h2=light; lightangle(h2,90,-90); h3=light;lightangle(h3,-90,30);
            
%             ROI=get(handles.ROI,'String');
%             ROI=load(ROI); ROIL=[]; ROIR=[];
%             for i=1:size(ROI.Scouts,2)
%                 if strcmp(ROI.Scouts(i).Label(end),'L')
%                     ROIL=[ROIL ROI.Scouts(i).Vertices];
%                 elseif strcmp(ROI.Scouts(i).Label(end),'R')
%                     ROIR=[ROIR ROI.Scouts(i).Vertices];
%                 end
%             end
%             ROIL=sort(ROIL,'ascend');
%             ROIR=sort(ROIR,'ascend');
            
%             handles.Inverse.Prior.ind=ones(1,size(Cortex.Vertices,1));
            handles.Inverse.Prior.ind=1:size(Cortex.Vertices,1);
            handles.Inverse.Prior.val=ones(1,size(Cortex.Vertices,1));
            
            HeadModel=get(handles.HeadModel,'String');
            HeadModel=load(HeadModel);
            HeadModel.Gain(ElecChanRemove,:)=[];
            
            Noise=get(handles.Noise,'Value');
            % Create average reference operator
            chan=size(HeadModel.Gain,1);
            I=eye(chan);
            AveRef=(I-sum(I(:))/(chan*chan));
            switch Noise
                case {1,2} % None selected or no noise estimation
                    % Identity matrix
                    C=1.0e-10*eye(chan);
                    % Apply average reverence to noise covariance
                    C=AveRef*C*AveRef';
                    % Use diagonal covariance with no noise modeling
                    variances=diag(C);
                    C=diag(variances);
                    
                    handles.Inverse.C=C;
                    
                    % COMPUTE INVERSE OPERATOR
                    handles.Inverse.Wfmri=1;
                    handles.Inverse=bci_fESI_CreateKernel3(HeadModel,'Tik_bst',handles.Inverse,Cortex);
                    R=handles.Inverse.R;
                    
                case {3,4} % Diagonal or full noise covariance
                    
                    NoiseDataFile=get(handles.NoiseDataFile,'String');
                    NoiseDataStruct=load(NoiseDataFile);
                    NoiseData=NoiseDataStruct.Dat.eeg;
                    
                    if isequal(size(NoiseData,1),handles.Electrodes.NumChanOrig)
                        NoiseData(handles.Electrodes.ElecChanRemove,:)=[];
                    end
                    
                    % Filter noisy data
                    NoiseData=filtfilt(b,a,double(NoiseData'));
                    NoiseData=NoiseData';
                    % Mean-correct noise data
                    NoiseData=NoiseData-repmat(mean(NoiseData,2),[1 size(NoiseData,2)]);
                    
                    PSD=get(handles.PSD,'Value');
                    switch PSD
                        case 1 % None
                        case 2 % Complex Morlet wavelet
                            
                            dt=1/MWParam.fs;
                            Anoise=zeros(size(MWParam.FreqVect,2),size(NoiseData,2),size(NoiseData,1));
                            for i=1:size(NoiseData,1)
                                for j=1:size(MWParam.FreqVect,2)
                                    Anoise(j,:,i)=conv2(NoiseData(i,:),MorWav{j},'same')*dt;
                                end
                            end
                            Enoisereal=real(Anoise);
                            Enoiseimag=imag(Anoise);
                            
                            Enoisereal=sum(Enoisereal,1);
                            Enoiseimag=sum(Enoiseimag,1);
                            
                            Enoisereal=(squeeze(Enoisereal))';
                            Enoiseimag=(squeeze(Enoiseimag))';
                            
                            C_real=(Enoisereal*Enoisereal')/size(Enoisereal,2);
                            C_imag=(Enoiseimag*Enoiseimag')/size(Enoiseimag,2);
                            
                            C_real=AveRef*C_real*AveRef';
                            C_imag=AveRef*C_imag*AveRef';
                            
                            if isequal(Noise,3) % diagonal covariance
                                C_real=diag(diag(C_real));
                                C_imag=diag(diag(C_imag));
                            end
                            
                            handles.Inverse.real.C=C_real;
                            handles.Inverse.imag.C=C_imag;
                            
                            % COMPUTE INVERSE OPERATOR
                            handles.Inverse.real.Prior=handles.Inverse.Prior;
                            handles.Inverse.real.Wfmri=1;
                            handles.Inverse.real=bci_fESI_CreateKernel2(HeadModel,'Tik_bst',handles.Inverse.real);
                            handles.Inverse.imag.Prior=handles.Inverse.Prior;
                            handles.Inverse.imag.Wfmri=1;
                            handles.Inverse.imag=bci_fESI_CreateKernel2(HeadModel,'Tik_bst',handles.Inverse.imag);
                            
                            R=handles.Inverse.real.R+handles.Inverse.imag.R;

                        case {3,4} % Welch's PSD or DFT
                    end
            end

%             axes(handles.axes1); cla
%             set(handles.Axis1Label,'String','');
%             set(handles.Axis1Label,'String','LeadField');
%             h=trisurf(Faces,Vertices(:,1),Vertices(:,2),Vertices(:,3),R);
%             set(h,'FaceColor','interp','EdgeColor','None','FaceLighting','phong');
%             axis([-100 100 -100 100 -100 100]);
%             axis equal; axis off; view(-90,90); colormap(jet);
%             light('Position',[0 0 1]);
%             hold on
%             scatter3(Vertices(ROIL,1),Vertices(ROIL,2),Vertices(ROIL,3),50,'g.');
%             scatter3(Vertices(ROIR,1),Vertices(ROIR,2),Vertices(ROIR,3),50,'g');
%             hold off

            % SAVE INVERSE PARAMETERS FOR CALLBACK DURING REALTIME OPERATION
            handles.Inverse.Cortex=Cortex;
%             handles.Inverse.ROIL=ROIL;
%             handles.Inverse.ROIR=ROIR;
            handles.Inverse.HeadModel=HeadModel;
            handles.Inverse.Faces=Faces;
            handles.Inverse.Vertices=Vertices;
            
        case 4 % fESI
            
            axes(handles.axes2); cla; 
            set(handles.Axis2Label,'String','Scalp Activity');
            topoplot([],eLoc); view(2); colorbar off
            set(gcf,'color',[.94 .94 .94])
            title('')
            
            Cortex=get(handles.Cortex,'String');
            Cortex=load(Cortex);
            Faces=Cortex.Faces; Vertices=Cortex.Vertices;
            axes(handles.axes3); cla
            set(handles.Axis3Label,'String','Cortical Activity');
            
            LRVizSource=get(handles.LRVizSource,'Value');
            if isequal(LRVizSource,1)
                CortexLR=get(handles.CortexLR,'String');
                CortexLR=load(CortexLR);
                FacesLR=CortexLR.Faces; VerticesLR=CortexLR.Vertices;
                h=trisurf(FacesLR,VerticesLR(:,1),VerticesLR(:,2),VerticesLR(:,3),zeros(1,size(VerticesLR,1)));
                
                NN=bci_fESI_Brain_Interp(Cortex,CortexLR);
                handles.Inverse.CortexLR=CortexLR;
                handles.Inverse.NN=NN;
                handles.Inverse.VerticesLR=VerticesLR;
                handles.Inverse.FacesLR=FacesLR;
                
            else
                h=trisurf(Faces,Vertices(:,1),Vertices(:,2),Vertices(:,3),zeros(1,size(Vertices,1)));
            end
            
            set(h,'FaceColor','interp','EdgeColor','None','FaceLighting','gouraud');
            axis equal; axis off; view(-90,90)
            cmap1=jet(256);
            newcmap1=repmat([0.85 0.85 0.85],[1 1]);
            newcmap2=cmap1(1:end,:);
            cmap=[newcmap1;newcmap2];
            colormap(cmap); caxis([0 1]);
            light; h2=light; lightangle(h2,90,-90); h3=light;lightangle(h3,-90,30);
            
%             ROI=get(handles.ROI,'String');
%             ROI=load(ROI); ROIL=[]; ROIR=[];
%             for i=1:size(ROI.Scouts,2)
%                 if strcmp(ROI.Scouts(i).Label(end),'L')
%                     ROIL=[ROIL ROI.Scouts(i).Vertices];
%                 elseif strcmp(ROI.Scouts(i).Label(end),'R')
%                     ROIR=[ROIR ROI.Scouts(i).Vertices];
%                 end
%             end
%             ROIL=sort(ROIL,'ascend');
%             ROIR=sort(ROIR,'ascend');
            
            % LOAD FMRI PRIOR(s) AND DETERMINE WEIGHTING
            fMRI=get(handles.fMRI,'String');
            fMRI=gifti(fMRI);
            PriorInd=find(fMRI.cdata~=0);
            PriorVal=fMRI.cdata(PriorInd);
            handles.Inverse.Prior.ind=PriorInd;
            handles.Inverse.Prior.val=PriorVal;

            % Compute fmri prior weight
            fMRIWeight=get(handles.fMRIWeight,'Value');
            Wnonfmri=1-(fMRIWeight/100);
            Wfmri=1/Wnonfmri;
            
            HeadModel=get(handles.HeadModel,'String');
            HeadModel=load(HeadModel);
            HeadModel.Gain(ElecChanRemove,:)=[];
            
            Noise=get(handles.Noise,'Value');
            % Create average reference operator
            chan=size(HeadModel.Gain,1);
            I=eye(chan);
            AveRef=(I-sum(I(:))/(chan*chan));
            switch Noise
                case {1,2} % None selected or no noise estimation
                    % Identity matrix
                    C=1.0e-10*eye(chan);
                    % Apply average reverence to noise covariance
                    C=AveRef*C*AveRef';
                    % Use diagonal covariance with no noise modeling
                    variances=diag(C);
                    C=diag(variances);
                    
                    handles.Inverse.C=C;
                    
                    % COMPUTE INVERSE OPERATOR
                    handles.Inverse.Wfmri=Wfmri;
                    handles.Inverse=bci_fESI_CreateKernel3(HeadModel,'Tik_bst',handles.Inverse,Cortex);
                    
                    R=handles.Inverse.R;
                    
                case {3,4} % Diagonal or full noise covariance
                    
                    NoiseDataFile=get(handles.NoiseDataFile,'String');
                    NoiseDataStruct=load(NoiseDataFile);
                    NoiseData=NoiseDataStruct.Dat.eeg;
                    
                    % Filter noisy data
                    NoiseData=filtfilt(b,a,double(NoiseData'));
                    NoiseData=NoiseData';
                    % Mean-correct noise data
                    NoiseData=NoiseData-repmat(mean(NoiseData,2),[1 size(NoiseData,2)]);
                    
                    PSD=get(handles.PSD,'Value');
                    switch PSD
                        case 1 % None
                        case 2 % Complex Morlet wavelet
                            
                            dt=1/MWParam.fs;
                            Anoise=zeros(size(MWParam.FreqVect,2),size(NoiseData,2),size(NoiseData,1));
                            for i=1:size(NoiseData,1)
                                for j=1:size(MWParam.FreqVect,2)
                                    Anoise(j,:,i)=conv2(NoiseData(i,:),MorWav{j},'same')*dt;
                                end
                            end
                            Enoisereal=real(Anoise);
                            Enoiseimag=imag(Anoise);
                            
                            Enoisereal=sum(Enoisereal,1);
                            Enoiseimag=sum(Enoiseimag,1);
                            
                            Enoisereal=(squeeze(Enoisereal))';
                            Enoiseimag=(squeeze(Enoiseimag))';
                            
                            C_real=(Enoisereal*Enoisereal')/size(Enoisereal,2);
                            C_imag=(Enoiseimag*Enoiseimag')/size(Enoiseimag,2);
                            
                            C_real=AveRef*C_real*AveRef';
                            C_imag=AveRef*C_imag*AveRef';
                            
                            if isequal(Noise,3) % diagonal covariance
                                C_real=diag(diag(C_real));
                                C_imag=diag(diag(C_imag));
                            end
                            
                            handles.Inverse.real.C=C_real;
                            handles.Inverse.imag.C=C_imag;
                            
                            % COMPUTE INVERSE OPERATOR
                            handles.Inverse.real.Prior=handles.Inverse.Prior;
                            handles.Inverse.real.Wfmri=Wfmri;
                            handles.Inverse.real=bci_fESI_CreateKernel2(HeadModel,'Tik_bst',handles.Inverse.real);
                            handles.Inverse.imag.Prior=handles.Inverse.Prior;
                            handles.Inverse.imag.Wfmri=Wfmri;
                            handles.Inverse.imag=bci_fESI_CreateKernel2(HeadModel,'Tik_bst',handles.Inverse.imag);
                            
                            R=handles.Inverse.real.R+handles.Inverse.imag.R;
                        
                        case {3,4} % Welch's PSD or DFT
                    end
            end

            axes(handles.axes1); cla
            set(handles.Axis1Label,'String','');
%             set(handles.Axis1Label,'String','LeadField');
%             h=trisurf(Faces,Vertices(:,1),Vertices(:,2),Vertices(:,3),R);
%             set(h,'FaceColor','interp','EdgeColor','None','FaceLighting','phong');
%             axis([-100 100 -100 100 -100 100]);
%             axis equal; axis off; view(-90,90); colormap(jet);
%             light('Position',[0 0 1]);
%             hold on
%             scatter3(Vertices(ROIL,1),Vertices(ROIL,2),Vertices(ROIL,3),50,'g.');
%             scatter3(Vertices(ROIR,1),Vertices(ROIR,2),Vertices(ROIR,3),50,'g');
%             hold off
            
            % SAVE INVERSE PARAMETERS FOR CALLBACK DURING REALTIME OPERATION
            handles.Inverse.Cortex=Cortex;
%             handles.Inverse.ROIL=ROIL;
%             handles.Inverse.ROIR=ROIR;
            handles.Inverse.HeadModel=HeadModel;
            handles.Inverse.Faces=Faces;
            handles.Inverse.Vertices=Vertices;

    end
    set(hObject,'BackgroundColor','green')
    set(hObject,'UserData',1)
    
    % SAVE INVERSE PARAMETERS TO FILE & SAVED FILE LIST FOR DISPLAY
    if exist('Cortex','var')
        SaveCortexVar='Cortex';
        SaveCortexFile=strcat(SaveFileDir,'\',SaveCortexVar,'.mat');
        SaveCortex.Vertices=Cortex.Vertices;
        SaveCortex.Faces=Cortex.Faces;
        SaveCortex.SulciMap=Cortex.SulciMap;
        save(SaveCortexFile,'SaveCortex','-v7.3');
        SaveFiles=cell(get(handles.SaveFiles,'String'));
        if ~ismember(SaveCortexVar,SaveFiles)
            SaveFiles=vertcat(SaveFiles,{SaveCortexVar});
            set(handles.SaveFiles,'String',SaveFiles);
        end
        handles.save.cortex=SaveCortexFile;
    end
    
    if isfield(handles,'Inverse') && isfield(handles.Inverse,'Cortex')
        SaveLeadFieldVar='Lead Field';
        SaveLeadFieldFile=strcat(SaveFileDir,'\',SaveLeadFieldVar,'.mat');
        SaveNoiseCovVar='Noise Covariance';
        SaveSourceCovVar='Source Covariance';
        SavePriorVar='Source Prior';
        
        if isfield(handles.Inverse,'T') && ~isempty(handles.Inverse.T)
            SaveLeadField.ImagingKernel=handles.Inverse.T;
        end
        
        if isfield(handles.Inverse,'R') && ~isempty(handles.Inverse.R)
            SaveLeadField.Weights=handles.Inverse.R;
        elseif isfield(handles.Inverse,'real') && isfield(handles.Inverse.real,'R') &&...
                ~isempty(handles.Inverse.real.R) && isfield(handles.Inverse,'imag') &&...
                isfield(handles.Inverse.imag,'R') && ~isempty(handles.Inverse.imag.R)
            SaveLeadField.RealWeights=handles.Inverse.real.R;
            SaveLeadField.ImagWeights=handles.Inverse.imag.R;
        end
        
        if isfield(handles.Inverse,'C') && ~isempty(handles.Inverse.C)
            SaveLeadField.NoiseCov=handles.Inverse.C;
        elseif isfield(handles.Inverse,'real') && isfield(handles.Inverse.real,'C') &&...
                ~isempty(handles.Inverse.real.C) && isfield(handles.Inverse,'imag') &&...
                isfield(handles.Inverse.imag,'C') && ~isempty(handles.Inverse.imag.C)
            SaveLeadField.RealNoiseCov=handles.Inverse.real.C;
            SaveLeadField.ImagNoiseCov=handles.Inverse.imag.C;
        end
        
        if isfield(handles.Inverse,'Prior') && isfield(handles.Inverse.Prior,'ind') &&...
                ~isempty(handles.Inverse.Prior.ind) && isfield(handles.Inverse.Prior,'val') &&...
                ~isempty(handles.Inverse.Prior.val)
            SaveLeadField.PriorInd=handles.Inverse.Prior.ind;
            SaveLeadField.PriorVal=handles.Inverse.Prior.val;
        end
        
        % Save lead field file
        % Add variable to file list
        save(SaveLeadFieldFile,'SaveLeadField','-v7.3');
        SaveFiles=cell(get(handles.SaveFiles,'String'));
        if ~ismember(SaveLeadFieldVar,SaveFiles)
            SaveFiles=sort(vertcat(SaveFiles,{SaveLeadFieldVar}));
            set(handles.SaveFiles,'String',SaveFiles);
        end

        % Add variables to file list
        if ~ismember(SaveNoiseCovVar,SaveFiles)
            SaveFiles=sort(vertcat(SaveFiles,{SaveNoiseCovVar}));
            set(handles.SaveFiles,'String',SaveFiles);
        end
        
        if ~ismember(SaveSourceCovVar,SaveFiles)
            SaveFiles=sort(vertcat(SaveFiles,{SaveSourceCovVar}));
            set(handles.SaveFiles,'String',SaveFiles);
        end

        if ~ismember(SavePriorVar,SaveFiles)
            SaveFiles=sort(vertcat(SaveFiles,{SavePriorVar}));
            set(handles.SaveFiles,'String',SaveFiles);
        end
        
        handles.save.leadfield=SaveLeadFieldFile;
    end
    
elseif isequal(Check,2)
    
    fprintf(2,'PARAMETERS DID NOT PASS THE CHECK\n');
    set(hObject,'BackgroundColor','red')
    set(hObject,'UserData',0)
    
elseif isequal(Check,0)
    
   fprintf(2,'PARAMETERS HAVE NOT BEEN CHECKED\n');
   set(hObject,'BackgroundColor','red');
   set(hObject,'UserData',0)
   
end

set(handles.Stop,'Value',1);