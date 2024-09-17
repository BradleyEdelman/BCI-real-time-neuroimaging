function [hObject,handles]=bci_fESI_CheckESI(hObject,handles)

SetSystem=get(handles.SetSystem,'userdata');

if isequal(SetSystem,1)

    set(hObject,'backgroundcolor','green','userdata',1);
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % CHECK NOISE
    noise=get(handles.noise,'value');
    set(handles.noisefile,'backgroundcolor','green')
    switch noise
        case {1,2} % None selected or no noise estimation
            fprintf(2,'   NO NOISE ESTIMATION; USING IDENTITY NOISE MATRIX\n');
        case {3,4} % Diagonal or full noise covariance
            noisefile=get(handles.noisefile,'string');
            if ~exist(noisefile,'file')
                fprintf(2,'   NOISE DATA FILE DOES NOT EXIST, USING IDENTITY NOISE MATRIX\n');
                set(handles.noise,'value',2);
                set(handles.noisefile,'backgroundcolor',[1 .7 0])
            elseif ~strcmp(noisefile(end-2:end),'Dat') &&...
                    ~strcmp(noisefile(end-2:end),'mat')
                fprintf(2,'   NOISE DATA FILE NOT IN .DAT or .mat FORMAT, USING IDENTITY NOISE MATRIX\n');
                set(handles.noise,'value',2);
                set(handles.noisefile,'backgroundcolor',[1 .7 0])
            elseif strcmp(noisefile(end-2:end),'mat')
                noisestruct=load(noisefile);
                noisechan=size(noisestruct.Dat(1).eeg,1);
                CurrentChan=size(handles.SYSTEM.Electrodes.current.eLoc,2);
                if ~isequal(noisechan,CurrentChan);
                  fprintf(2,'NOISE DATA CHANNEL SIZE NOT COMPATIBLE WITH SELECTED CHANNELS\n');
                  set(handles.noisefile,'backgroundcolor','red');
                end
            elseif strcmp(noisefile(end-2:end),'Dat')
                % LOAD EEGLAB
            end
    end

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % CHECK CORTEX
    cortexfile=get(handles.cortexfile,'string');
    set(handles.cortexfile,'backgroundcolor','green')
    if ~exist(cortexfile,'file')
        fprintf(2,'CORTEX NOT SELECTED\n');
        set(handles.cortexfile,'backgroundcolor','red')
        set(hObject,'backgroundcolor','red','userdata',0)
    else
        cortex=load(cortexfile);
        if ~isfield(cortex,'Vertices')
            fprintf(2,'CORTEX FILE MISSING VERTICES\n');
            set(hObject,'backgroundcolor','red','userdata',0)
            set(handles.cortexfile,'backgroundcolor','red')
        elseif ~isfield(cortex,'Faces')
            fprintf(2,'CORTEX FILE MISSING FACES\n');
            set(hObject,'backgroundcolor','red','userdata',0)
            set(handles.cortexfile,'backgroundcolor','red')
        elseif ~isfield(cortex,'SulciMap')
            fprintf(2,'CORTEX FILE MISSING SULCIMAP\n');
            set(hObject,'backgroundcolor','red','userdata',0)
            set(handles.cortexfile,'backgroundcolor','red')
        end
    end

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % CHECK LOW RESOLUTION CORTEX
    lrvizsource=get(handles.lrvizsource,'value');
    if isequal(lrvizsource,1)
        cortexlrfile=get(handles.cortexlrfile,'string');
        set(handles.cortexlrfile,'backgroundcolor','green')
        if ~exist(cortexlrfile,'file')
            fprintf(2,'LOW RESOLUTION CORTEX NOT SELECTED\n');
            set(hObject,'backgroundcolor','red','userdata',0)
            set(handles.cortexlrfile,'backgroundcolor','red');
        else
            cortexlr=load(cortexlrfile);
            if ~isfield(cortexlr,'Vertices')
                fprintf(2,'LOW RESOLUTION CORTEX FILE MISSING VERTICES\n');
                set(hObject,'backgroundcolor','red','userdata',0)
                set(handles.cortexlrfile,'backgroundcolor','red')
            elseif size(cortex.Vertices,1)/3<size(cortexlr.Vertices,1)
                fprintf(2,'LOW RESOLUTION CORTEX MUST BE AT LEAST THREE TIMES ROUGHER THAN ORIGINAL\n');
                set(hObject,'backgroundcolor','red','userdata',0)
                set(handles.cortexlrfile,'backgroundcolor','red')
            elseif ~isfield(cortexlr,'Faces')
                fprintf(2,'LOW RESOLUTION CORTEX FILE MISSING FACES\n');
                set(hObject,'backgroundcolor','red','userdata',0)
                set(handles.cortexlrfile,'backgroundcolor','red')
            end
        end
    end

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % CHECK EEG SYSTEM
    eegsystem=get(handles.eegsystem,'value');
    if isequal(eegsystem,1)
        set(hObject,'backgroundcolor','red','userdata',0)
        set(handles.eegsystem,'backgroundcolor','red')
    else
        headmodelfile=get(handles.headmodelfile,'string');
        set(handles.headmodelfile,'backgroundcolor','green')
        if ~exist(headmodelfile,'file')
            fprintf(2,'HEADMODEL NOT SELECTED\n');
            set(handles.headmodelfile,'backgroundcolor','red')
            set(hObject,'backgroundcolor','red','userdata',0)
        else
            headmodel=load(headmodelfile);
            if ~isfield(headmodel,'Gain')
                fprintf(2,'HEADMODEL FILE MISSING GAIN MATRIX\n');
                set(hObject,'backgroundcolor','red','userdata',0)
                set(handles.headmodelfile,'backgroundcolor','red')
            elseif ~isfield(headmodel,'GridOrient')
                fprintf(2,'HEADMODEL FILE MISSING GAIN MATRIX\n');
                set(hObject,'backgroundcolor','red','userdata',0)
                set(handles.headmodelfile,'backgroundcolor','red')
            elseif ~isequal(size(headmodel.Gain,1),size(handles.SYSTEM.Electrodes.original.eLoc,2))
                fprintf(2,'ELECTRODE NUMBER DOES NOT MATCH GAIN MATRIX\n');
                set(hObject,'backgroundcolor','red','userdata',0)
                set(handles.headmodelfile,'backgroundcolor','red')
            elseif ~isfield(headmodel,'GridLoc')
                fprintf(2,'HEADMODEL FILE MISSING SOURCE LOCATIONS\n');
                set(hObject,'backgroundcolor','red','userdata',0)
                set(handles.headmodelfile,'backgroundcolor','red')
            elseif ~isequal(size(headmodel.Gain,2)/3,size(cortex.Vertices,1))
                fprintf(2,'INCONSISTENT # OF DIPOLES IN HEADMODEL AND CORTEX\n');
                set(hObject,'backgroundcolor','red','userdata',0)
                set(handles.headmodelfile,'backgroundcolor','red')
            elseif ~isequal(headmodel.GridLoc,cortex.Vertices)
                fprintf(2,'HEADMODEL AND CORTEX DO NOT HAVE SAME SOURCE LOCATIONS\n');
                set(hObject,'backgroundcolor','red','userdata',0)
                set(handles.headmodelfile,'backgroundcolor','red')
            end
        end
    end

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % CHECK fMRI PRIOR
    fmrifile=get(handles.fmrifile,'string');
    set(handles.fmrifile,'backgroundcolor','green')
    if isempty(fmrifile)
        set(handles.fmrifile,'backgroundcolor','white')
    else
        if ~exist(fmrifile,'file')
            fprintf(2,'FMRI FILE DOES NOT EXIST\n');
            set(handles.fmrifile,'backgroundcolor','red')
            set(hObject,'backgroundcolor','red','userdata',0)
        elseif ~strcmp(fmrifile(end-2:end),'gii')
            fprintf(2,'FMRI RESULTS NOT .GII FORMAT\n');
            set(handles.fmrifile,'backgroundcolor','red')
            set(hObject,'backgroundcolor','red','userdata',0)
        else
            fmri=gifti(fmrifile);
            if ~isfield(fmri,'cdata')
                fprintf(2,'FMRI PRIOR FILE MISSING DATA\n');
                set(hObject,'backgroundcolor','red','userdata',0)
                set(handles.fmrifile,'backgroundcolor','red')
            elseif ~isfield(fmri,'faces')
                fprintf(2,'FMRI PRIOR FILE MISSING FACES\n');
                set(hObject,'backgroundcolor','red','userdata',0)
                set(handles.fmrifile,'backgroundcolor','red')
            elseif ~isfield(fmri,'vertices')
                fprintf(2,'FMRI PRIOR FILE MISSING VERTICES\n');
                set(hObject,'backgroundcolor','red','userdata',0)
                set(handles.fmrifile,'backgroundcolor','red')
            elseif ~isequal(size(fmri.vertices,1),size(cortex.Vertices,1))
                fprintf(2,'INCONSISTENT # OF DIPOLES IN FMRI PRIOR AND CORTEX\n');
                set(hObject,'backgroundcolor','red','userdata',0)
                set(handles.fmrifile,'backgroundcolor','red')
            elseif ~isequal(fmri.faces,cortex.Faces)
                fprintf(2,'FMRI PRIOR AND CORTEX DO NOT HAVE SAME SOURCE LOCATIONS\n');
                set(hObject,'backgroundcolor','red','userdata',0)
                set(handles.fmrifile,'backgroundcolor','red')
            end
        end
    end

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % CHECK BRAIN REGIONS
    brainregions=get(handles.selectbrainregions,'userdata');
    set(handles.selectbrainregions,'backgroundcolor','green')
    if isempty(brainregions) || isequal(sum(brainregions),0)
        fprintf(2,'NO BRAIN REGIONS SELECTED\n');
        set(handles.selectbrainregions,'backgroundcolor','red');
        set(hObject,'backgroundcolor','red','userdata',0); 
    end

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % CHECK CORTICAL PARCELLATION 
    parcellation=get(handles.parcellation,'value');
    set(handles.parcellation,'backgroundcolor','green');
    switch parcellation 
        case 1 % None Selected
        case 2 % None
        case 3 % MSP

            esifiles=cellstr(get(handles.esifiles,'string'));
            empty=0;
            for i=1:size(esifiles,1)
                if isempty(esifiles{i})
                    empty=empty+1;
                elseif size(esifiles{i},2)<4
                    fprintf(2,'%s NOT OF COMPATIBLE FORMAT\n',esifiles{i});
                    set(hObject,'backgroundcolor','red','userdata',0)
                elseif isempty(strfind(esifiles{i},'.dat'))
                    fprintf(2,'%s NOT OF COMPATIBLE FORMAT\n',esifiles{i});
                    set(hObject,'backgroundcolor','red','userdata',0)
                end
            end
            
            if empty>0
                fprintf(2,'NO ESI FILES SELECTED\n');
                set(hObject,'backgroundcolor','red','userdata',0)
            end

        case 4 % k-means
    end
    
else
    fprintf(2,'SYSTEM PARAMETERS HAVE NOT BEEN SET\n');
    set(hObject,'backgroundcolor','red')
end











