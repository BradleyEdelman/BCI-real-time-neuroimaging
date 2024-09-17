function NN=bci_fESI_Brain_Interp(Brain_HR,Brain_LR)

vertHR=Brain_HR.Vertices; % Must be N x 3
vertLR=Brain_LR.Vertices; % Must be M x 3


vertLR=repmat(vertLR,[1,size(vertHR,1)]);

vertHR=vertHR';
vertHR=vertHR(:)';
vertHR=repmat(vertHR,[size(vertLR,1),1]);

Dxyz=vertHR-vertLR;
Dxyz=Dxyz.^2;

Dsum=zeros(size(vertLR,1),size(vertHR,1));
for i=1:size(Dxyz,2)/3
    Dsum(:,i)=sum(Dxyz(:,1+3*(i-1):3+3*(i-1)),2);
end
D=Dsum.^(.5);

NN=zeros(size(vertLR,1),size(vertHR,2)/3);
for i=1:size(vertLR,1)
    [tmp,idx]=sort(D(i,:),'ascend');
    NN(i,idx(1:3))=1;
end

% Can then multiple NN by the high resolution column CCD to obtain the
% downsampled CCD distribution
    




