
% do_filter
% flattens current image
% 
% Written by Daniel Buscombe, various times in 2012 and 2013
% while at
% School of Marine Science and Engineering, University of Plymouth, UK
% then
% Grand Canyon Monitoring and Research Center, U.G. Geological Survey, Flagstaff, AZ 
% please contact:
% dbuscombe@usgs.gov
% for lastest code version please visit:
% https://github.com/dbuscombe-usgs
% see also (project blog):
% http://dbuscombe-usgs.github.com/
%====================================
%   This function is part of 'dgs-gui' software
%   This software is in the public domain because it contains materials that originally came 
%   from the United States Geological Survey, an agency of the United States Department of Interior. 
%   For more information, see the official USGS copyright policy at 
%   http://www.usgs.gov/visual-id/credit_usgs.html#copyright
%====================================


disp('Filtering image ...')

[rows,cols] = size(sample.data);

% filter parameters
boost=Setts.filteroptions.boost; % sample.filt1;
CutOff=Setts.filteroptions.CutOff; %sample(ii).filt2;
order=Setts.filteroptions.order; %sample(ii).filt3;

try
    sample.data= normalise(sample.data);   % Rescale values 0-1 (and cast  to `double' if needed).
    FFTlogIm = fft2(log(sample.data+.01)); % Take FFT of log (with offset
    % to avoid log of 0).
    hb = highboostfilter([rows cols], CutOff, order, boost);
    sample.data = exp(real(ifft2(FFTlogIm.*hb)));  % Apply the filter, invert
    % fft, and invert the log.
    sample.data=rescale(sample.data,0,255);
catch
    disp('Error in filtering image. Continuing without filtering')
end
            