function [hObject,handles]=bci_fESI_Load(hObject,handles,Type)


if strcmp(Type,'SYSTEM')
    
    stringfields={'initials','session','run','year','month','day',...
        'savepath','fs','lowcutoff','highcutoff','dsfactor'};
            
    valuefields={'tasktype','domain','eegsystem','psd'};
            
    handlefields={'masterdir','subdir','sessiondir','savefiledir',...
        'filter','Electrodes','mwparam','morwav'};
    
    userdatafields={};
    
    % Unmatched import fields
    extrainput={'Electrodes'};
    extraoutput={'selectsensors'};
    
    proceed={'SetSystem'};
    

elseif strcmp(Type,'ESI')
    
    stringfields={'cortexfile','cortexlrfile','headmodelfile','fmrifile',...
        'brainregionfile','noisefile','esifiles'};
    
    valuefields={'parcellation','noise'};
    
    handlefields={'cortex','cortexlr','lrinterp','headmodel','psd',...
        'noisecov','whitener','fmriprioridx','fmripriorval','jfmri',...
        'wfmri','selectbrainregions','vertidxinclude','vertidxexclude',...
        'leadfield','leadfieldweights','clusters','vertclusterassignment',...
        'clusterleadfield','clustersourcecov','residualsolution',...
        'lambdasq','inv'};
    
    userdatafields={'selectbrainregions'};
    
    extrainput={};
    extraoutput={};
    
    proceed={'CheckESI','SetESI'};
    
    savevar={'Cortex' 'Lead Field' 'Noise Covariance' 'Source Covariance'...
        'Source Prior' 'Clusters'};
    set(handles.savefiles,'string',savevar)
    
    
elseif strcmp(Type,'REGRESSION')    
    
    stringfields={};
    
    valuefields={};
    
    handlefields={};
    
    userdatafields={};
    
    Proceed={};

elseif strcmp(Type,'BCI')
    
    stringfields={};
    
    valuefields={};
    
    handlefields={};
    
    userdatafields={};
    
    proceed={'CheckBCI','SetESI'};

else
    
    fprintf(2,'NOT A VALID FILE TYPE TO LOAD\n');
    
end


savepath=get(handles.savepath,'String');
[filename,pathname]=uigetfile(strcat(savepath,'\*.mat*'));
file=strcat(pathname,filename);

if isempty(strfind(file,Type))
    fprintf(2,'MUST SELECT A "%s" FILE TO LOAD %s PARAMETERS\n',Type,Type);
else
    load(file);

    savevar=matlab.lang.makeValidName(strcat('Save',Type));

    if exist(savevar,'var')
        
        % STRING FIELDS
        for i=1:size(stringfields,2)
            if isfield(eval(savevar),stringfields{i})
                set(handles.(stringfields{i}),'backgroundcolor','green',...
                    'string',eval([savevar '.' (stringfields{i});]));
                handles.(Type).(stringfields{i})=eval([savevar '.' (stringfields{i});]);
            end
        end
        
        % VALUE FIELDS
        for i=1:size(valuefields,2)
            if isfield(eval(savevar),valuefields{i})
                set(handles.(valuefields{i}),'backgroundcolor','green',...
                    'value',eval([savevar '.' (valuefields{i});]));
                handles.(Type).(valuefields{i})=eval([savevar '.' (valuefields{i});]);
            end
        end
        
        % UserData Fields
        for i=1:size(userdatafields,2)
            if isfield(eval(savevar),userdatafields{i})
                set(handles.(userdatafields{i}),'userdata',eval([savevar '.' (userdatafields{i});]));
            end
        end
        
        % HANDLE TYPE FIELDS
        for i=1:size(handlefields,2)
            if isfield(eval(savevar),handlefields{i})
                handles.(Type).(handlefields{i})=eval([savevar '.' (handlefields{i});]);
            end
        end

        
        
        % HANDLE FIELDS
        for i=1:size(extrainput,2)
            if isfield(eval(savevar),extrainput{i})
                handles.(extrainput{i})=eval([savevar '.' (extrainput{i});]);
                
                if strcmp(extrainput{i},'Electrodes')
                    tmp=ones(size(eval([savevar '.Electrodes.original.eLoc']),2),1);
                    tmp(eval([savevar '.Electrodes.chanidxexclude']))=0;
                    set(handles.selectsensors,'userdata',tmp,'backgroundcolor','green');
                end

            end
        end
        
        for i=1:size(proceed,2)
            set(handles.(proceed{i}),'backgroundcolor','green','userdata',1);
        end
        
        
    end

end


