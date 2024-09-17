function [eegspecdB,freqs,specstd]=bci_fESI_Welch(data,param,method)
	
if param.winsize>size(data,2)
	winlength=size(data,2);
else
	winlength = param.winsize;
end

if isempty(param.nfft)
	fftlength = 2^(nextpow2(winlength))*param.freqfac;
else
	fftlength = param.nfft;
end
nbchan=size(data,1);
srate=param.srate;

% fprintf(' (window length %d; fft length: %d; overlap %d):\n', winlength, fftlength, param.overlap);	

eegspecdB=zeros(nbchan,fftlength/2+1);
specstd=zeros(nbchan,fftlength/2+1);
for i=1:nbchan % scan channels or components
	tmpdata=data(i,:); % channel activity
	[tmpspec,freqs]=pwelch(tmpdata,winlength,param.overlap,fftlength,srate,method);
	eegspecdB(i,:)=tmpspec';
	specstd(i,:)=tmpspec'.^2;
% 	fprintf('.')
end
    
% n=size(epoch_subset,1);
% 	eegspecdB = eegspec/n; % normalize by the number of sections
%     if n>1  % normalize standard deviation by the number of sections
%         specstd   = sqrt( (specstd +  eegspec.^2/n)/(n-1) ); 
%     else specstd   = [];
%     end;
% 	return;
