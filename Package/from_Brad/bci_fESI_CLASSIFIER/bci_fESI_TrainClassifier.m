function handles=bci_fESI_TrainClassifier(TaskInfo,TrialStruct,Data,handles)

handles.Regress
SaveFileDir=handles.save.savefiledir;

% Want data in Chan X Time form
if size(Data,1)>size(Data,2)
    Data=Data';
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Separate data into trials
Base=TrialStruct.isi*1000;
Trial=TrialStruct.stimdur*1000;
StimInd=cell2mat(TaskInfo(2:end,4));
NumTrial=size(TaskInfo,1)-1;
for i=1:NumTrial
    BaseData(:,:,i)=Data(:,StimInd(i)-Base:StimInd(i)-1);
    TrialData(:,:,i)=Data(:,StimInd(i):StimInd(i)+Trial-1);
end

for i=1:NumTrial
    AveBase=mean(BaseData(:,:,i),2);
    VarBase=std(BaseData(:,:,i)'); VarBase=VarBase';
%     Data2(:,StimInd(i)-Base:StimInd(i)-1)=BaseData(:,:,i)./repmat(AveBase,[1 Base]);
%     Data2(:,StimInd(i):StimInd(i)+Trial-1)=TrialData(:,:,i)./repmat(AveBase,[1 Trial]);
    
%     Data2(:,StimInd(i)-Base:StimInd(i)-1)=(BaseData(:,:,i)-repmat(AveBase,[1 Base]))./repmat(VarBase,[1 Base]);
%     Data2(:,StimInd(i):StimInd(i)+Trial-1)=TrialData(:,:,i)-repmat(AveBase,[1 Trial])./repmat(AveBase,[1 Trial]);

    Data2(:,StimInd(i):StimInd(i)+Trial-1)=TrialData(:,:,i)-repmat(AveBase,[1 Trial]);

    TrialData(:,:,i)=Data2(:,StimInd(i):StimInd(i)+Trial-1);
end

% f=figure;
% for i=1:NumTrial
%     subplot(2,1,1); imagesc(TrialData(:,:,i)); colorbar; title(num2str(i));
%     if isequal(get(handles.Domain,'Value'),2)
%         subplot(2,1,2); topoplot(sum(TrialData(:,:,i),2),handles.Electrodes.eLoc,'numcontour',0);
%     elseif ismember(get(handles.Domain,'value'),[3,4])
%         Cortex=handles.Inverse.Cortex; Disp=zeros(1,size(Cortex.Vertices,1));
%         
% %         size(handles.TrainParam.brainverticesinclude)
%         
%         
%         Disp(handles.TrainParam.verticesinclude)=sum(TrialData(:,:,i),2)';
%         subplot(2,1,2);
%         h=trisurf(Cortex.Faces,Cortex.Vertices(:,1),...
%             Cortex.Vertices(:,2),Cortex.Vertices(:,3),Disp);
%         set(h,'FaceColor','interp','EdgeColor','None','FaceLighting','gouraud');
%         axis equal; axis off; view(-90,90)
%         light; h2=light; lightangle(h2,90,-90); h3=light;lightangle(h3,-90,30);
%         caxis auto; rotate3d on
%     end
%     title(TaskInfo{i+1,3});
%     set(gcf,'Color',[.94 .94 .94]);
%     pause; clf
% end
% close(f)


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Break "feedback" data up into windows IDENTICAL to online processing
fs=str2double(get(handles.fs,'String'));
AnalysisWindow=get(handles.AnalysisWindow,'String');
BlockSize=round(str2double(AnalysisWindow)/1000*fs);
UpdateWindow=get(handles.UpdateWindow,'String');
Overlap=round(str2double(UpdateWindow)/1000*fs);

for j=1:NumTrial
    StartInd=1; EndInd=BlockSize; win=1;
	while EndInd<size(TrialData,2) && StartInd<size(TrialData,2)
        WinData(:,win,j)=sum(TrialData(:,StartInd:EndInd,j),2);
        StartInd=EndInd+1;
        EndInd=StartInd+BlockSize-1;
        win=win+1;
    end
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% ORGANIZE DATA FOR BUILDING DECODER

% Separate data into respective classes
TargetTypes=unique(cell2mat(TaskInfo(2:end,2)));
NumTask=size(TargetTypes,1);
ClassSize=zeros(NumTask,1);
clear ClassData
for i=1:NumTask
    ClassData{i}=(WinData(:,:,find(cell2mat(TaskInfo([2:end],2))==TargetTypes(i))));
    ClassSize(i)=size(ClassData{i},3);
end
% p=ClassSize/NumTrial;

% Want training data of the form NumMeasurements X NumFeatures
TrainingScheme=handles.TrainParam.trainingscheme;
switch TrainingScheme
    case 1 % None
    case 2 % Average Time Window
        
        % Finding window (time) invariant patterns
        % % -> concatenate windowed data
        for i=1:NumTask
            ClassData{i}=ClassData{i}(:,:)';
        end
        [NumTrial,NumChan,NumWin]=size(ClassData{1});

    case 3 % Time Resolved
        [NumChan,NumWin,NumTrial]=size(ClassData{1});
        ClassDatatmp=cell(1,NumTask);
        for i=1:NumTask
            for j=1:NumWin
                ClassDatatmp{i}(:,:,j)=squeeze(ClassData{i}(:,j,:))';
            end
        end
        ClassData=ClassDatatmp;
        clear ClassDatatmp
        [NumTrial,NumChan,NumWin]=size(ClassData{1});
end


% Build decoder according to specified type
DecoderType=handles.TrainParam.decodertype;
Domain=get(handles.Domain,'Value');
DomainLabel={'' 'Sensor' 'Source' 'Source'};
switch DecoderType
	case 1 % None
    case 2 % Fisher LDA
        
        % Multi-class LDA analysis
        [Classes,ClassMean,SW,SB,W,Y,DB]=bci_fESI_FDA(ClassData);
        
        if isequal(TrainingScheme,2)
            % One-vs-all LDA analysis
            if NumTask>2
                for i=1:NumTask
                    X{1}=ClassData{i};
                    TotTasktmp=1:NumTask; TotTasktmp(i)=[];
                    X{2}=vertcat(ClassData{TotTasktmp}); % all
                    [ClassesOVA(i,:),ClassMeanOVA(:,:,i),SWOVA(:,:,i),SBOVA(:,:,i),WOVA(:,i),YOVA(:,i),DBOVA(:,:,i)]=bci_fESI_FDA(X);

                end
            end
        end
        
        SaveDecoder.DecoderType=DecoderType;
        SaveDecoder.TrainingScheme=TrainingScheme;
        SaveDecoder.Type='FDA';
        SaveDecoder.NumWin=NumWin;
        SaveDecoder.NumChan=NumChan;
        SaveDecoder.NumTask=NumTask;
        SaveDecoder.Weights=W;
        SaveDecoder.TrainData=Classes;
        SaveDecoder.ClassMean=ClassMean;
        SaveDecoder.SW=SW;
        SaveDecoder.SB=SB;
        SaveDecoder.Y=Y;
        SaveDecoder.W=W;

        if NumTask>2 && isequal(TrainingScheme,2)
            for i=1:NumTask
                SaveDecoder.OVA(i).TrainData(i,:)=ClassesOVA(i,:);
                SaveDecoder.OVA(i).ClassMean(:,:,i,:)=ClassMeanOVA(:,:,i);
                SaveDecoder.OVA(i).SW=SWOVA(:,:,i);
                SaveDecoder.OVA(i).SB=SBOVA(:,:,i);
                SaveDecoder.OVA(i).Y=YOVA(:,i);
                SaveDecoder.OVA(i).W=WOVA(:,i);
            end
        end

        switch Domain
            case 1 % None
            case 2 % Sensor
                SaveDecoderSensor=SaveDecoder;
                SaveDecoderVar='Decoder Sensor';
                SaveDecoderFile=strcat(SaveFileDir,'\Decoder_Sensor.mat');
                
                save(SaveDecoderFile,'SaveDecoderSensor','-v7.3');
                handles.save.decoder.sensor=SaveDecoderFile;
            case {3,4} % ESI or fESI
                SaveDecoderSource=SaveDecoder;
                SaveDecoderVar='Decoder Source';
                SaveDecoderFile=strcat(SaveFileDir,'\Decoder_Source.mat');

                save(SaveDecoderFile,'SaveDecoderSource','-v7.3');
                handles.save.decoder.source=SaveDecoderFile;
        end
        
        % Add files to display list
        SaveFiles=cellstr(get(handles.SaveFiles,'String'));
        if ~ismember(SaveDecoderVar,SaveFiles)
            SaveFiles=sort(vertcat(SaveFiles,{SaveDecoderVar}));
            set(handles.SaveFiles,'String',SaveFiles);
        end
                
        % One-vs-all 
        if NumTask>2 && isequal(TrainingScheme,2)
            for i=1:NumTask
                WeightVar=[DomainLabel{Domain} ' Weights Task ' num2str(i) '-vs-all'];
                SaveFiles=cellstr(get(handles.SaveFiles,'String'));
                if ~ismember(WeightVar,SaveFiles)
                    SaveFiles=sort(vertcat(SaveFiles,{WeightVar}));
                    set(handles.SaveFiles,'String',SaveFiles);
                end
                
                DsqVar=[DomainLabel{Domain} ' MD Task ' num2str(i) '-vs-all'];
                SaveFiles=cellstr(get(handles.SaveFiles,'String'));
                if ~ismember(DsqVar,SaveFiles)
                    SaveFiles=sort(vertcat(SaveFiles,{DsqVar}));
                    set(handles.SaveFiles,'String',SaveFiles);
                end
            end
        end

    case 3 % LDA
        
        % Multi-class LDA analysis
        [Classes,PC,ClassMean,W0,W]=bci_fESI_LDA(ClassData);
        
        % One-vs-all LDA analysis
        if NumTask>2
            for i=1:NumTask
                X{1}=ClassData{i};
                TotTasktmp=1:NumTask; TotTasktmp(i)=[];
                X{2}=vertcat(ClassData{TotTasktmp}); % all
                [ClassesOVA(i,:),PCOVA(:,:,i,:),ClassMeanOVA(:,:,i),W0OVA(:,:,i,:),WOVA(:,:,i)]=bci_fESI_LDA(X);
            end
        end
        
        % Calculate "classifier weights"
        % % For LDA find Mahalanobis Distance between tasks at each location
        TotTask=1:NumTask;
        Dsq=zeros(NumTask,NumChan,NumWin);
        
        for i=1:NumTask
            X1=Classes{i};
            TotTasktmp=TotTask; TotTasktmp(i)=[];
            X2=vertcat(Classes{TotTasktmp});
            
            for j=1:NumChan
                for k=1:NumWin
                    
                    n1=size(X1,1);
                    n2=size(X2,1);
                    
                    X1tmp=mean(X1(:,j,k),1);
                    X2tmp=mean(X2(:,j,k),1);
                    
                    X1cov=cov(X1(:,j,k));
                    X2cov=cov(X2(:,j,k));

                    PCmahal=(n1*X1cov+n2*X2cov)/(n1+n2-2);
%                     PCmahal=(X1cov+X2cov)/2;                    
                    Dsq(i,j,k)=(X1tmp-X2tmp)'*inv(PCmahal)*(X1tmp-X2tmp);

%                     B(i,j,k)=1/8*Dsq(i,j,k)+.5*log(det(PCmahal)/sqrt(det(X1cov)*det(X2cov)));
                end
            end
        end
        
        
%         for i=1:NumChan
%             Assign(i)=find(Dsq(:,i)==max(Dsq(:,i)));
%         end

        SaveDecoder.DecoderType=DecoderType;
        SaveDecoder.TrainingScheme=TrainingScheme;
        SaveDecoder.Type='LDA';
        SaveDecoder.NumWin=NumWin;
        SaveDecoder.NumChan=NumChan;
        SaveDecoder.NumTask=NumTask;
        SaveDecoder.TrainData=Classes;
        SaveDecoder.ClassMean=ClassMean;
        SaveDecoder.PC=PC;
        SaveDecoder.W=W;
        SaveDecoder.W0=W0;
        SaveDecoder.Dsq=Dsq;
%         SaveDecoder.Assign=Assign;
        
        % One-vs-all 
        if NumTask>2
            for i=1:NumTask
                SaveDecoder.OVA(i).TrainData(i,:)=ClassesOVA(i,:);
                SaveDecoder.OVA(i).ClassMean(:,:,i,:)=ClassMeanOVA(:,:,i);
                SaveDecoder.OVA(i).PC=PCOVA(:,:,i);
                SaveDecoder.OVA(i).W0=W0OVA(:,:,i);
                SaveDecoder.OVA(i).W=WOVA(:,:,i);
            end
        end

        switch Domain
            case 1 % None
            case 2 % Sensor
                SaveDecoderSensor=SaveDecoder;
                SaveDecoderVar='Decoder Sensor';
                SaveDecoderFile=strcat(SaveFileDir,'\Decoder_Sensor.mat');
                
                save(SaveDecoderFile,'SaveDecoderSensor','-v7.3');
                handles.save.decoder.sensor=SaveDecoderFile;
            case {3,4} % ESI or fESI
                SaveDecoderSource=SaveDecoder;
                SaveDecoderVar='Decoder Source';
                SaveDecoderFile=strcat(SaveFileDir,'\Decoder_Source.mat');
                
                save(SaveDecoderFile,'SaveDecoderSource','-v7.3');
                handles.save.decoder.source=SaveDecoderFile;
        end
        
        SaveFiles=cellstr(get(handles.SaveFiles,'String'));
        if ~ismember(SaveDecoderVar,SaveFiles)
            SaveFiles=sort(vertcat(SaveFiles,{SaveDecoderVar}));
            set(handles.SaveFiles,'String',SaveFiles);
        end
                
        % One-vs-all 
        if NumTask>2
            for i=1:NumTask
                WeightVar=[DomainLabel{Domain} ' Weights Task ' num2str(i) '-vs-all'];
                SaveFiles=cellstr(get(handles.SaveFiles,'String'));
                if ~ismember(WeightVar,SaveFiles)
                    SaveFiles=sort(vertcat(SaveFiles,{WeightVar}));
                    set(handles.SaveFiles,'String',SaveFiles);
                end
                
                DsqVar=[DomainLabel{Domain} ' MD Task ' num2str(i) '-vs-all'];
                SaveFiles=cellstr(get(handles.SaveFiles,'String'));
                if ~ismember(DsqVar,SaveFiles)
                    SaveFiles=sort(vertcat(SaveFiles,{DsqVar}));
                    set(handles.SaveFiles,'String',SaveFiles);
                end
            end
        end
end




    






















        
        
        
        
        
        
        
        
        
        
        
        
        
        
        
        
        

