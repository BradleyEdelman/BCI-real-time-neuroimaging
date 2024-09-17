function [MorWav]=bci_fESI_MorWav(MWParam)


% Frequencies at which to build the wavelet
FreqVect=MWParam.FreqVect;
% Central frequency
fc=1;
% FWHM at central frequency
FWHMc=3;

% Scales for wavelet at each frequency
scales=FreqVect./fc;
NumScale=size(scales,2); 
% Standard deviaton of gaussian kernal in time (at central frequency)
sigma_tc=FWHMc/sqrt(8*log(2));
% Standard deviation in time at each frequency
sigma_t=sigma_tc*fc./FreqVect;
% Standard deviation in frequency at each frequency
sigma_f=1./(2*pi*sigma_t);


% Precision: parameter that helps define how large the wavelet is in time
precision=3;
% Time step
dt=1/MWParam.fs;

% Build complex morlet wavelet at desired frequencies
for i=1:NumScale
    
    % Timerange of wavelet in each freq (based on precision and stdev in time)
	time=-precision*sigma_t(i):dt:precision*sigma_t(i);
	scale_time=scales(i)*time;
    
	W=(sigma_tc*sqrt(pi))^(-0.5)*exp(-(scale_time.^2)/(2*sigma_tc^2)).*...
        exp(1i*2*pi*fc*scale_time);
	MorWav{i}=sqrt(scales(i))*W;
    
end

