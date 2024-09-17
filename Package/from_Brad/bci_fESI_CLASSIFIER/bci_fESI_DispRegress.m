function [hObject,handles]=bci_fESI_DispRegress(hObject,handles)

value=get(handles.regressvar,'value');
regressvar=get(handles.regressvar,'string');

% CHECK IF REGRESSION VARIABLE LIST IS POPULATED
if ~isempty(regressvar)
    
    DisplayVar=regressvar{value};
    
    % CHECK IF A VISUALIZATION METHOD IS SELECTED
    AllFreq=get(handles.RegressFreqAll,'value');
    RegressFreq=str2double(get(handles.RegressFreq,'string'));
    if isequal(AllFreq,1) || ~isnan(RegressFreq)

        % SENSOR OR SOURCE SPACE REGRESSION???
        if ~isequal(size(strfind(DisplayVar,'Sensor'),2),0)
                    
            % IDENTIFY FREQUENCY FOR DISPLAY
            if ~isequal(AllFreq,1)
                Freq=RegressFreq-handles.SYSTEM.lowcutoff+1;
            end
                
            % IDENTIFY ONE-vs-REST, ONE-vs-ONE, or ONE-vs-ALL
            TaskInd=str2double(regexp(DisplayVar,'.\d+','match'));
            RegressType=1;
            if ~isempty(strfind(DisplayVar,'Rest'))
            elseif size(TaskInd,2)>1
                for i=1:size(handles.RegressSensor.sensorlabel{2},1)
                    if isequal(TaskInd,str2num(handles.RegressSensor.sensorlabel{2}(i,:)))
                        TaskInd=i;
                    end
                end
                RegressType=2;
            elseif ~isempty(strfind(DisplayVar,'All'))
                RegressType=3;
            end
                
            if ~exist(handles.RegressSensor.sensorfile{RegressType},'file');
                regressvar(value)=[];
                set(handles.regressvar,'string',regressvar,'value',size(regressvar,1));
                [hObject,handles]=bci_fESI_Reset(hObject,handles,'None',[]);
                fprintf(2,'SAVED SENSOR REGRESSION RESULTS FILE DOES NOT EXIST FOR TASK "%s"\n',regressvar{value});
            else
                load(handles.RegressSensor.sensorfile{RegressType});
                if isequal(AllFreq,1)
                    R=SaveRegressSensor.R(:,:,TaskInd);
                    pval=SaveRegressSensor.pval(:,:,TaskInd);
                    Rsq=SaveRegressSensor.Rsq(:,:,TaskInd);

                    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                    % PLOT R VALUES FOR ALL FREQUENCIES
                    axes(handles.axes1); cla
                    set(handles.Axis1Label,'string','R values');
                    imagesc(R);
                    xlabel('Freq (Hz)'); ylabel('Chan #');
                    LowCutoff=handles.SYSTEM.lowcutoff;
                    HighCutoff=handles.SYSTEM.highcutoff;
                    set(gca,'xtick',1:handles.SYSTEM.mwparam.NumFreq,'xticklabel',LowCutoff:HighCutoff);
                    view(0,90); axis xy; rotate3d off;
                    colorbar; caxis auto; caxis([-max(abs(caxis)) max(abs(caxis))]);

                    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                    % PLOT P VALUES FOR ALL FREQUENCIES
                    axes(handles.axes2); cla
                    set(handles.Axis2Label,'string','p values');
                    imagesc(pval);
                    xlabel('Freq (Hz)'); ylabel('Chan #');
                    set(gca,'xtick',1:handles.SYSTEM.mwparam.NumFreq,'xticklabel',LowCutoff:HighCutoff);
                    view(0,90); axis xy; rotate3d off; colorbar; caxis auto 

                    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                    % PLOT R-SQUARED VALUES FOR ALL FREQUENCIES
                    axes(handles.axes3); cla
                    set(handles.Axis3Label,'string','R-squared values');
                    imagesc(Rsq);
                    set(gca,'xtick',1:handles.SYSTEM.mwparam.NumFreq,'xticklabel',LowCutoff:HighCutoff);
                    xlabel('Freq (Hz)'); ylabel('Chan #');
                    view(0,90); axis xy; rotate3d off;set(gcf,'color',[.94 .94 .94]);
                    cmap=jet(256); colormap(cmap);
                    colorbar; caxis auto;  
                else
                    R=SaveRegressSensor.R(:,Freq,TaskInd);
                    Rsq=SaveRegressSensor.Rsq(:,Freq,TaskInd);
                    pval=SaveRegressSensor.pval(:,Freq,TaskInd);

                    
%                     R(pval>.05)=0;
%                     Rsq(pval>.05)=0;

                    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                    % PLOT FREQUENCY SPECIFIC R VALUES TOPO
                    axes(handles.axes1); cla
                    set(handles.Axis1Label,'string','R values');
                    topoplot(R,handles.SYSTEM.Electrodes.current.eLoc,'electrodes','ptlabels','numcontour',0);
                    view(0,90); axis xy; rotate3d off;
                    set(gcf,'color',[.94 .94 .94]); colorbar; caxis auto;

                    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                    % PLOT FREQUENCY SPECIFIC P VALUES TOPO
                    axes(handles.axes2); cla
                    set(handles.Axis2Label,'string','p values');
                    topoplot(pval,handles.SYSTEM.Electrodes.current.eLoc,'electrodes','ptlabels','numcontour',0);
                    view(0,90); axis xy; rotate3d off;
                    set(gcf,'color',[.94 .94 .94]); colorbar; caxis auto

                    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                    % PLOT FREQUENCY SPECIFIC R-SQUARED VALUES TOPO
                    axes(handles.axes3); cla
                    set(handles.Axis3Label,'string','R-squared values');
                    topoplot(Rsq,handles.SYSTEM.Electrodes.current.eLoc,'electrodes','ptlabels','numcontour',0);
                    view(0,90); axis xy; rotate3d off;
                    set(gcf,'color',[.94 .94 .94]);
                    cmap=jet(256); colormap(cmap); colorbar; caxis auto 
                end
            end

        elseif ~isequal(size(strfind(DisplayVar,'Source'),2),0)
            
            % IDENTIFY FREQUENCY FOR DISPLAY
            if ~isequal(AllFreq,1)
                Freq=RegressFreq-handles.SYSTEM.lowcutoff+1;
            end

            TaskInd=str2double(regexp(DisplayVar,'.\d+','match'));
            RegressType=1;
            if ~isempty(strfind(DisplayVar,'Rest'))
            elseif size(TaskInd,2)>1
                for i=1:size(handles.RegressSource.sourcelabel{2},1)
                    if isequal(TaskInd,str2num(handles.RegressSource.sourcelabel{2}(i,:)))
                        TaskInd=i;
                    end
                end
                RegressType=2;
            elseif ~isempty(strfind(DisplayVar,'All'))
                RegressType=3;
            end

            if ~exist(handles.RegressSource.sourcefile{RegressType},'file');
                regressvar(value)=[];
                set(handles.regressvar,'string',regressvar,'value',size(regressvar,1));
                [hObject,handles]=bci_fESI_Reset(hObject,handles,'None',[]);
                fprintf(2,'SAVED SOURCE REGRESSION RESULTS FILE DOES NOT EXIST FOR %s\n',regressvar{value});
            else
                load(handles.RegressSource.sourcefile{RegressType})
                if isequal(AllFreq,1)
                    
                    % Vertices or clusters
                    if ~isequal(size(strfind(DisplayVar,'Cluster'),2),0)
                        R=SaveRegressSource.cluster.R(:,:,TaskInd);
                        pval=SaveRegressSource.cluster.pval(:,:,TaskInd);
                        Rsq=SaveRegressSource.cluster.Rsq(:,:,TaskInd);
                    else
                        R=SaveRegressSource.vert.R(:,:,TaskInd);
                        pval=SaveRegressSource.vert.pval(:,:,TaskInd);
                        Rsq=SaveRegressSource.vert.Rsq(:,:,TaskInd);
                    end

                    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                    % PLOT R VALUES FOR ALL FREQUENCIES
                    axes(handles.axes1); cla
                    set(handles.Axis1Label,'string','R values');
                    imagesc(R);
                    LowCutoff=handles.SYSTEM.lowcutoff;
                    HighCutoff=handles.SYSTEM.highcutoff;
                    set(gca,'xtick',1:handles.SYSTEM.mwparam.NumFreq,'xticklabel',LowCutoff:HighCutoff);
                    view(0,90); axis xy; rotate3d off;
                    colorbar; caxis auto; caxis([-max(abs(caxis)) max(abs(caxis))]);

                    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                    % PLOT P VALUES FOR ALL FREQUENCIES
                    axes(handles.axes2); cla
                    set(handles.Axis2Label,'string','p values');
                    imagesc(pval);
                    set(gca,'xtick',1:handles.SYSTEM.mwparam.NumFreq,'xticklabel',LowCutoff:HighCutoff);
                    view(0,90); axis xy;
                    caxis auto; rotate3d off; colorbar
                            
                    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                    % PLOT R-SQUARED VALUES FOR ALL FREQUENCIES
                    axes(handles.axes3); cla
                    set(handles.Axis3Label,'string','R-squared values');
                    imagesc(Rsq);
                    set(gca,'xtick',1:handles.SYSTEM.mwparam.NumFreq,'xticklabel',LowCutoff:HighCutoff);
                    view(0,90); axis xy;  rotate3d off; colorbar
                    caxis auto; cmap=jet(256); colormap(cmap); 
                else
                    
%                     if ~exist(CortexFile,'file')
%                         fprintf(2,'SAVED CORTEX FILE DOES NOT EXIST, SET PARAMETERS TO RESAVE\n');
%                         SaveFiles(value)=[];
%                         set(handles.SaveFiles,'string',SaveFiles);
%                         set(handles.SaveFiles,'value',size(SaveFiles,1));
%                     else
%                         load(CortexFile);
%                     load(handles.ESI.savefile)
%                     SaveCortex=SaveESI.ESI.cortex;
                    SaveCortex=handles.ESI.cortex;
%                     SaveCortex=load('M:\brainstorm_db\bci_fESI\anat\BE\tess_cortex_pial_low_fig.mat');

                    R=-.1*ones(1,size(SaveCortex.Vertices,1));
                    Rsq=-.1*ones(1,size(SaveCortex.Vertices,1));
                    pval=-.1*ones(1,size(SaveCortex.Vertices,1));
                    if ~isequal(size(strfind(DisplayVar,'Cluster'),2),0)
                        clusters=handles.ESI.clusters;
                        for i=1:size(clusters,2)-1
                            R(clusters{i})=repmat(SaveRegressSource.cluster.R(i,Freq,TaskInd),[1 size(clusters{i},2)]);
                            Rsq(clusters{i})=repmat(SaveRegressSource.cluster.Rsq(i,Freq,TaskInd),[1 size(clusters{i},2)]);
                            pval(clusters{i})=repmat(SaveRegressSource.cluster.pval(i,Freq,TaskInd),[1 size(clusters{i},2)]);
                        end
                    else
                        R(SaveRegressSource.verticesinclude)=SaveRegressSource.vert.R(:,Freq,TaskInd);
                        Rsq(SaveRegressSource.verticesinclude)=SaveRegressSource.vert.Rsq(:,Freq,TaskInd);
                        pval(SaveRegressSource.verticesinclude)=SaveRegressSource.vert.pval(:,Freq,TaskInd);
                    end
                    
%                     R(pval>.05)=-.1;
%                     Rsq(pval>.05)=-.1;

                    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                    % PLOT FREQUENCY SPECIFIC R VALUES ON CORTEX
                    axes(handles.axes1); cla
                    set(handles.Axis1Label,'string','R values');
                    h=trisurf(SaveCortex.Faces,SaveCortex.Vertices(:,1),...
                        SaveCortex.Vertices(:,2),SaveCortex.Vertices(:,3),R);
                    set(h,'FaceColor','interp','EdgeColor','None','FaceLighting','gouraud');
                    axis equal; axis off; view(-90,90); caxis auto; rotate3d on;
                    light; h2=light; lightangle(h2,90,-90); h3=light;lightangle(h3,-90,30);
                    colorbar; caxis auto; caxis([-max(abs(caxis)) max(abs(caxis))]); 
                        
                    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                    % PLOT FREQUENCY SPECIFIC P VALUES ON CORTEX
                    axes(handles.axes2); cla
                    set(handles.Axis2Label,'string','p values');
                    h=trisurf(SaveCortex.Faces,SaveCortex.Vertices(:,1),...
                        SaveCortex.Vertices(:,2),SaveCortex.Vertices(:,3),pval);
                    set(h,'FaceColor','interp','EdgeColor','None','FaceLighting','gouraud');
                    axis equal; axis off; view(-90,90); rotate3d on;
                    light; h2=light; lightangle(h2,90,-90); h3=light;lightangle(h3,-90,30);
                    caxis auto;  colorbar

                    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                    % PLOT FREQUENCY SPECIFIC R-SQUARED VALUES ON CORTEX
                    axes(handles.axes3); cla
                    set(handles.Axis3Label,'string','R-squared values');
                    h=trisurf(SaveCortex.Faces,SaveCortex.Vertices(:,1),...
                        SaveCortex.Vertices(:,2),SaveCortex.Vertices(:,3),Rsq);
                    set(h,'FaceColor','interp','EdgeColor','None','FaceLighting','gouraud');
                    axis equal; axis off; view(-90,90); rotate3d on
                    light; h2=light; lightangle(h2,90,-90); h3=light;lightangle(h3,-90,30);
                    cmap=jet(256); cmap(1,:)=repmat([.85 .85 .85],1,1); colormap(cmap);  
                    caxis auto; colorbar
                        
                    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                    % OUTLINE CLUSTERS
                    ShowClusters=get(handles.ShowClusters,'value');
                    if isequal(ShowClusters,1)
%                         load(handles.ESI.savefile)
%                         clusters=SaveESI.ESI.clusters;
                        clusters=handles.ESI.clusters;
                        
                        set(h,'FaceAlpha',.75)
                        hold on
                        V=SaveCortex.Vertices;
                        for i=1:size(clusters,2)-1
                            Vtmp=V(clusters{i},:);
                            hullIndexes=convhulln(Vtmp(:,1:2));
                            hullIndexes=hullIndexes(:,2);
                            Vhull=Vtmp(hullIndexes,:);
                            f=[1:size(Vhull,1) 1];
                            patch('Faces',f,'Vertices',Vhull,...
                                'EdgeColor','k','FaceColor','none','LineWidth',1.5);
                        end
                    end
                    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                        
                end
            end
        else
            [hObject,handles]=bci_fESI_Reset(hObject,handles,'None',[]);
        end
    end
end
