function [hObject,handles]=bci_fESI_CheckBCI(hObject,handles)

set(hObject,'userdata',1);

tasktype=get(handles.tasktype,'value');
set(handles.tasktype,'backgroundcolor','green');
if isequal(tasktype,1)
    fprintf(2,'MUST SELECT A TASK TYPE\n');
    set(handles.tasktype,'backgroundcolor','red');
    set(hObject,'backgroundcolor','red','userdata',0);
end

analysiswindow=get(handles.analysiswindow,'string');
set(handles.analysiswindow,'backgroundcolor','green');
if isempty(analysiswindow)
    fprintf(2,'ANALYSIS WINDOW LENGTH NOT SET\n');
    set(handles.analysiswindow,'backgroundcolor','red');
    set(hObject,'backgroundcolor','red','userdata',0);
end

updatewindow=get(handles.updatewindow,'string');
set(handles.updatewindow,'backgroundcolor','green');
if isempty(updatewindow)
    fprintf(2,'UPDATE WINDOW LENGTH NOT SET\n');
    set(handles.updatewindow,'backgroundcolor','red');
    set(hObject,'backgroundcolor','red','userdata',0);
end

psd=handles.SYSTEM.psd;
handles.BCI.psd=psd;
switch psd
    case 1 % None
    case 2 % Morlet wavelet
    case {3,4} % Welch's PSD or DFT
        set(handles.Noise,'value',2)
        fprintf(2,'\nNOISE ESTIMATION IN THE FREQUENCY DOMAIN REQUIRES A TIME-FREQUENCY REPRESENATION\n');
end

FixNorm=get(handles.FixNormVal,'value');
if isequal(FixNorm,0)
    if isequal(tasktype,2)
        cyclelength=get(handles.buffercyclelength,'value');
        if isempty(cyclelength)
            fprintf(2,'MUST ENTER CYCLE LENGTH FOR ADAPTIVE CONTINUOUS BCI\n');
            set(handles.cyclelength,'backgroundcolor','red');
            set(hObject,'backgroundcolor','red','userdata',0);
        end
    end
    
    bufferlength=get(handles.bufferlength,'value');
    if isempty(bufferlength)
        fprintf(2,'MUST ENTER BUFFER LENGTH FOR ADAPTIVE BCI\n');
        set(handles.bufferlength,'backgroundcolor','red');
        set(hObject,'backgroundcolor','red','userdata',0);
    end
end


domain=get(handles.domain,'value');
switch domain
    case 1 % None
        
        fprintf(2,'ANALYSIS DOMAIN NOT SELECTED\n');
        set(handles.domain,'backgroundcolor','red')
        set(hObject,'backgroundcolor','red')
        
	case 2 % Sensor
            SetSystem=get(handles.SetSystem,'userdata');
            if isequal(SetSystem,0)
                fprintf(2,'SYSTEM PARAMETERS HAVE NOT BEEN CHECKED\n');
            end
        
            
	case 3 % ESI
        
        % CHECK FOR ESI MODEL PARAMETERS
        if ~isfield(handles,'ESI')
            set(hObject,'backgroundcolor','red','userdata',0);
            fprintf(2,'ESI PARAMETERS HAVE NOT BEEN SET\n');
        elseif ~isfield(handles.ESI,'clusterleadfield')
            set(hObject,'backgroundcolor','red','userdata',0);
            fprintf(2,'CLUSTERED LEAD FIELD DOES NOT EXIST, MUST SET ESI PARAMETERS\n');
        elseif ~isfield(handles.ESI,'clustersourcecov')
            set(hObject,'backgroundcolor','red','userdata',0);
            fprintf(2,'CLUSTERED SOURCE COVARIANCE MATRICES DO NOT EXIST, MUST SET ESI PARAMETERS\n');
        elseif ~isfield(handles.ESI,'residualsolution')
            set(hObject,'backgroundcolor','red','userdata',0);
            fprintf(2,'RESIDUAL SOLUTION MATRIX DOES NOT EXIST, MUST SET ESI PARAMETERS\n');
        end
        
        % CHECK FOR ESI NOISE-DEPENDENT PARAMTERS
        noise=handles.ESI.noise;
        switch noise
            case {1,2}
              if ~isfield(handles.ESI,'whitener')
                  set(hObject,'backgroundcolor','red','userdata',0);
                  fprintf(2,'WHITENER DOES NOT EXIST, MUST SET ESI PARAMETERS\n');
              elseif ~isfield(handles.ESI,'lambdasq')
                  set(hObject,'backgroundcolor','red','userdata',0);
                  fprintf(2,'LAMBDA DOES NOT EXIST, MUST SET ESI PARAMETERS\n');
              end
                
            case {3,4}
                % NEEEEDS UPDATING
                if ~isfield(handles.ESI,'inv') || isempty(handles.ESI.inv)
                    set(hObject,'backgroundcolor','red','userdata',0);
                    fprintf(2,'INVERSE TRANSFORMS DO NOT EXIST, MUST SET ESI PARAMETERS\n');
                elseif ~isfield(handles.ESI.inv,'real') || isempty(handles.ESI.inv.real)
                    set(hObject,'backgroundcolor','red','userdata',0);
                    fprintf(2,'REAL INVERSE TRANSFORM DOES NOT EXIST, MUST SET ESI PARAMETERS\n');
                elseif ~isfield(handles.ESI.inv,'imag') || isempty(handles.ESI.inv.imag)
                    set(hObject,'backgroundcolor','red','userdata',0);
                    fprintf(2,'IMAGINARY INVERSE TRANSFORM DOES NOT EXIST, MUST SET ESI PARAMETERS\n');
                end
        end
end

if isequal(get(hObject,'userdata'),1)            
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % IDENTIFY NUMBER OF CONTROL DIMENSIONS AND THEIR DIRECTION
    % Cannot select BCI control locations unless other dimension info is complete
    userdata=ones(3,1);

    Dimensions={'1' '2' '3'};
    for i=1:size(Dimensions,2)
        dimar=strcat('bcidim',Dimensions{i});
        taskvar=strcat('bcitask',Dimensions{i});
        freqvar=strcat('bcifreq',Dimensions{i});
        locvar=strcat('bciloc',Dimensions{i});
        gainvar=strcat('gain',Dimensions{i});
        offsetvar=strcat('offset',Dimensions{i});
        scalevar=strcat('scale',Dimensions{i});

        dimval=get(handles.(dimar),'value');
        set(handles.(dimar),'backgroundcolor','green')
        if isequal(dimval,1)
            fprintf(2,'\nDIMENSION %s: NOT SPECIFIED, IGNORING OTHER PARAMETERS\n',Dimensions{i});
            set(handles.(dimar),'backgroundcolor','white');
            Fields={taskvar freqvar locvar gainvar offsetvar scalevar};
            [hObject,handles]=bci_fESI_Reset(hObject,handles,Fields,[]);
            userdata(i)=0;
        else
            taskval=get(handles.(taskvar),'value');
            if isequal(taskval,1)
                fprintf(2,'DIMENSION %s: TASKS NOT SPECIFIED\n',Dimensions{i});
                set(handles.(dimar),'backgroundcolor','red');
                set(handles.(taskvar),'backgroundcolor','red');
                userdata(i)=0;
            else
                set(handles.(taskvar),'backgroundcolor','green');
            end

            freqval=get(handles.(freqvar),'value');
            if isequal(freqval,1)
                fprintf(2,'DIMENSION %s: FREQUENCY NOT SPECIFIED\n',Dimensions{i});
                set(handles.(dimar),'backgroundcolor','red');
                set(handles.(freqvar),'backgroundcolor','red');
                userdata(i)=0;
            else
                set(handles.(freqvar),'backgroundcolor','green');
            end
            
            locval=get(handles.(locvar),'userdata');
            set(handles.(locvar),'backgroundcolor','green');
            if isempty(locval) || isequal(locval,0)
                fprintf(2,'DIMENSION %s: CONTROL LOCATIONS NOT SPECIFIED\n',Dimensions{i});
                set(handles.(dimar),'backgroundcolor','red');
                set(handles.(locvar),'backgroundcolor','red');
                userdata(i)=0;
            else
                switch domain
                    case 1 % None
                    case 2 % Sensor
                        if size(locval,1)>size(handles.SYSTEM.Electrodes.chanidxinclude,1)
                            fprintf(2,'DIMENSION %s: NUMBER OF CHANNELS SELECTED EXCEEDS TOTAL NUMBER OF INCLUDED CHANNELS\n',Dimensions{i});
                            userdata(i)=0;
                        else
                            BCILocIdx=locval(:,1);
                            for j=1:size(BCILocIdx,1)-1
                                if BCILocIdx(j)>size(handles.SYSTEM.Electrodes.chanidxinclude,1)
                                    fprintf(2,'DIMENSION %s: SELECTED CHANNEL INDEX EXCEEDS TOTAL NUMBER OF INCLUDED CHANNELS\n',Dimensions{i});
                                    userdata(i)=0;
                                end
                            end
                        end
                    case 3 % ESI
                        if size(locval,1)>size(handles.ESI.clusters,2)
                            fprintf(2,'DIMENSION %s: NUMBER OF CLUSTERS SELECTED EXCEEDS TOTAL NUMBER OF CLUSTERS\n',Dimensions{i});
                            userdata(i)=0;
                        else
                            BCILocIdx=locval(:,1);
                            for j=1:size(BCILocIdx,1)-1
                                if BCILocIdx(j)>size(handles.ESI.clusters,2)
                                    fprintf(2,'DIMENSION %s: SELECTED CLUSTER INDEX EXCEEDS TOTAL NUMBER OF INCLUDED CHANNELS\n',Dimensions{i});
                                    userdata(i)=0;
                                end
                            end
                        end
                end
            end

            gainval=str2double(get(handles.(gainvar),'string'));
            if ~isnumeric(gainval)
                fprintf(2,'DIMENSION %s: INVALID GAIN VALUE\n',Dimensions{i});
                set(handles.(dimar),'backgroundcolor','red');
                set(handles.(gainvar),'backgroundcolor','red');
                userdata(i)=0;
            else
                set(handles.(gainvar),'backgroundcolor','green');
            end

            offsetval=str2double(get(handles.(offsetvar),'string'));
            if ~isnumeric(offsetval)
                fprintf(2,'DIMENSION %s: INVALID OFFSET VALUE\n',Dimensions{i});
                set(handles.(dimar),'backgroundcolor','red');
                set(handles.(offsetvar),'backgroundcolor','red');
                userdata(i)=0;
            else
                set(handles.(offsetvar),'backgroundcolor','green');
            end

            scaleval=str2double(get(handles.(scalevar),'string'));
            if ~isnumeric(scaleval)
                fprintf(2,'DIMENSION %s: INVALID SCALE VALUE\n',Dimensions{i});
                set(handles.(dimar),'backgroundcolor','red');
                set(handles.(scalevar),'backgroundcolor','red');
                userdata(i)=0;
            else
                set(handles.(scalevar),'backgroundcolor','green');
            end

        end
    end
end


if exist('userdata','var')
    set(hObject,'backgroundcolor','green')
    if isequal(sum(userdata),0)
        set(hObject,'backgroundcolor','red')
    end
    set(hObject,'userdata',userdata);
else
    set(hObject,'backgroundcolor','red')
end






