function [handles,TrialInfo]=bci_fESI_BCIESIExtractParamaters(handles,TrainFiles)


NumFiles=size(TrainFiles,1);

Length=zeros(1,NumFiles);
ChanIdxInclude=cell(1,NumFiles);
VertIdxInclude=cell(1,NumFiles);


% LOAD THE SELECTED DAT FILE
for i=1:NumFiles
    
    load(TrainFiles{i});
    
    Length(i)=size(Dat,2);
    ChanIdxInclude{i}=Dat(1).chanidxinclude;
    VertIdxInclude{i}=Dat(1).vertidxinclude;
    NumFreq(i)=Dat(1).numfreq;
    
end
TrialInfo.length=sum(Length,2);

combinations=combnk(1:NumFiles,2);
for i=1:size(combinations,1)
    
    if ~isequal(ChanIdxInclude{combinations(i,1)},ChanIdxInclude{combinations(i,2)})
        error('INCONSISTENT EEG CHANNELS AMONG TRAINING FILES');
    end
    
end
TrialInfo.chanidxinclude=ChanIdxInclude{1};


for i=1:size(combinations,1)
    
    if ~isequal(VertIdxInclude{combinations(i,1)},VertIdxInclude{combinations(i,2)})
        error('INCONSISTENT SOURCE DIPOLES AMONG TRAINING FILES');
    end
    
end
TrialInfo.vertidxinclude=VertIdxInclude{1};


for i=1:size(combinations,1)
    
    if ~isequal(NumFreq(combinations(i,1)),NumFreq(combinations(i,2)))
        error('INCONSISTENT NUMBER OF FREQUENCIES AMONG TRAINING FILES');
    end
    
end
TrialInfo.numfreq=NumFreq(1);
    

