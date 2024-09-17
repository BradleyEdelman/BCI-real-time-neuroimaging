function [hObject,handles]=bci_fESI_CorticalClusters(hObject,handles,MSPData)

savefiledir=handles.SYSTEM.savefiledir;
cortex=handles.ESI.cortex;
cortexdip=size(cortex.Vertices,1);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Multivariate Source Prelocalization (Mattout 2015)

% Column normalize lead field matrix
leadfield=handles.ESI.leadfield.original;
% LeadField(handles.SYSTEM.Electrodes.chanidxexclude,:)=[];
G=leadfield;
% Remove bad channels from lead field
[chan,CurrentDip]=size(G); 
Gn=G./repmat(sqrt(sum(G.^2,1)),[size(G,1),1]);
[tmp,lambda,U]=svd(Gn',0);
lambda=diag(lambda);

if iscell(MSPData)
    M=horzcat(MSPData{:});
else
    M=MSPData;
end
% M=M(1:16,:);
M(handles.SYSTEM.Electrodes.chanidxexclude,:)=[];
% Check to make sure adjusted lead field and data have same # channels
if ~isequal(size(M,1),size(G,1))
    error('nflwnsfvlsnmgv');
end
% Column normalize data matrix
Mn=M./repmat(sqrt(sum(M.^2,1)),[size(M,1),1]);
Mn(isnan(Mn))=0;

% Project the normalized data on eigenvectors
gamma=U'*Mn;
R2=diag(gamma*gamma');
% Reorder the singular values as a function of R2
[tmp,indices]=sort(R2,'descend');
lambda=lambda(indices);

% Select the columns of B as a function of the ordered singular values up
% to the threshold value
i_T=indices(1:find(cumsum(lambda)./sum(lambda)>=.95,1));
Ut=U(:,sort(i_T));

% Create the projector
Ms=Ut*Ut'*Mn;
Ps=Ms*pinv(Ms'*Ms)*Ms';

% Calculate the MSP (probability-like) scores
Ps2=Ps*Gn;
scores=zeros(1,CurrentDip);
for i=1:size(Gn,2)
     scores(i)=Gn(:,i)'*Ps2(:,i);
end

vertidxinclude=handles.ESI.vertidxinclude;
scoresplot=zeros(1,cortexdip);
axes(handles.axes1); set(handles.Axis1Label,'string','APB Scores')

h=trisurf(cortex.Faces,cortex.Vertices(:,1),cortex.Vertices(:,2),cortex.Vertices(:,3),scores);
set(h,'FaceColor','flat','EdgeColor','None','FaceLighting','gouraud');
axis equal; axis off; view(-90,90); drawnow

% Find faces associated only w/ included vertices (selected brain regions)
% % Clusters will only be generated from these faces/vertices!!!
reducedfaces=[];j=1;
for i=1:size(cortex.Faces,1)
    if isequal(ismember(cortex.Faces(i,:),vertidxinclude),[1 1 1])
        reducedfaces(j)=i;
        j=j+1;
    end
end
reducedfaces=unique(reducedfaces)';
reducedfaces=cortex.Faces(reducedfaces,:);

% Find each included vertex's neighboring vertices (can write own code also)
neighbors=be_get_neighbor_matrix(cortexdip,reducedfaces);

% Create clusters using growing region 
OPTIONS.clustering.neighborhood_order=5;
OPTIONS.clustering.MSP_scores_threshold=0;
[OPTIONS,vertclusterassignment,Clusters]=be_create_clusters(neighbors,scoresplot,OPTIONS);

% For vizualization...
nonzero=find(vertclusterassignment~=0);
plotclusters=-1*ones(1,cortexdip);
plotclusters(nonzero)=vertclusterassignment(nonzero);

axes(handles.axes2); set(handles.Axis2Label,'string','Cortical Clusters')
h=trisurf(cortex.Faces,cortex.Vertices(:,1),cortex.Vertices(:,2),cortex.Vertices(:,3),plotclusters);
set(h,'FaceColor','flat','EdgeColor','None','FaceLighting','gouraud');
axis equal; axis off; view(-90,90);

% cmap=[1 0 1;1 0 .5;.45 .45 1;.6 .6 0;.55 1 .75;...
%   .6 .3 0;1 .8 .8;1 0 0;1 .5 0;1 1 0;0 1 0;0 1 1;0 0 1;.5 0 1];
% numrep=ceil(size(unique(vertclusterassignment),1)/size(cmap,1));
% cmap=repmat(cmap,[numrep 1]);
% if ~isequal(size(VertIdxInclude,1),CortexDip)
%     cmap=[.85 .85 .85;cmap];
% end
% colormap(cmap); drawnow
drawnow

% Must create a null cluster to create full inverse operator
nullcluster=find(vertclusterassignment==0);
Clusters{end+1}=nullcluster';
handles.ESI.clusters=Clusters;
handles.ESI.vertclusterassignment=vertclusterassignment;
handles.ESI.leadfield.cluster=leadfield;

% Add parcellated brain to saved files list
ClusterVar='Clusters';
savefiles=cell(get(handles.savefiles,'string'));
if ~ismember(ClusterVar,savefiles)
    savefiles=sort(vertcat(savefiles,{ClusterVar}));
    set(handles.savefiles,'string',savefiles);
end

% Save Cluster
SaveClusterFile=strcat(savefiledir,'\Clusters.mat');
SaveCluster.chaninclude=vertidxinclude;
SaveCluster.neighbors=neighbors;
SaveCluster.neighborhoodorder=OPTIONS.clustering.neighborhood_order;
SaveCluster.MSPscorethreshold=OPTIONS.clustering.MSP_scores_threshold;
SaveCluster.clusters=Clusters;
SaveCluster.plotclusters=vertclusterassignment;
SaveCluster.cortex=cortex;
SaveCluster.label='';
save(SaveClusterFile,'SaveCluster','-v7.3');

handles.RegressSource.clusterfile{1}=SaveClusterFile;
handles.RegressSource.clusterlabel{1}='clusters';

















