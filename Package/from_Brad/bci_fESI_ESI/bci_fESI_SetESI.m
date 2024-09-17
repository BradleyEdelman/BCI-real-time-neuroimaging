function [hObject,handles]=bci_fESI_SetESI(hObject,handles)

set(hObject,'backgroundcolor',[.94 .94 .94],'userdata',0)
set(handles.SenSpikes,'string','');

savefiledir=handles.SYSTEM.savefiledir;

CheckESI=get(handles.CheckESI,'userdata');
if isequal(CheckESI,1)
    
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %   LOAD CORTEX, LOW RESOLUTION CORTEX, COMPUTE INTERPOLATION MATRIX  %
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    cortexfile=get(handles.cortexfile,'string');
    cortex=load(cortexfile);
    handles.ESI.cortex=cortex;
    faces=cortex.Faces; vertices=cortex.Vertices;
    
    axes(handles.axes3); cla
    set(handles.Axis3Label,'string','Cortical Activity');
    lrvizsource=get(handles.lrvizsource,'value');
    cortexlrfile=get(handles.cortexlrfile,'string');
    if isequal(lrvizsource,1)
        cortexlr=load(cortexlrfile);
        faceslr=cortexlr.Faces; verticeslr=cortexlr.Vertices;
        h=trisurf(faceslr,verticeslr(:,1),verticeslr(:,2),verticeslr(:,3),zeros(1,size(verticeslr,1)));

        lrinterp=bci_fESI_Brain_Interp(cortex,cortexlr);
        handles.ESI.cortexlr=cortexlr;
        handles.ESI.lowresinterp=lrinterp;
    else
        h=trisurf(faces,vertices(:,1),vertices(:,2),vertices(:,3),zeros(1,size(vertices,1)));
    end
    
    set(h,'FaceColor','interp','EdgeColor','None','FaceLighting','gouraud');
    axis equal; axis off; view(-90,90)
    cmap1=jet(256);
    newcmap1=repmat([0.85 0.85 0.85],[1 1]);
    newcmap2=cmap1(1:end,:);
    cmap=[newcmap1;newcmap2];
    colormap(cmap); caxis([0 1]);
    light; h2=light; lightangle(h2,90,-90); h3=light;lightangle(h3,-90,30);
    
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %              LOAD HEADMODEL AND PREPROCESS GAIN MATRIX              %
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    headmodelfile=get(handles.headmodelfile,'string');
    headmodel=load(headmodelfile);
    leadfield=headmodel.Gain;
    leadfield(handles.SYSTEM.Electrodes.chanidxexclude,:)=[];
    [chan,dip]=size(leadfield); dip=dip/3;

    % Create average reference operator
    I=eye(chan); AveRef=(I-sum(I(:))/(chan*chan));
    % Apply average reference to lead field
    leadfield=AveRef*leadfield; 

    % Compute power of lead fields for depth weighting
    R=reshape(leadfield,[chan 3 dip]);
    R=R.^2;
    R=sum(R,1);
    R=sum(R,2);
    R=squeeze(R);

    % Fix orientations of lead field sources
    leadfield=bci_fESI_bst_gain_orient(leadfield,headmodel.GridOrient);
    
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %                   CREATE NOISE COVARIANCE MATRICES                  %
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    noise=get(handles.noise,'value');
    noisefile=get(handles.noisefile,'string');
    % Regularize noise covariance matrix
    reg=0.1;
    
    switch noise
        case {1,2} % None or no noise estimation
            
            % Identity matrix 
            chan=size(handles.SYSTEM.Electrodes.current.eLoc,2);
            I=eye(chan); AveRef=(I-sum(I(:))/(chan*chan));
            noisecov=eye(chan);
            % Apply average reverence to noise covariance
            noisecov=AveRef*noisecov*AveRef';
            % Use diagonal covariance with no noise modeling
            variances=diag(noisecov);
            noisecov=diag(variances);
            % Repeat "non-modeled" noise for all frequencies
            noisecovrank=chan;
            % Create whitener
            whitener=bci_fESI_CalculateWhitener(noisecov,noisecovrank,0);
            handles.ESI.noisecov.nomodel=noisecov;
            handles.ESI.whitener.nomodel=whitener;

        case {3,4} % Diagonal or full noise covariance
            
            psd=get(handles.psd,'value');
            switch psd
                case 1 % None
                case 2 % Complex Morlet wavelet
                    
                    MWParam=handles.SYSTEM.mwparam;
                    MorWav=handles.SYSTEM.morwav;
                    dt=1/MWParam.fs;
                    noisestruct=load(noisefile);
                    noisedatatmp=noisestruct.Dat(1).eeg;
                    
                    C_real=zeros(size(noisedatatmp,1),size(noisedatatmp,1),size(noisestruct.Dat,2));
                    C_imag=zeros(size(noisedatatmp,1),size(noisedatatmp,1),size(noisestruct.Dat,2));
                    for i=1:size(noisestruct.Dat,2)
                        
                        noisedata=noisestruct.Dat(i).eeg;
                    
                        % Filter noisy data
                        noisedata=filtfilt(handles.SYSTEM.filter.b,handles.SYSTEM.filter.a,double(noisedata'));
                        noisedata=noisedata';

                        % Mean-correct noise data
                        noisedata=noisedata-repmat(mean(noisedata,2),[1 size(noisedata,2)]);
                    
                        Anoise=zeros(MWParam.NumFreq,size(noisedata,2),size(noisedata,1));
                        for j=1:size(noisedata,1)
                            for k=1:MWParam.NumFreq
                                Anoise(k,:,j)=conv2(noisedata(j,:),MorWav{k},'same')*dt;
                            end
                        end

                        Enoisereal=sum(real(Anoise),1);
                        Enoiseimag=sum(imag(Anoise),1);

                        Enoisereal=squeeze(Enoisereal)';
                        Enoiseimag=squeeze(Enoiseimag)';

                        C_real(:,:,i)=(Enoisereal*Enoisereal')/size(Enoisereal,2);
                        C_imag(:,:,i)=(Enoiseimag*Enoiseimag')/size(Enoiseimag,2);

                        C_real(:,:,i)=AveRef*C_real(:,:,i)*AveRef';
                        C_imag(:,:,i)=AveRef*C_imag(:,:,i)*AveRef';

                        if isequal(noise,3) % diagonal covariance
                            C_real(:,:,i)=diag(diag(C_real(:,:,i)));
                            C_imag(:,:,i)=diag(diag(C_imag(:,:,i)));
                        end
                            
                    end
                    
                    C_real=mean(C_real,3);
                    C_imag=mean(C_imag,3);
                    
                    noisecovrank=chan;
                    % Regularize noise covariance matrix
                    noisecovreal=C_real+(reg*mean(diag(C_real))*eye(chan));
                    whitenerreal=bci_fESI_CalculateWhitener(noisecovreal,noisecovrank,0);
                    handles.ESI.noisecov.real=noisecovreal;
                    handles.ESI.whitener.real=whitenerreal;

                    noisecovimag=C_imag+(reg*mean(diag(C_imag))*eye(chan));
                    whitenerimag=bci_fESI_CalculateWhitener(noisecovimag,noisecovrank,0);
                    handles.ESI.noisecov.imag=noisecovimag;
                    handles.ESI.whitener.imag=whitenerimag;

                    whitener=(whitenerreal+whitenerimag)/2;
                            
                            
                case {3,4} % Welch's PSD or DFT
            end
    end
    
    % Reciprocal of dipole power
    R=1./R;
    % Apply depth weighting
    weightlimit=10;
    weightlimit2=weightlimit.^2;
    limit=min(R)*weightlimit2;
    R(R>limit)=limit;
    weightexp=.5; % Weighting parameter (between 0 and 1)
    R=R.^weightexp;
    
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %              LOAD FMRI PRIOR(s) AND DETERMINE WEIGHTING             %
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    fmrifile=get(handles.fmrifile,'string');
    if ~isempty(fmrifile)
        fmri=gifti(fmrifile);
        prioridx=find(fmri.cdata~=0);
        priorval=fmri.cdata(prioridx);
    else
        prioridx=[];
        priorval=[];
    end
    jfmri=zeros(1,15002);
    jfmri(prioridx)=priorval;
    
    % COMPUTE DIPOLE SCALING FACTOR BASED ON FMRI WEIGHT
    fmriweight=get(handles.fmriweight,'value');
    wnonfmri=1-(fmriweight/100);
    wfmri=1/wnonfmri;
    
    % Apply fmri weighting
    R(prioridx)=R(prioridx)*wfmri;
    handles.ESI.leadfieldweights=R;

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %            PERFORM ANATOMICALLY CONSTRAINED PARCELLATION            %
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    brainregionfile=get(handles.brainregionfile,'string');
    brainregions=load(brainregionfile);
    selectbrainregions=get(handles.selectbrainregions,'userdata');
    vertidxinclude={brainregions.Scouts(selectbrainregions==1).Vertices};
    vertidxinclude=sort(horzcat(vertidxinclude{:}));
    vertidxexclude=1:dip;
    vertidxexclude(vertidxinclude)=[];
    
    handles.ESI.vertidxinclude=vertidxinclude;
    handles.ESI.vertidxexclude=vertidxexclude;
    handles.ESI.leadfield.original=leadfield;
    
    parcellation=get(handles.parcellation,'value');
    esifiles=cellstr(get(handles.esifiles,'string'));
    switch parcellation
        case {1,2} % None selected or None
            
            switch noise
                case {1,2} % None or no noise estimation

                    leadfield=whitener*leadfield;

                    % Determine lambda empirically from lead field
                    SNR=3;
                    lambdasq=trace(leadfield*diag(R)*leadfield')/(trace(noisecov)*SNR^2);
                    handles.ESI.lambdasq.nomodel=lambdasq;

                    % Create inverse operator
                    INV=diag(R)*leadfield'/(leadfield*diag(R)*leadfield'+lambdasq*noisecov)*whitener;
                    handles.ESI.inv.nomodel=INV;
                    handles.ESI.sourcecov=R;

                case {3,4} % Diagonal or full noise covariance

                    LeadFieldReal=whitenerreal*leadfield;
                    LeadFieldImag=whitenerimag*leadfield;
                    SNR=3;

                    % Create real inverse operator
                    lambdasqreal=trace(LeadFieldReal*diag(R)*LeadFieldReal')/(trace(noisecovreal)*SNR^2);
                    handles.ESI.lambdasq.real=lambdasqreal;
                    INVreal=diag(R)*LeadFieldReal'/(LeadFieldReal*diag(R)*LeadFieldReal'+lambdasqreal*noisecovreal)*whitenerreal;
                    handles.ESI.inv.real=INVreal;

                    % Create imaginary inverse operator
                    lambdasqimag=trace(LeadFieldImag*diag(R)*LeadFieldImag')/(trace(noisecovimag)*SNR^2);
                    handles.ESI.lambdasq.imag=lambdasqimag;
                    INVimag=diag(R)*LeadFieldImag'/(LeadFieldImag*diag(R)*LeadFieldImag'+lambdasqimag*noisecovimag)*whitenerimag;
                    handles.ESI.inv.imag=INVimag;

            end
            
        case 3 % MSP
            [TrialStruct]=bci_fESI_ExtractBCI2000Parameters(esifiles);
            [handles,TaskInfo,Data]=bci_fESI_TaskInfo(handles,esifiles,TrialStruct);
            [hObject,handles,BaselineData,TrialData]=...
                bci_fESI_TrialSections(hObject,handles,TaskInfo,...
                TrialStruct,Data,250/1000*str2double(handles.SYSTEM.fs)/handles.SYSTEM.dsfactor);
            [hObject,handles]=bci_fESI_CorticalClusters(hObject,handles,horzcat(TrialData{:}));
            % Must create a null cluster to create full inverse operator
            clusters=handles.ESI.clusters;
            
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            % BUILD INVERSE OPERATOR FOR EACH CLUSTER
            % Whiten lead field
            leadfield=whitener*handles.ESI.leadfield.cluster;
            handles.ESI.leadfield.whitened=leadfield;
            
            numCluster=size(clusters,2);
            GG=zeros(chan);
            Gk=cell(1,numCluster);
            Rk=cell(1,numCluster);
%             figure;
            for i=1:size(clusters,2)
                Gk{i}=leadfield(:,clusters{i});   
                Rk{i}=diag(R(clusters{i}));
%                 Rk{i}(Rk{i}==0)=.5;

                for j=1:size(clusters{i},2)
                    F1=find(faces(:,1)==clusters{i}(j));
                    F2=find(faces(:,2)==clusters{i}(j));
                    F3=find(faces(:,3)==clusters{i}(j));
                    Ftot=vertcat(F1,F2,F3);
                    vert=unique(faces(Ftot,:)); vert(vert==clusters{i}(j))=[];
                    vert(~ismember(vert,clusters{i}))=[];
                    
%                     hold on
%                     scatter3(Cortex.Vertices(Clusters{i}(j),1),Cortex.Vertices(Clusters{i}(j),2),Cortex.Vertices(Clusters{i}(j),3),200,'b','filled')
%                     scatter3(Cortex.Vertices(Vert,1),Cortex.Vertices(Vert,2),Cortex.Vertices(Vert,3),200,'r','filled')
                    vertidx=find(ismember(clusters{i},clusters{i}(j))==1);
                    connectidx=find(ismember(clusters{i},vert)==1);

                    Rk{i}(repmat(vertidx,[size(connectidx,1),1]),connectidx)=.005;
                    Rk{i}(connectidx,repmat(vertidx,[size(connectidx,1),1]))=.005;
                    
                end

                % Compile Gk*Rk*Gk' for entire lead field
                GG=GG+Gk{i}*Rk{i}*Gk{i}';
%                 subplot(12,12,i); imagesc(Rk{i}); caxis([-.5 .5]);
            end
            handles.ESI.clusterleadfield=Gk;
            handles.ESI.clustersourcecov=Rk;
            handles.ESI.residualsolution=GG;
                
% % % %             % Verification of cluster-by-cluster lead field build
% % % %             RR=diag(R);
% % % %             for i=1:size(clusters,2)
% % % %                 for j=1:size(clusters{i},2)
% % % %                     F1=find(Faces(:,1)==clusters{i}(j));
% % % %                     F2=find(Faces(:,2)==clusters{i}(j));
% % % %                     F3=find(Faces(:,3)==clusters{i}(j));
% % % %                     Ftot=vertcat(F1,F2,F3);
% % % %                     Vert=unique(Faces(Ftot,:)); Vert(Vert==clusters{i}(j))=[];
% % % %                     Vert(~ismember(Vert,clusters{i}))=[];
% % % %                     RR(repmat(clusters{i}(j),[size(Vert,1),1]),Vert)=.002;
% % % %                     RR(Vert,repmat(clusters{i}(j),[size(Vert,1),1]))=.002;
% % % %                 end
% % % %             end

% % % %             b=zeros(128,1);
% % % %             b([53 54 114 115])=1;
% % % %             Plot=zeros(1,15002);
% % % %             for i=1:size(clusters,2)
% % % %                 Jk{i}=Rk{i}*Gk{i}'*inv(GG+lambda*eye(128))*Whitener*b;
% % % %                 Plot(clusters{i})=Jk{i};
% % % %             end
% % % %             
% % % %             JJ=RR*LeadField'*inv(LeadField*RR*LeadField'+lambda*eye(128))*Whitener*b;
% % % %             
% % % %             figure; subplot(1,2,1)
% % % %             hold off
% % % %             h=trisurf(Cortex.Faces,Cortex.Vertices(:,1),Cortex.Vertices(:,2),Cortex.Vertices(:,3),Plot);
% % % %             set(h,'FaceColor','interp','EdgeColor','None','FaceLighting','gouraud');
% % % %             axis equal; axis off; view(-90,90)
% % % %             subplot(1,2,2)
% % % %             h=trisurf(Cortex.Faces,Cortex.Vertices(:,1),Cortex.Vertices(:,2),Cortex.Vertices(:,3),abs(JJ));
% % % %             set(h,'FaceColor','interp','EdgeColor','None','FaceLighting','gouraud');
% % % %             axis equal; axis off; view(-90,90)                
                
            switch noise
                case {1,2} % None or no noise estimation

                    % Determine lambda empirically from total lead field
                    SNR=3;
                    lambdasq=double(trace(GG)/(trace(noisecov)*SNR^2));
                    handles.ESI.lambdasq.nomodel=lambdasq;
                    
                    % Create inverse operator for each cluster
                    INV=cell(1,size(clusters,2));
                    for i=1:size(clusters,2)
                        INV{i}=Rk{i}*Gk{i}'*inv(GG+lambdasq*eye(chan))*whitener;
                    end
                    handles.ESI.inv.nomodel=INV;
                    
                case {3,4} % Diagonal or full noise covariance
                    
                    SNR=3;
                    % Create real inverse operator for each cluster
                    lambdasqreal=double(trace(GG)/(trace(noisecovreal)*SNR^2));
                    handles.ESI.lambdasq.real=lambdasqreal;
                    
                    INVreal=cell(1,size(clusters,2));
                    for i=1:size(clusters,2)
                        INVreal{i}=Rk{i}*Gk{i}'*inv(GG+lambdasqreal*eye(chan))*whitenerreal;
                    end
                    handles.ESI.inv.real=INVreal;
                    
                    % Create imaginary inverse operator for each cluster
                    lambdasqimag=double(trace(GG)/(trace(noisecovimag)*SNR^2));
                    handles.ESI.lambda.imag=lambdasqimag;
                    
                    INVimag=cell(1,size(clusters,2));
                    for i=1:size(clusters,2)
                        INVimag{i}=Rk{i}*Gk{i}'*inv(GG+lambdasqimag*eye(chan))*whitenerimag;
                    end
                    handles.ESI.inv.imag=INVimag;
            end

        case 4 % k-means
    end
   
    
    handles.ESI.cortexfile=cortexfile;
    handles.ESI.cortex=cortex;
    handles.ESI.cortexlrfile=cortexlrfile;
    handles.ESI.headmodelfile=headmodelfile;
    handles.ESI.headmodel=headmodel;
    handles.ESI.fmrifile=fmrifile;
    handles.ESI.fmriprioridx=prioridx;
    handles.ESI.fmripriorval=priorval;
    handles.ESI.jfmri=jfmri;
    handles.ESI.wfmri=wfmri;
   
    handles.ESI.brainregionfile=brainregionfile;
    handles.ESI.selectbrainregions=selectbrainregions;
    handles.ESI.esifiles=esifiles;
    handles.ESI.noisefile=noisefile;
    
    handles.ESI.parcellation=parcellation;
    handles.ESI.noise=noise;
    
    % SAVE ESI PARAMETERS TO FILE
    k=1;
    saveESIfile=strcat(savefiledir,'\ESI_',num2str(k),'.mat');
    % Dont duplicate file (may want to load later)
    while exist(saveESIfile,'file')
        k=k+1;
        saveESIfile=strcat(savefiledir,'\ESI_',num2str(k),'.mat');
    end
    SaveESI=handles.ESI;
    save(saveESIfile,'SaveESI','-v7.3');
    
    
    % ADD VARIABLES TO SAVED FILE LIST FOR DISPLAY
    if isfield(handles,'ESI')
        
        savevar={'Cortex' 'Lead Field' 'Noise Covariance'...
            'Source Covariance' 'Source Prior'};
        
        for i=1:size(savevar,2)
            savefiles=cell(get(handles.savefiles,'string'));
            if ~ismember(savevar{i},savefiles)
                savefiles=sort(vertcat(savefiles,{savevar{i}}));
                set(handles.savefiles,'string',savefiles);
            end
        end
        
    end
    set(hObject,'backgroundcolor','green','userdata',1);
    
elseif isequal(CheckESI,0)
    
   fprintf(2,'ESI PARAMETERS HAVE NOT BEEN CHECKED\n');
   set(hObject,'backgroundcolor','red','userdata',0);
   
end
