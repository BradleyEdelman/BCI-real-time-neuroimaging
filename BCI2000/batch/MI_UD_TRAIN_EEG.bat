cd ..\prog


start Operator               --OnConnect "-LOAD PARAMETERFILE ..\parms\_BRAD_CP\MI_UD_TRAIN_EEG.prm"
start BioSemi2		
start ARSignalProcessing
start StimulusPresentation
