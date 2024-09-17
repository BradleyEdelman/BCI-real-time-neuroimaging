function [Classes,PC,ClassMean,W0,W]=bci_fESI_LDA(ClassData)

NumTask=size(ClassData,2);
[NumTrial,NumChan,NumWin]=size(ClassData{1});


% Multi-class LDA Analysis
PC=zeros(NumChan,NumChan,NumWin);
W0=zeros(NumTask,NumTask,NumWin);
W=cell(NumTask,NumTask,NumWin);

for i=1:NumWin
            
    Classes=cell(1,NumTask);
    ClassSize=zeros(1,NumTask);
    ClassMean=zeros(NumTask,NumChan);
    ClassCov=zeros(NumChan,NumChan,NumTask);
    PriorProb=zeros(NumTask,1);
    for j=1:NumTask
        Classes{j}=squeeze(ClassData{j}(:,:,i));
        ClassSize(j)=size(Classes{j},1);
        ClassMean(j,:,i)=mean(Classes{j},1);
        ClassMeanCorrect=Classes{j}-repmat(ClassMean(j,:,i),[ClassSize(j),1]);
        ClassCov(:,:,j)=(1/(ClassSize(j)-1))*(ClassMeanCorrect'*ClassMeanCorrect);
    end

    TotSize=size(vertcat(Classes{:}),1);
    for j=1:NumTask
        PriorProb(j)=ClassSize(j)/TotSize;
    end

    PCtmp=zeros(NumChan,NumChan);
    for j=1:NumTask
        PCtmp=PCtmp+ClassSize(j)*ClassCov(:,:,j);
    end
    PC(:,:,i)=PCtmp/(sum(ClassSize)-NumTask);


    for j=1:NumTask-1
        W0(j,j+1,i)=log(PriorProb(j)/PriorProb(j+1))-...
            .5*(ClassMean(j+1,:,i)-ClassMean(j,:,i))*inv(PC(:,:,i))*...
            (ClassMean(j+1,:,i)-ClassMean(j,:,i))';
        W{j,j+1,i}=(ClassMean(j+1,:,i)-ClassMean(j,:,i))*inv(PC(:,:,i));
    end

end
