function [hObject,handles]=bci_fESI_TestSource(hObject,handles)

eegsystem=get(handles.eegsystem,'Value');
if isfield(handles,'SYSTEM') && isfield(handles.SYSTEM,'Electrodes') &&...
        isfield(handles.SYSTEM.Electrodes,'current') &&...
        isfield(handles.SYSTEM.Electrodes.current,'eLoc')
    eLoc=handles.SYSTEM.Electrodes.current.eLoc;
    MaxChan=size(eLoc,2);
    TestPoints=str2num(get(handles.SenSpikes,'String'));
    TestData=zeros(MaxChan,1);
    TestData(TestPoints)=1;
else
    fprintf(2,'MUST SELECT EEG SYSTEM TO TEST SOURCE\n');
end

switch eegsystem
    case 1 % None
    case {2,3,4,5,6}
        
        domain=get(handles.domain,'Value');
        switch domain
            case 1 % None
            case 2 % Sensor
            case 3 % ESI
                
                % Check if necessary variables have been created
                if exist('eLoc','var') && isfield(handles,'ESI') && ~isequal(sum(TestData),0)
                    
                    cortex=handles.ESI.cortex;
                    clusters=handles.ESI.clusters;
                    numcluster=size(clusters,2);
                    parcellation=get(handles.parcellation,'value');
                    
                    noise=handles.ESI.noise;
                    switch noise
                        case {1,2} % None or no noise estimation
                            
                            INV=handles.ESI.inv.nomodel;
                            
                            J=zeros(1,size(cortex.Vertices,1));
                            switch parcellation
                                case {1,2} % None selected or None
                                    
                                    J=INV*TestData;
                                    
                                case {3,4} % MSP or K-means
                                    
                                    % Rk*Gk'*inv(sum(Gk*Rk*Gk')+a*I)*b for each cluster
                                    for i=1:numcluster
                                        J(clusters{i})=INV{i}*TestData;
                                    end
                                    
                            end
                            J=abs(J);
                        
                        case {3,4} % Diagonal or full 
                            
                            INVreal=handles.ESI.inv.real;
                            INVimag=handles.ESI.inv.imag;
                            
                            Jreal=zeros(1,size(cortex.Vertices,1));
                            Jimag=zeros(1,size(cortex.Vertices,1));
                            
                            switch parcellation
                                case {1,2} % None selected or None
                                    
                                    Jreal=INVreal*TestData;
                                    Jimag=INVimag*TestData;
                                    
                                case {3,4} % MSP or K-means
                                    
                                    for i=1:numcluster

                                        Jreal(clusters{i})=INVreal{i}*TestData;
                                        Jimag(clusters{i})=INVimag{i}*TestData;
                                        
                                    end
                                    
                            end
                            J=sqrt(Jreal.^2+Jimag.^2);
                            
                    end
                            
                    axes(handles.axes3); cla
                    set(handles.Axis3Label,'String','Test Source');
                    h=trisurf(cortex.Faces,cortex.Vertices(:,1),...
                        cortex.Vertices(:,2),cortex.Vertices(:,3),J);
                    set(h,'FaceColor','interp','EdgeColor','None','FaceLighting','gouraud'); 
                    axis auto; axis equal; axis off; view(-90,90)
                    colormap(jet); caxis auto; rotate3d on
                    light; h2=light; lightangle(h2,90,-90); h3=light;lightangle(h3,-90,30);

                    axes(handles.axes2); cla; view(0,90)
                    topoplot(TestData,eLoc,'plotrad',.5,'electrodes','numbers');
                    set(gcf,'color',[.94 .94 .94])
                    set(handles.Axis2Label,'String','Test Source');
                end
        end
end

