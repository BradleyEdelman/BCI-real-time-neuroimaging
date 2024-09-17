function [hObject,handles]=bci_fESI_SelectBrainRegions(hObject,handles)

% Extract brain regions from specified file
brainregionfile=get(handles.brainregionfile,'string');
set(handles.brainregionfile,'backgroundcolor','green');
cortexfile=get(handles.cortexfile,'string');
if isempty(brainregionfile) || strcmp(brainregionfile,'') ||...
        size(brainregionfile,2)<4
    fprintf(2,'BRAIN REGION FILE NOT SELECTED, CANNOT SELECT BRAIN REGIONS\n');
    set(handles.brainregionfile,'backgroundcolor','red');
elseif ~strcmp(brainregionfile(end-3:end),'.mat')
    fprintf(2,'BRAIN REGION FILE MUST BE .MAT FORMAT\n');
    set(handles.brainregionfile,'backgroundcolor','red');
elseif isempty(cortexfile) || strcmp(cortexfile,'') || size(cortexfile,2)<4
    fprintf(2,'CORTEX FILE NOT SELECTED, CANNOT SELECT BRAIN REGIONS\n');
else
    BrainRegions=load(brainregionfile);
    cortex=load(cortexfile);
    if ~isfield(BrainRegions,'Scouts')
        fprintf(2,'BRAIN REGION FILE MUST CONTAIN "SCOUTS" - IDENTIFYING REGIONS\n');
        set(handles.brainregionfile,'backgroundcolor','red');
    elseif ~isfield(BrainRegions.Scouts,'Label')
        fprintf(2,'BRAIN REGION FILE MUST CONTAIN LABELS\n');
        set(handles.brainregionfile,'backgroundcolor','red');
    else
        NumRegion=size(BrainRegions.Scouts,2);
        RegionsLabels={BrainRegions.Scouts.Label};
        if NumRegion<=14

            handles.RegionsBrain.cortex=cortex;
            handles.RegionsBrain.scouts=BrainRegions.Scouts;

            set(hObject,'backgroundcolor','white');
            handles.RegionsBrainFig=figure;
            set(handles.RegionsBrainFig,'MenuBar','none','ToolBar','none','color',[.94 .94 .94]);
            rotate3d on

            % Assigned plotting axes
            handles.RegionsBrainAxes=axes('Parent',handles.RegionsBrainFig,'Units','pixels',...
                'HandleVisibility','callback','Position',[175 25 375 370]); axis off

            if isfield(handles,'RegionsBrain') && ~isempty(handles.RegionsBrain) &&...
                    isfield(handles.RegionsBrain,'radio') && ~isempty(handles.RegionsBrain.radio)
                handles.RegionsBrain.radio(NumRegion+1:end)=[];
            end

            % Create radio buttons for each region
            for i=1:NumRegion
                handles.RegionsBrain.radio(i)=uicontrol('Style','radiobutton','Callback',...
                    @myRadio,'Units','pixels','Position',[15,375-25*(i-1),150,25],...
                    'string',RegionsLabels{i},'value',0,'FontSize',9);
            end

            % Create colormap
            cmap=[.85 .85 .85;1 0 1;1 0 .5;.45 .45 1;.6 .6 0;.55 1 .75;...
                .6 .3 0;1 .8 .8;1 0 0;1 .5 0;1 1 0;0 1 0;0 1 1;0 0 1;.5 0 1];
            cmap1=[2 3 4 5 6 7 8 9 10 11 12 13 14 15];

            % Plot blank brain
            BrainDisplay=zeros(1,size(cortex.Vertices,1));
            h=trisurf(cortex.Faces,cortex.Vertices(:,1),cortex.Vertices(:,2),...
                cortex.Vertices(:,3),BrainDisplay);
            set(h,'FaceColor','flat','EdgeColor','none','FaceLighting','gouraud');
            axis equal; axis off; view(-90,90)
            colormap(cmap); caxis([0 16]); light;
            h2=light; lightangle(h2,90,-90); h3=light;lightangle(h3,-90,30);

            % Check if brain regions have already been selected - if so, plot
            if isequal(size(get(hObject,'userdata'),1),NumRegion) && ~isequal(get(hObject,'userdata'),zeros(NumRegion,1))
                OldRadioVal=get(hObject,'userdata');
                for i=1:size(get(hObject,'userdata'),1)
                    set(handles.RegionsBrain.radio(i),'value',OldRadioVal(i));
                end

                BrainDisplay=zeros(1,size(cortex.Vertices,1));
                for i=1:size(OldRadioVal,1)
                    if isequal(OldRadioVal(i),1)
                        BrainDisplay(BrainRegions.Scouts(i).Vertices)=cmap1(i);
                    end
                end

                h=trisurf(cortex.Faces,cortex.Vertices(:,1),cortex.Vertices(:,2),...
                    cortex.Vertices(:,3),BrainDisplay);
                set(h,'FaceColor','flat','EdgeColor','None','FaceLighting','gouraud');
                axis equal; axis off; view(-90,90)
                colormap(cmap); caxis([0 16]);
                light; h2=light; lightangle(h2,90,-90); h3=light;lightangle(h3,-90,30);
            end
                text1=uicontrol('style','text','string',...
                    'Select brain regions for training data','Position',[105 395 350 25],'FontSize',13.5);

                text2=uicontrol('style','text','string',...
                    '*Must ensure brain region file uses same brain as specified cortex',...
                    'Position',[125 10 350 15],'FontSize',8);

                btn1=uicontrol('style','pushbutton','string','Save & Close','Position',...
                    [10 10 125 20],'Callback','close');

                guidata(handles.RegionsBrainFig,handles);

        else
            fprintf(2,'MUST HAVE LESS THAN 15 BRAIN REGIONS...\n');
        end
    end
end


function myRadio(RadioH,EventData)
handles=guidata(RadioH);

if isempty(get(handles.cortexfile,'string'))  
else
    cortex=handles.RegionsBrain.cortex;
    Scouts=handles.RegionsBrain.scouts;
    cmap=[.85 .85 .85;1 0 1;1 0 .5;.45 .45 1;.6 .6 0;.55 1 .75;...
                .6 .3 0;1 .8 .8;1 0 0;1 .5 0;1 1 0;0 1 0;0 1 1;0 0 1;.5 0 1];
    cmap1=[2 3 4 5 6 7 8 9 10 11 12 13 14 15];
    
    BrainDisplay=zeros(1,size(cortex.Vertices,1));
    RegionOnOff=cell2mat(get(handles.RegionsBrain.radio,'value'));
        
    for i=1:size(RegionOnOff,1)
        if isequal(RegionOnOff(i),1)
            BrainDisplay(Scouts(i).Vertices)=cmap1(i);
        end
    end
    
    h=trisurf(cortex.Faces,cortex.Vertices(:,1),cortex.Vertices(:,2),...
        cortex.Vertices(:,3),BrainDisplay);
    set(h,'FaceColor','flat','EdgeColor','None','FaceLighting','gouraud');
    axis equal; axis off; view(-90,90)
    colormap(cmap); caxis([0 16]); light;
    h2=light; lightangle(h2,90,-90); h3=light;lightangle(h3,-90,30);
end
% Save "on/off" state of brain regions for future use
set(handles.selectbrainregions,'userdata',cell2mat(get(handles.RegionsBrain.radio,'value')))