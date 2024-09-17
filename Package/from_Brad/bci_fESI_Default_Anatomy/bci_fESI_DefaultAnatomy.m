function [hObject,handles]=bci_fESI_DefaultAnatomy(hObject,handles)

rootdir=handles.SYSTEM.rootdir;

value=get(hObject,'value');
if isequal(value,1)
    cortex=strcat(rootdir,'\from_Brad\bci_fESI_Default_Anatomy\Default_Cortex15000V.mat');
    if exist(cortex,'file')
        set(handles.cortexfile,'string',cortex)
    else
        fprintf(2,'CORTEX FILE DOES NOT EXIST IN DEFAULT ANATOMY DIRECTORY\n'); 
    end

    cortexlr=strcat(rootdir,'\from_Brad\bci_fESI_Default_Anatomy\Default_InflateCortex1000V.mat');
    if exist(cortexlr,'file')
        set(handles.cortexlrfile,'string',cortexlr)
    else
        fprintf(2,'INFLATED CORTEX FILE DOES NOT EXIST IN DEFAULT ANATOMY DIRECTORY\n'); 
    end
    
    brainregionfile=strcat(rootdir,'\from_Brad\bci_fESI_Default_Anatomy\Default_BrainRegions.mat');
    if exist(brainregionfile,'file')
        set(handles.brainregionfile,'string',brainregionfile)
    else
        fprintf(2,'BRAIN REGIONS FILE DOES NOT EXIST IN DEFAULT ANATOMY DIRECTORY\n'); 
    end
    
    eegsystem=get(handles.eegsystem,'value');
    switch eegsystem
        case 1 % None
            fprintf(2,'MUST SELECT AN EEG SYSTEM IN ORDER TO LOAD DEFAULT HEAD MODEL\n');
        case 2 % Neuroscan 64
            headmodel=strcat(rootdir,'\from_Brad\bci_fESI_Default_Anatomy\Default_Headmodel_NSL64.mat');
            if exist(headmodel,'file');
                set(handles.headmodelfile,'string',headmodel);
            else
                fprintf(2,'HEADMODEL FOR NS64 DOES NOT EXIST IN DEFAULT ANATOMY DIRECTORY\n');
            end
        case 3 % Neuroscan 128
            headmodel=strcat(rootdir,'\from_Brad\bci_fESI_Default_Anatomy\Default_Headmodel_NSL128.mat');
            if exist(headmodel,'file');
                set(handles.headmodelfile,'string',headmodel);
            else
                fprintf(2,'HEADMODEL FOR NS128 DOES NOT EXIST IN DEFAULT ANATOMY DIRECTORY\n');
            end
        case 4 % BioSemi 64
            headmodel=strcat(rootdir,'\from_Brad\bci_fESI_Default_Anatomy\Default_Headmodel_BS64.mat');
            if exist(headmodel,'file');
                set(handles.headmodelfile,'string',headmodel);
            else
                fprintf(2,'HEADMODEL FOR BS64 DOES NOT EXIST IN DEFAULT ANATOMY DIRECTORY\n');
            end
        case 5 % BioSemi 128
            headmodel=strcat(rootdir,'\from_Brad\bci_fESI_Default_Anatomy\Default_Headmodel_BS128.mat');
            if exist(headmodel,'file');
                set(handles.headmodelfile,'string',headmodel);
            else
                fprintf(2,'HEADMODEL FOR BS128 DOES NOT EXIST IN DEFAULT ANATOMY DIRECTORY\n');
            end
        case 6 % SigGen
            headmodel=strcat(rootdir,'\from_Brad\bci_fESI_Default_Anatomy\Default_Headmodel_SG16.mat');
            if exist(headmodel,'file');
                set(handles.headmodelfile,'string',headmodel);
            else
                fprintf(2,'HEADMODEL FOR SG16 DOES NOT EXIST IN DEFAULT ANATOMY DIRECTORY\n');
            end
    end
    
else
    
    if isfield(handles,'default')
        if isfield(handles.default,'cortexfile')
            set(handles.cortexfile,'string',handles.default.cortexfile);
        end
        
        if isfield(handles.default,'cortexlrfile')
            set(handles.cortexlrfile,'string',handles.default.cortexlrfile);
        end
        
        if isfield(handles.default,'headmodelfile')
            set(handles.headmodelfile,'string',handles.default.headmodelfile);
        end
        
        if isfield(handles.default,'fmrifile')
            set(handles.fmrifile,'string',handles.default.fmrifile);
        end
        
        if isfield(handles.default,'brainregionfile')
            set(handles.brainregionfile,'string',handles.default.brainregionfile);
        end
        
    else
        set(handles.cortexfile,'string','');
        set(handles.cortexlrfile,'string','');
        set(handles.headmodelfile,'string','');
        set(handles.fmrifile,'string','');
        set(handles.brainregionfile,'string','');
    end
    
end