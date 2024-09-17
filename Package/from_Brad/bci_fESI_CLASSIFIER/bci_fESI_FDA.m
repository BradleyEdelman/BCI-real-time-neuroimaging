function [Classes,ClassMean,SW,SB,W,Y,DB]=bci_fESI_FDA(ClassData)

NumTask=size(ClassData,2);
[NumTrial,NumChan,NumWin]=size(ClassData{1});

Y=cell(NumTask,NumWin);
DB=zeros(NumTask,NumTask,NumWin);
W=zeros(NumChan,NumWin);
for i=1:NumWin

    Classes=cell(1,NumTask);
    ClassMean=zeros(NumTask,NumChan);
    ClassCov=zeros(NumChan,NumChan,NumTask);
    for j=1:NumTask
        Classes{j}=ClassData{j}(:,:,i); %Classes{j}(:,Bad)=0;
        ClassSize(j)=size(Classes{j},1);

        % Find mean and covariance of each class feature
        ClassMean(j,:)=mean(Classes{j},1);
        ClassMeanCorrect=Classes{j}-repmat(ClassMean(j,:),[ClassSize(j),1]);
        ClassCov(:,:,j)=(1/(ClassSize(j)-1))*(ClassMeanCorrect'*ClassMeanCorrect);
    end

    % Compute global mean
    TotMean=mean(ClassMean,1)/NumTask;

    % Compute w/in class scatter
    SW=sum(ClassCov,3);

    % Compute between class scatter
    SB=zeros(NumChan,NumChan);
    for j=1:NumTask
        SB=SB+ClassSize(j)*(ClassMean(j,:)-TotMean)'*(ClassMean(j,:)-TotMean);
    end

    [V,U]=eig(SB/SW);

    % Number of dimensions to reduce data to
    NumDim=1;
    W(:,i)=abs(V(:,1:NumDim));

    for j=1:NumTask
        Y{j,i}=W(:,i)'*Classes{j}';
    end

    for j=1:NumTask-1
        DB(j,j+1,i)=abs(W(:,i)'*.5*(ClassMean(j,:)+ClassMean(j+1,:))');
    end
end
            
