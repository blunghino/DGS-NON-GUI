
% calc_psd
% calculates PSD for each ROI
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
%   This function is part of 'dgs-batch' software
%   This software is in the public domain because it contains materials that originally came 
%   from the United States Geological Survey, an agency of the United States Department of Interior. 
%   For more information, see the official USGS copyright policy at 
%   http://www.usgs.gov/visual-id/credit_usgs.html#copyright
%====================================


density=Setts.density;
MotherWav={'Paul';'Morlet';'DOG'};
wavs=2;
Args=struct('Pad',1,...      % pad the time series with zeroes (recommended)
    'Dj',1/8,... %8, ...    % this will do dj sub-octaves per octave
    'S0',start_size,...    % this says start at a scale of X pixels
    'J1',[],...
    'Mother',MotherWav{wavs});

if Setts.filter
   batch_do_filter 
end

if Setts.flatten
   batch_do_flatten
end

[P,scale]=batch_get_psd(sample.data,density,Args);

P(isnan(P))=0;
D=P./sum(P);

sample.dist=[scale(:).*Setts.res,D(:)];

[sample.percentiles,sample.geom_moments,...
    sample.arith_moments]=gsdparams(sample.dist(:,2),sample.dist(:,1));

sample.geom_moments(2) = 1000*2^-sample.geom_moments(2);

clear D scalei index_keep
    
    