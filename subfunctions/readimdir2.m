
function [filenames] = readimdir2(directory,ext)
%READIMDIR2
% Reads images of multiple file extensions in a directory, and returns them as a structure of filenames
% as strings
% [filenames] = ReadImDir2(directory,extension)
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
F=[];
for i=1:length(ext)
direc=dir([directory,filesep,'*.',ext{i}]); %list directory and separate .*ext files
filenames={};   %create a structure of these files
[filenames{1:length(direc),1}] = deal(direc.name); %Deal inputs to outputs!
F=[F;filenames];
end

filenames=sortrows(char(F{:})); %Create character array, and sort rows in ascending order
