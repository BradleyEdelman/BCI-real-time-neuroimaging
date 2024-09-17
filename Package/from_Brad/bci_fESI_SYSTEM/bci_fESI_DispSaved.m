function [hObject,handles]=bci_fESI_DispSaved(hObject,handles)

value=get(handles.savefiles,'value');
savefiles=cell(get(handles.savefiles,'string'));
DisplayFile=savefiles{value};
if ismember(DisplayFile,{'Cortex' 'Lead Field' 'Noise Covariance' 'Source Covariance'...
        'Source Prior' 'Clusters'})
    switch DisplayFile
        case 'Cortex'
            
            % Check if variable is stored in handles
            if isfield(handles.ESI,'cortex')
                cortex=handles.ESI.cortex;
            % If not, check if ESI variables have been saved
            elseif isfield(handles.ESI,'savefile') && exist(handles.ESI.savefile,'file')
                load(handles.ESI.savefile);
                cortex=SaveESI.ESI.cortex;
            else
                fprintf(2,'CORTEX NOT STORED IN HANDLES OR SAVED TO FILE\n');
                savefiles(value)=[];
                set(handles.savefiles,'string',savefiles);
                set(handles.savefiles,'value',size(savefiles,1));
            end
            
            if exist('cortex','var')
                [hObject,handles]=bci_fESI_Reset(hObject,handles,'None',[]);
                set(handles.Axis3Label,'string','cortex');
                dip=size(cortex.Vertices,1);
                h=trisurf(cortex.Faces,cortex.Vertices(:,1),...
                    cortex.Vertices(:,2),cortex.Vertices(:,3),zeros(1,dip));
                set(h,'FaceColor','interp','EdgeColor','None','FaceLighting','gouraud');
                axis equal; axis off; view(-90,90)
                light; h2=light; lightangle(h2,90,-90); h3=light;lightangle(h3,-90,30);
                cmap=[.85 .85 .85]; colormap(cmap); caxis auto; rotate3d on
            end

        case 'Lead Field'
            
            % Check if variable is stored in handles
            if isfield(handles.ESI,'cortex') && isfield(handles.ESI,'leadfieldweights')
                cortex=handles.ESI.cortex;
                R=handles.ESI.leadfieldweights;
            elseif isfield(handles.ESI,'savefile') && exist(handles.ESI.savefile,'file')
                load(handles.ESI.savefile);
                cortex=SaveESI.ESI.cortex;
                R=SaveESI.ESI.leadfieldweights;
            else
                fprintf(2,'CORTEX NOT STORED IN HANDLES OR SAVED TO FILE\n');
                savefiles(value)=[];
                set(handles.savefiles,'string',savefiles);
                set(handles.savefiles,'value',size(savefiles,1));
            end
            
            if exist('cortex','var') && exist('R','var')
                    [hObject,handles]=bci_fESI_Reset(hObject,handles,'None',[]);
                    set(handles.Axis3Label,'string','Lead Field');
                    h=trisurf(cortex.Faces,cortex.Vertices(:,1),...
                        cortex.Vertices(:,2),cortex.Vertices(:,3),R);
                    set(h,'FaceColor','interp','EdgeColor','None','FaceLighting','gouraud');
                    axis equal; axis off; view(-90,90)
                    light; h2=light; lightangle(h2,90,-90); h3=light; lightangle(h3,-90,30);
                    cmap=jet(256); colormap(cmap); caxis auto; rotate3d on
            end
            
        case 'Noise Covariance'
            
            % Check if variable is stored in handles
            if isfield(handles.ESI,'noise')
                
                noise=handles.ESI.noise;
                switch noise
                    case 1 % None
                    case 2 % No Noise Estimation
                        noisecov=handles.ESI.noisecov.nomodel;
                    case 3 % Diagonal
                        noisecov_real=handles.ESI.noisecov.real;
                        noisecov_imag=handles.ESI.noisecov.imag;
                        noisecov=noisecov_real+noisecov_imag;
                    case 4 % Full
                end
                
            elseif isfield(handles.ESI,'savefile') && exist(handles.ESI.savefile,'file')
                
                load(handles.ESI.savefile);
                noise=SaveESI.ESI.noisetype;
                switch noise
                    case 1 % None
                    case 2 % No Noise Estimation
                        noisecov=SaveESI.ESI.NoiseCov;
                    case 3 % Diagonal
                        noisecov_real=SaveESI.ESI.real.noisecov;
                        noisecov_imag=SaveESI.ESI.imag.noisecov;
                        noisecov=noisecov_real+noisecov_imag;
                    case 4 % Full
                end
                
            else
                fprintf(2,'NOISE COVARIANCE NOT STORED IN HANDLES OR SAVED TO FILE\n');
                savefiles(value)=[];
                set(handles.savefiles,'string',savefiles);
                set(handles.savefiles,'value',size(savefiles,1));
            end
            
            if exist('noise','var') && exist('noisecov','var')
                [hObject,handles]=bci_fESI_Reset(hObject,handles,'None',[]);
                set(handles.Axis3Label,'string','Noise Covariance');
                axes(handles.axes3); rotate3d off;
                imagesc(noisecov); 
                axis off; axis auto; axis equal; view(0,90);
                cmap=jet(256); colormap(cmap);
                caxis([min(noisecov(:)) max(noisecov(:))*1.1])
            end
            
        case 'Source Covariance'
            
% % % %             if isfield(handles,'ESI') && isfield(handles.ESI,'savefiledir') &&...
% % % %                     ~isnan(str2double(get(handles.LeadFieldFreq,'string')))
% % % %                 LeadFieldFreq=str2double(get(handles.LeadFieldFreq,'string')); 
% % % %                 ESIFile=strcat(handles.ESI.savefiledir,'\ESI_',num2str(LeadFieldFreq),'Hz.mat');
% % % %                 if ~exist(ESIFile,'file')
% % % %                     fprintf(2,'SAVED LEAD FIELD FILE DOES NOT EXIST, SET PARAMETERS TO RESAVE\n');
% % % %                     savefiles(value)=[];
% % % %                     set(handles.savefiles,'string',savefiles);
% % % %                     set(handles.savefiles,'value',size(savefiles,1));
% % % %                 else
% % % % 
% % % %                     load(ESIFile)
% % % %                     Noise=get(handles.Noise,'value');
% % % %                     switch Noise
% % % %                         case 1 % None
% % % %                         case 2 % No Noise Estimation
% % % %                             SourceCov=SaveESI.ESI.SourceCov;
% % % %                         case 3 % Diagonal
% % % %                             SourceCov_real=SaveESI.ESI.SourceCov.real;
% % % %                             SourceCov_imag=SaveESI.ESI.SourceCov.imag;
% % % %                             SourceCov=SourceCov_real+SourceCov_imag;
% % % %                         case 4 % Full
% % % %                     end
% % % % 
% % % %                     [hObject,handles]=bci_fESI_Reset(hObject,handles,'None',[]);
% % % %                     set(handles.Axis3Label,'string','Source Covariance');
% % % %                     imagesc(SourceCov); axis auto; rotate3d off
% % % %                     axis equal; axis off; cmap=jet(256); colormap(cmap);
% % % %                     caxis([min(SourceCov(:)) max(SourceCov(:))*1.1])
% % % %                 end
% % % %             end
            
        case 'Source Prior'
        	
            % Check if variable is stored in handles
            if isfield(handles.ESI,'fmriprioridx')
                prioridx=handles.ESI.fmriprioridx;
                priorval=handles.ESI.fmripriorval;
                cortex=handles.ESI.cortex;
            % If not, check if ESI variables have been saved
            elseif isfield(handles.ESI,'savefile') && exist(handles.ESI.savefile,'file')
                load(handles.ESI.savefile);
                prioridx=SaveESI.ESI.fmriprioridx;
                priorval=SaveESI.ESI.fmripriorval;
                cortex=SaveESI.ESI.cortex;
            else
                fprintf(2,'fMRI PRIOR NOT STORED IN HANDLES OR SAVED TO FILE\n');
                savefiles(value)=[];
                set(handles.savefiles,'string',savefiles);
                set(handles.savefiles,'value',size(savefiles,1));
            end
        
                if exist('prioridx','var') && exist('priorval','var') &&...
                        exist('cortex','var')
                    Prior=cortex.SulciMap;
                    Prior=-.1*Prior-.1;
                    priorval=(priorval-min(priorval))/(max(priorval)-min(priorval));
                    Prior(prioridx)=priorval;

%                     Subj=get(handles.Initials,'string');
%                     HRicortex=strcat('M:\_bci_fESI\Brad_Test_Files\tess_cortex_pial_low_fig.mat');
%                     if exist(HRicortex,'file')
%                         cortex=load(HRicortex);
%                     else
%                         cortex=handles.ESI.cortex;
%                     end

                    [hObject,handles]=bci_fESI_Reset(hObject,handles,'None',[]);
                    set(handles.Axis3Label,'string','Source Prior');
                    h=trisurf(cortex.Faces,cortex.Vertices(:,1),...
                        cortex.Vertices(:,2),cortex.Vertices(:,3),Prior);
                    set(h,'FaceColor','interp','EdgeColor','None','FaceLighting','gouraud');
                    axis equal; axis off; view(-90,90); rotate3d on
                    light; h2=light; lightangle(h2,90,-90); h3=light;  lightangle(h3,-90,30);
                    cmap=jet(128); cmap=[repmat([.7 .7 .7],[10,1]);repmat([.85 .85 .85],[10,1]);cmap]; colormap(cmap);
                    caxis([-.2 1]);
                
                end
             
        case 'Clusters'
            
            % Check if variable is stored in handles
            if isfield(handles.ESI,'clusters')
                clusters=handles.ESI.vertclusterassignment;
                cortex=handles.ESI.cortex;
                vertidxexclude=handles.ESI.vertidxexclude;
            % If not, check if ESI variables have been saved
            elseif isfield(handles.ESI,'savefile') && exist(handles.ESI.savefile,'file')
                load(handles.ESI.savefile);
                clusters=SaveESI.ESI.verticesassigned;
                cortex=SaveESI.ESI.cortex;
                vertidxexclude=SaveESI.ESI.vertidxexclude;
            else
                fprintf(2,'fMRI PRIOR NOT STORED IN HANDLES OR SAVED TO FILE\n');
                savefiles(value)=[];
                set(handles.savefiles,'string',savefiles);
                set(handles.savefiles,'value',size(savefiles,1));
            end
            
            if exist('clusters','var') && exist('cortex','var')
                [hObject,handles]=bci_fESI_Reset(hObject,handles,'None',[]);
                set(handles.Axis3Label,'string','Cortical Clusters');
                axes(handles.axes3)
                h=trisurf(cortex.Faces,cortex.Vertices(:,1),...
                cortex.Vertices(:,2),cortex.Vertices(:,3),clusters);
                set(h,'FaceColor','flat','EdgeColor','None','FaceLighting','gouraud');
                axis equal; axis off; view(-90,90); rotate3d on
                light; h2=light; lightangle(h2,90,-90); h3=light;  lightangle(h3,-90,30);
                cmap=[1 0 1;1 0 .5;.45 .45 1;.6 .6 0;.55 1 .75;...
                    .6 .3 0;1 .8 .8;1 0 0;1 .5 0;1 1 0;0 1 0;0 1 1;0 0 1;.5 0 1];
                numrep=ceil(size(unique(clusters),1)/size(cmap,1));
                cmap=repmat(cmap,[numrep 1]);
                if ~isempty(vertidxexclude)
                    cmap=[.85 .85 .85;cmap];
                end
                colormap(cmap); colorbar; caxis auto;
            end

        case 'Decoder Source'
            
            if ~exist(handles.save.decoder.source,'file')
                fprintf(2,'SOURCE DECODER FILE DOES NOT EXIST, TRAIN DECODER TO RESAVE\n');
                savefiles(value)=[];
                set(handles.savefiles,'string',savefiles);
                set(handles.savefiles,'value',size(savefiles,1));
            else
                
                load(handles.save.cortex);
                Savecortex=load('M:\brainstorm_db\bci_fESI\anat\BE\tess_cortex_pial_low_fig.mat');
                load(handles.save.decoder.source);
                DecoderType=SaveDecoderSource.DecoderType;
                TrainingScheme=SaveDecoderSource.TrainingScheme;
                
                switch DecoderType
                    case 1 % None
                    case 2 % Fisher LDA
                        
                        switch TrainingScheme
                          case 1 % None
                          case 2 % Average Time Window
                              
                            [hObject,handles]=bci_fESI_Reset(hObject,handles,'None',[]);
                            set(handles.Axis1Label,'string','Fisher Data Projection');
                            Y=SaveDecoderSource.Y;
                            plot(Y{1},zeros(1,size(Y{1},2)),'bo'); hold on
                            plot(Y{2},zeros(1,size(Y{2},2)),'ro');
%                             DB=SaveDecoderSource.DB(1,2);
%                             quiver(DB,-.5,0,2,'k','LineWidth',2);
                            hold off; axis off; axis auto
                              
                            set(handles.Axis3Label,'string','Fisher DA Weights');
                            Weights=SaveDecoderSource.W{1,2};
                            DispWeights=-.1*ones(1,size(Savecortex.Vertices,1));
                            DispWeights(handles.TrainParam.verticesinclude)=Weights;
                            h=trisurf(Savecortex.Faces,Savecortex.Vertices(:,1),...
                            Savecortex.Vertices(:,2),Savecortex.Vertices(:,3),DispWeights);
                            set(h,'FaceColor','interp','EdgeColor','None','FaceLighting','gouraud');
                            axis equal; axis off; view(-90,90); caxis auto;
                            light; h2=light; lightangle(h2,90,-90); h3=light;lightangle(h3,-90,30);
                            caxis auto; rotate3d on
                            cmap=jet(256); cmap(1,:)=repmat([.85 .85 .85],1,1); colormap(cmap);
                              
                          case 3 % Time Resolved

                            Y=SaveDecoderSource.Y;
                            figure;
                            for i=1:size(Y,2)
                                subplot(5,5,i);
                                plot(Y{1,i},zeros(1,size(Y{1},2)),'bo'); hold on
                                plot(Y{2,i},zeros(1,size(Y{2},2)),'ro');
                                plot(Y{3,i},zeros(1,size(Y{3},2)),'go');
%                                 DB=SaveDecoderSource.DB(1,2,i);
%                                 quiver(DB,-.5,0,2,'k','LineWidth',2);
                                hold off; axis off; axis auto
                            end
                            set(gcf,'Color',[.94 .94 .94]);

                            Weights=SaveDecoderSource.Weights;
                            figure;
                            for i=1:size(Weights,2)
                                subplot(5,5,i)
                                DispWeights=-.1*ones(1,size(Savecortex.Vertices,1));
                                DispWeights(handles.TrainParam.verticesinclude)=Weights(:,i);
                                h=trisurf(Savecortex.Faces,Savecortex.Vertices(:,1),...
                                Savecortex.Vertices(:,2),Savecortex.Vertices(:,3),DispWeights);
                                set(h,'FaceColor','interp','EdgeColor','None','FaceLighting','gouraud');
                                axis equal; axis off; view(-90,90); caxis auto;
                                light; h2=light; lightangle(h2,90,-90); h3=light;lightangle(h3,-90,30);
                            end
                            rotate3d on
                            set(gcf,'Color',[.94 .94 .94]);
                            cmap=jet(256); cmap(1,:)=repmat([.85 .85 .85],1,1); colormap(cmap);
                            suptitle('Time Resolved Sensor Fisher LDA Classifier Weights');
                              
                      end
                        
                    case 3 % LDA
                        
                        switch TrainingScheme
                            case 1 % None
                            case 2 % Average Time Window
                              
                                load(handles.save.cortex);
                                Savecortex=load('M:\brainstorm_db\bci_fESI\anat\BE\tess_cortex_pial_low_fig.mat');
                                [hObject,handles]=bci_fESI_Reset(hObject,handles,'None',[]);
                                set(handles.Axis3Label,'string','Mahalanobis Distance');
                                W=SaveDecoderSource.W{2,3};
                                DispWeights=-.1*ones(1,size(Savecortex.Vertices,1));
                                DispWeights(handles.TrainParam.verticesinclude)=W;
                                h=trisurf(Savecortex.Faces,Savecortex.Vertices(:,1),...
                                Savecortex.Vertices(:,2),Savecortex.Vertices(:,3),DispWeights);
                                set(h,'FaceColor','interp','EdgeColor','None','FaceLighting','gouraud');
                                axis equal; axis off; view(-90,90); caxis auto;
                                light; h2=light; lightangle(h2,90,-90); h3=light;lightangle(h3,-90,30);
                                set(gcf,'Color',[.94 .94 .94]); rotate3d on
                                cmap=jet(256); cmap(1,:)=repmat([.85 .85 .85],1,1); colormap(cmap);
                                colorbar
                              
                          case 3 % Time Resolved
                        end
                end
            end
            
        case 'Decoder Sensor'
            
            if ~exist(handles.save.decoder.sensor,'file')
                fprintf(2,'SENSOR DECODER FILE DOES NOT EXIST, TRAIN DECODER TO RESAVE\n');
                savefiles(value)=[];
                set(handles.savefiles,'string',savefiles);
                set(handles.savefiles,'value',size(savefiles,1));
             else

              load(handles.save.decoder.sensor);
              DecoderType=SaveDecoderSensor.DecoderType;
              TrainingScheme=SaveDecoderSensor.TrainingScheme;
              
              switch DecoderType
                  case 1 % None
                  case 2 % Fisher LDA
                      
                      switch TrainingScheme
                          case 1 % None
                          case 2 % Average Time Window
                              
                            [hObject,handles]=bci_fESI_Reset(hObject,handles,'None',[]);
                            set(handles.Axis1Label,'string','Fisher Data Projection');
                            Y=SaveDecoderSensor.Dsq;
                            plot(Y{1},zeros(1,size(Y{1},2)),'bo'); hold on
                            plot(Y{2},zeros(1,size(Y{2},2)),'ro');
                            plot(Y{3},zeros(1,size(Y{3},2)),'go'); hold off
                            axis off; axis auto
                              
                            Weights=SaveDecoderSensor.W(:,3);
                            set(handles.Axis3Label,'string','Fisher DA Weights');
                            topoplot(Weights,handles.TrainParam.eLoc,'electrodes','ptlabels');
                            view(0,90); axis xy; set(gcf,'color',[.94 .94 .94]);
                            cmap=jet(256); colormap(cmap); caxis auto
                              
                          case 3 % Time Resolved
                              
                                Y=SaveDecoderSensor.TrainDataProjection;
                                figure;
                                for i=1:size(Y,2)
                                    subplot(4,4,i);
                                    plot(Y{1,i},zeros(1,size(Y{1,i},2)),'bo'); hold on
                                    plot(Y{2,i},zeros(1,size(Y{2,i},2)),'ro');
                                    DB=SaveDecoderSensor.DB(1,2,i);
                                    quiver(DB,-.5,0,2,'k','LineWidth',2);
                                    hold off; axis off; axis auto
                                end
                                set(gcf,'Color',[.94 .94 .94]);

                                Weights=SaveDecoderSensor.Weights;
                                figure;
                                for i=1:size(Weights,2)
                                	subplot(4,4,i)
                                	topoplot(Weights(:,i),handles.TrainParam.eLoc);
                                end
                                set(gcf,'Color',[.94 .94 .94]);
                                suptitle('Time Resolved Sensor Fisher LDA Classifier Weights');
                      end

                  case 3 % LDA
                      
                      switch TrainingScheme
                          case 1 % None
                          case 2 % Average Time Window
                            
                            [hObject,handles]=bci_fESI_Reset(hObject,handles,'None',[]);
                            W=SaveDecoderSensor.Dsq(3,:);
                            set(handles.Axis3Label,'string','Fisher DA Weights');
                            topoplot(W,handles.TrainParam.eLoc,'electrodes','ptlabels');
                            view(0,90); axis xy; set(gcf,'color',[.94 .94 .94]);
                            cmap=jet(256); colormap(cmap); caxis auto
                              
                              
                          case 3 % Time Resolved
                      end
              end
            end
    end
    
elseif ~isequal(size(strfind(DisplayFile,'Sensor MD'),2),0)
    
    TaskInd=str2double(regexp(DisplayFile,'.\d+','match'));
    load(handles.save.decoder.sensor);
    [hObject,handles]=bci_fESI_Reset(hObject,handles,'None',[]);
    
    if TaskInd>size(SaveDecoderSensor.Dsq,1)
        savefiles(value)=[];
        set(handles.savefiles,'string',savefiles);
        set(handles.savefiles,'value',size(savefiles,1));
    else
        MD=SaveDecoderSensor.Dsq(TaskInd,:);
        set(handles.Axis3Label,'string','Mahalanobis Distance');
        topoplot(MD,handles.TrainParam.eLoc,'electrodes','ptlabels');
        view(0,90); axis xy; set(gcf,'color',[.94 .94 .94]);
        cmap=jet(256); colormap(cmap); caxis auto
    end
    
elseif ~isequal(size(strfind(DisplayFile,'Source MD'),2),0)
    
    TaskInd=str2double(regexp(DisplayFile,'.\d+','match'));
    load(handles.save.decoder.source);
    load(handles.save.cortex);
    Savecortex=load('M:\brainstorm_db\bci_fESI\anat\BE\tess_cortex_pial_low_fig.mat');
    [hObject,handles]=bci_fESI_Reset(hObject,handles,'None',[]);
    
    if TaskInd>size(SaveDecoderSource.Dsq,1)
        savefiles(value)=[];
        set(handles.savefiles,'string',savefiles);
        set(handles.savefiles,'value',size(savefiles,1));
    else
        set(handles.Axis3Label,'string','Mahalanobis Distance');
        MD=SaveDecoderSource.Dsq(TaskInd,:);
        DispMD=-.1*ones(1,size(Savecortex.Vertices,1));
        DispMD(handles.TrainParam.verticesinclude)=MD;
        h=trisurf(Savecortex.Faces,Savecortex.Vertices(:,1),...
        Savecortex.Vertices(:,2),Savecortex.Vertices(:,3),DispMD);
        set(h,'FaceColor','interp','EdgeColor','None','FaceLighting','gouraud');
        axis equal; axis off; view(-90,90); caxis auto;
        light; h2=light; lightangle(h2,90,-90); h3=light;lightangle(h3,-90,30);
        set(gcf,'Color',[.94 .94 .94]); rotate3d on
        cmap=jet(256); cmap(1,:)=repmat([.85 .85 .85],1,1); colormap(cmap); colorbar
    end
   
elseif ~isequal(size(strfind(DisplayFile,'Sensor Weights'),2),0)
    
    if ~exist(handles.save.decoder.sensor,'file')
        fprintf(2,'SENSOR DECODER FILE DOES NOT EXIST, TRAIN DECODER TO RESAVE\n');
        savefiles(value)=[];
        set(handles.savefiles,'string',savefiles);
        set(handles.savefiles,'value',size(savefiles,1));
    else

        load(handles.save.decoder.sensor);
        DecoderType=SaveDecoderSensor.DecoderType;
        TrainingScheme=SaveDecoderSensor.TrainingScheme;
        TaskInd=str2double(regexp(DisplayFile,'.\d+','match'));
        
        if TaskInd>size(SaveDecoderSensor.OVA,2)
            savefiles(value)=[];
            set(handles.savefiles,'string',savefiles);
            set(handles.savefiles,'value',size(savefiles,1));
        else
            switch DecoderType
                case 1 % None
                case 2 % Fisher LDA
                    switch TrainingScheme
                        case 1 % None
                        case 2 % Average Time Window

                            [hObject,handles]=bci_fESI_Reset(hObject,handles,'None',[]);
                            set(handles.Axis3Label,'string','FDA Sensor Weights');
                            W=SaveDecoderSensor.OVA(TaskInd).W;
                            topoplot(W,handles.TrainParam.eLoc,'electrodes','ptlabels');
                            view(0,90); axis xy; set(gcf,'color',[.94 .94 .94]);
                            cmap=jet(256); colormap(cmap); caxis auto
                    end

                case 3 % LDA
                    switch TrainingScheme
                        case 1 % None
                        case 2 % Average Time Window

                            [hObject,handles]=bci_fESI_Reset(hObject,handles,'None',[]);
                            set(handles.Axis3Label,'string','LDA Sensor Weights');
                            W=SaveDecoderSensor.OVA(TaskInd).W{1,2};
                            topoplot(W,handles.TrainParam.eLoc,'electrodes','ptlabels');
                            view(0,90); axis xy; set(gcf,'color',[.94 .94 .94]);
                            cmap=jet(256); colormap(cmap); caxis auto

                        case 3 % Time Resolved
                    end
            end
        end
    end
    
elseif ~isequal(size(strfind(DisplayFile,'Source Weights'),2),0)

    if ~exist(handles.save.decoder.source,'file')
        fprintf(2,'SOURCE DECODER FILE DOES NOT EXIST, TRAIN DECODER TO RESAVE\n');
        savefiles(value)=[];
        set(handles.savefiles,'string',savefiles);
        set(handles.savefiles,'value',size(savefiles,1));
    else

%         load(handles.save.cortex);
        Savecortex=load('M:\brainstorm_db\bci_fESI\anat\BE\tess_cortex_pial_low_fig.mat');
        load(handles.save.decoder.source);
        DecoderType=SaveDecoderSource.DecoderType;
        TrainingScheme=SaveDecoderSource.TrainingScheme;
        TaskInd=str2double(regexp(DisplayFile,'.\d+','match'));

        if TaskInd>size(SaveDecoderSource.OVA,2)
            savefiles(value)=[];
            set(handles.savefiles,'string',savefiles);
            set(handles.savefiles,'value',size(savefiles,1));
        else
            switch DecoderType
                case 1 % None
                case 2 % Fisher LDA
                    switch TrainingScheme
                        case 1 % None
                        case 2 % Average Time Window

                        [hObject,handles]=bci_fESI_Reset(hObject,handles,'None',[]);
                        set(handles.Axis3Label,'string','FDA Source Weights');
                        W=SaveDecoderSource.OVA(TaskInd).W; min(W)
                        if min(W)<0
                            DispWeights=1.1*min(W)*ones(1,size(Savecortex.Vertices,1));
                        else 
                            DispWeights=-1.1*min(W)*ones(1,size(Savecortex.Vertices,1));
                        end
                        DispWeights(handles.TrainParam.verticesinclude)=W;
                        h=trisurf(Savecortex.Faces,Savecortex.Vertices(:,1),...
                        Savecortex.Vertices(:,2),Savecortex.Vertices(:,3),DispWeights);
                        set(h,'FaceColor','interp','EdgeColor','None','FaceLighting','gouraud');
                        axis equal; axis off; view(-90,90); caxis auto;
                        light; h2=light; lightangle(h2,90,-90); h3=light;lightangle(h3,-90,30);
                        set(gcf,'Color',[.94 .94 .94]); rotate3d on
                        cmap=jet(256); cmap(1,:)=repmat([.85 .85 .85],1,1); colormap(cmap);
                    end

                case 3 % LDA
                    switch TrainingScheme
                        case 1 % None
                        case 2 % Average Time Window

                            [hObject,handles]=bci_fESI_Reset(hObject,handles,'None',[]);
                            set(handles.Axis3Label,'string','LDA Source Weights');
                            W=SaveDecoderSource.OVA(TaskInd).W{1,2};
                            if min(W)<0
                                DispWeights=1.1*min(W)*ones(1,size(Savecortex.Vertices,1));
                            else 
                                DispWeights=-1.1*min(W)*ones(1,size(Savecortex.Vertices,1));
                            end
                            DispWeights(handles.TrainParam.verticesinclude)=W;
                            h=trisurf(Savecortex.Faces,Savecortex.Vertices(:,1),...
                            Savecortex.Vertices(:,2),Savecortex.Vertices(:,3),DispWeights);
                            set(h,'FaceColor','interp','EdgeColor','None','FaceLighting','gouraud');
                            axis equal; axis off; view(-90,90); caxis auto;
                            light; h2=light; lightangle(h2,90,-90); h3=light;lightangle(h3,-90,30);

                            rotate3d on
                            set(gcf,'Color',[.94 .94 .94]);
                            cmap=jet(256); cmap(1,:)=repmat([.85 .85 .85],1,1); colormap(cmap);

                        case 3 % Time Resolved
                    end
            end
        end
    end
    
else
    savefiles(value)=[];
    set(handles.savefiles,'string',savefiles);
    set(handles.savefiles,'value',size(savefiles,1));
end