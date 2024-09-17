function [hObject,handles]=bci_fESI_DispEEG(hObject,handles)


set(handles.Axis3Label,'String','Raw EEG');
axes(handles.axes3); cla
set(handles.Axis2Label,'String','Power Topo');
axes(handles.axes2); cla

filename='buffer://localhost:1972';
hdr = ft_read_header(filename, 'cache', true);

% Stop and go on alternating clicks
if isempty(get(hObject,'UserData'))
    set(hObject,'UserData',0)
end
Value=get(hObject,'UserData');
if isequal(Value,1)
    Value=0;
elseif isequal(Value,0)
    Value=1;
end
set(hObject,'UserData',Value);

if isfield(handles,'Electrodes') && isfield(handles.Electrodes,'eLoc')...
        && ~isempty(handles.Electrodes.eLoc) && isfield(handles.Electrodes,'eLoc2') &&...
        ~isempty(handles.Electrodes.eLoc2)

    if size(handles.Electrodes.eLoc,2)<=hdr.nChans && size(handles.Electrodes.eLoc2,2)<=hdr.nChans

        % Extract hdr parameters
        count=0;
        prevSample=0;
        Fs=hdr.Fs;
        blocksize=round(500/1000*Fs); % display 500ms at a time
        chanindx=1:hdr.nChans;

        % Choose which channels to display
        if isequal(get(handles.AllChanEEG,'Value'),1)
            ChanLabel={handles.Electrodes.eLoc.labels}; % all channels
        else
            ChanLabel={handles.Electrodes.eLoc2.labels}; % only selected channels
            ElecChanRemove=handles.Electrodes.ElecChanRemove;
            chanindx(ElecChanRemove)=[];
        end
        % Create offset for separating channels
        Offset=linspace(0,-5000,size(chanindx,2))'; 

        
        while isequal(get(hObject,'UserData'),1)
            % determine number of samples available in buffer
            hdr=ft_read_header(filename, 'cache', true);

            % see whether new samples are available
            newsamples=(hdr.nSamples*hdr.nTrials-prevSample);

            if newsamples>=blocksize
                % determine the samples to process
                begsample=prevSample+1;
                endsample=prevSample+blocksize ;

                % remember up to where the data was read
                prevSample=endsample;
        %         count=count+1;
        %         fprintf('processing segment %d from sample %d to %d\n', count, begsample, endsample);

                % read data segment from buffer
                dat=ft_read_data(filename, 'header', hdr, 'begsample', begsample, 'endsample', endsample, 'chanindx', chanindx);
                
                % Bandpass filter data
                % Introduce filter coefficients
                a=handles.TFParam.butterA;
                b=handles.TFParam.butterB;
                dat=filtfilt(b,a,double(dat'));
                dat=dat';
                
                % Mean-correct data
                dat=dat-repmat(mean(dat,2),[1,size(dat,2)]);
                
                % ONLY MORLET WAVELET RIGHT NOW
                MWParam=handles.TFParam.MWParam;
                MorWav=handles.TFParam.MorWav;
                dt=1/hdr.Fs;
                for i=1:size(dat,1)
                    for j=1:size(MWParam.FreqVect,2)
                        A(j,:,i)=conv2(dat(i,:),MorWav{j},'same')*dt;
                    end
                end
                Ereal=real(A);
                Eimag=imag(A);

                % Sensor analysis
                ErealSensor=sum(Ereal.^2,1); % Square for power, sum across freq
                ErealSensor=mean(ErealSensor,2); % Average over time
                ErealSensor=squeeze(ErealSensor);

                EimagSensor=sum(Eimag.^2,1);
                EimagSensor=mean(EimagSensor,2);
                EimagSensor=squeeze(EimagSensor);
                E=ErealSensor+EimagSensor;
                E=(E-min(E))/(max(E)-min(E));
                
                axes(handles.axes2); cla
                topoplot(E,handles.Electrodes.eLoc2);
                view(-1,90)
                set(gcf,'color',[.94 .94 .94])
                axis off; axis xy
                
                % apply offset
                dat=dat+repmat(Offset,[1,size(dat,2)]);

                % create a matching time-axis
                time=(begsample:endsample)/hdr.Fs;

                % plot the data just like a standard FieldTrip raw data strucute
                axes(handles.axes3); cla
                plot(time, dat); hold on
                % add channel labels
                for i=1:size(ChanLabel,2)
                    text(time(1)-.05,Offset(i),ChanLabel(i));
                end

                % ensure tight axes
                xlim([time(1)-.1 time(end)]);
                ylim([-5250 250]);
                axis square; axis off; view(2)
                pause(.25)
                drawnow

            end
        end

    else
        fprintf(2,'\nSELECTED EEG SYSTEM NOT COMPATIBLE WITH DATA STREAM SIZE\n');
    end

end