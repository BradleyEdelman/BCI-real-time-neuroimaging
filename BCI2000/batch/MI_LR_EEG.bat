cd ..\prog


start Operator               --OnConnect "-LOAD PARAMETERFILE ..\parms\_BRAD_CP\MI_LR_EEG.prm"
start BioSemi2		
start ARSignalProcessing
start StimulusPresentation
