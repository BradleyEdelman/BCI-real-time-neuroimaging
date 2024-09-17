function [hObject,handles]=bci_fESI_DefaultHandles(hObject,handles,HandleField)


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% INITIALIZE CUSTOM HANDLES


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                                 SYSTEM                                  %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
SYSTEM=struct('masterdir',[],'subdir',[],'sessiondir',[],'savefiledir',[],...
    'initials',[],'session',[],'run',[],'year',[],'month',[],'day',[],...
    'savepath',[],'eegsystem',[],'fs',[],'Electrodes',[],'psd',[],...
    'lowcutoff',[],'highcutoff',[],'filter',[],'dsfactor',[]);

    SYSTEM.Electrodes=struct('original',[],'current',[],'chanidxexclude',...
        [],'chanidxinclude',[]);
        SYSTEM.Electrodes.original=struct('eLoc',[]);
        SYSTEM.Electrodes.current=struct('eLoc',[],'plotX',[],'plotY',...
            [],'plotZ',[]);
    SYSTEM.filter=struct('a',[],'b',[]);
    
    
    
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                                   ESI                                   %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
ESI=struct('cortexfile',[],'cortex',[]','cortexlrfile',[],'cortexlr',[],...
    'lrinterp',[],'headmodelfile',[],'headmodel',[],'psd',[],'noise',[],...
    'noisefile',[],'noisecov',[],'whitener',[],'fmrifile',[],...
    'fmriprioridx',[],'fmripriorval',[],'jfmri',[],'wfmri',[],...
    'brainregionfile',[],'selectbrainregions',[],'vertidxinclude',[],...
    'vertidxexclude',[],'vertclusterassignment',[],'leadfield',[],...
    'leadfieldweights',[],'parcellation',[],'esifiles',[],'clusters',[],...
    'clusterleadfield',[],'clustersourcecov',[],'residualsolution',[],...
    'lambdasq',[],'inv',[]);

    ESI.leadfield=struct('original',[]','cluster',[],'whitened',[]);
    ESI.whitener=struct('nomodel',[],'real',[],'imag',[]);
    ESI.noisecov=struct('nomodel',[],'real',[],'imag',[]);
    ESI.lambdasq=struct('nomodel',[],'real',[],'imag',[]);
    ESI.inv=struct('nomodel',[],'real',[],'imag',[]);
    
    
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                                TRAINING                                 %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% TRAINING=struct('Sensor',[],'Source',[],'param',[]);
% 
%     TRAINING.Sensor=struct('NumTask',[],'taskinfo',[],'trialstruct',[],...
%         'data',[],'features',[]);
%         TRAINING.Sensor.features=struct('freq',[],'time',[]);
%              TRAINING.Sensor.features.freq=struct('regress',[],'rlda',[],'pca',[],'fda',[]);
%                 TRAINING.Sensor.features.freq.regress=struct('file',[],'label',[]);
%                 TRAINING.Sensor.features.freq.rlda=struct('file',[],'label',[]);
%                 TRAINING.Sensor.features.freq.pca=struct('file',[],'label',[]);
%                 TRAINING.Sensor.features.freq.fda=struct('file',[],'label',[]);
%              TRAINING.Sensor.features.time=struct('regress',[],'rlda',[],'pca',[],'fda',[]);
%                 TRAINING.Sensor.features.time.regress=struct('file',[],'label',[]);
%                 TRAINING.Sensor.features.time.rlda=struct('file',[],'label',[]);
%                 TRAINING.Sensor.features.time.pca=struct('file',[],'label',[]);
%                 TRAINING.Sensor.features.time.fda=struct('file',[],'label',[]);
% 
%     TRAINING.Source=struct('NumTask',[],'taskinfo',[],'trialstruct',[],...
%         'data',[]);
%         TRAINING.Source.features=struct('freq',[],'time',[]);
%              TRAINING.Source.features.freq=struct('regress',[],'rlda',[],'pca',[],'fda',[]);
%                 TRAINING.Source.features.freq.regress=struct('file',[],'label',[],'type',[]);
%                 TRAINING.Source.features.freq.rlda=struct('file',[],'label',[]);
%                 TRAINING.Source.features.freq.pca=struct('file',[],'label',[]);
%                 TRAINING.Source.features.freq.fda=struct('file',[],'label',[]);
%              TRAINING.Source.features.time=struct('regress',[],'rlda',[],'pca',[],'fda',[]);
%                 TRAINING.Source.features.time.regress=struct('file',[],'label',[],'type',[]);
%                 TRAINING.Source.features.time.rlda=struct('file',[],'label',[]);
%                 TRAINING.Source.features.time.pca=struct('file',[],'label',[]);
%                 TRAINING.Source.features.time.fda=struct('file',[],'label',[]);
                
                
                
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                                   BCI                                   %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% BCI=struct('tempdomainfield',[],'spatdomainfield',[],'psd',[],'dsfactor',...
%     [],'fsextract',[],'fsprocess',[],'analysiswindowextract',[],...
%     'analysiswindowprocess',[],'updatewindowextract',[],'control',[],...
%     'normidx',[],'targetid',[],'targetwords',[],'hitcriteria',[],'task',...
%     [],'chanidxinclude',[],'regress',[],'rlda',[],'featureoptions',[],...
%     'savefile',[]);
% 
%     BCI.control=struct('idx',[],'w',[],'w0',[],'freqidx',[]);
%     BCI.rlda=struct('file',[],'freqval',[],'taskval',[],'lambda',[]);
%     BCI.regress=struct('file',[],'LocIdx',[],'W',[]);
%     BCI.featureoptions=struct('Sensor',cell(1),'Source',cell(1));
%         BCI.featureoptions.Sensor{1}=' ';
%         BCI.featureoptions.Source{1}=' ';


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% SET INDICATED HANDLE FIELDS BACK TO DEFAULT
if isempty(HandleField)
    
    handles.SYSTEM=SYSTEM;
    handles.ESI=ESI;
%     handles.TRAINING=TRAINING;
%     handles.BCI=BCI;
    
else
    
    for i=1:size(HandleField,2)
        
        if ismember('SYSTEM',HandleField)
            
            handles.SYSTEM=SYSTEM;
            
        elseif ismember('ESI',HandleField)
            
            handles.ESI=ESI;
            
        elseif ismember('TRAINING',HandleField)
            
            handles.TRAINING=TRAINING;
            
        elseif ismember('TRAINING SOURCE',HandleField)
            handles.TRAINING.Source=TRAINING.Source;
            
        elseif ismember('TRAINING SENSOR',HandleField)
            handles.TRAINING.Sensor=TRAINING.Sensor;
            
        elseif ismember('BCI',HandleField)
            
            handles.BCI=BCI;
            
        end
    end
    
end
    
    
    
    
    
    
    
    
