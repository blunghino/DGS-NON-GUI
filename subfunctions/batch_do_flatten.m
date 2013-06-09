
% do_flatten
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


disp('Flattening image ...')

try
    img=imageresize(sample.data, .5, .5);
    
    [rows,cols] = size(img); %sample(ix).data);
    [x,y] = meshgrid(1:rows,1:cols);
    P = polyfitn([x(:),y(:)],img(:),2); %sample(ix).data(:),2);
    zhat = polyvaln(P,[x(:),y(:)]);
    zhat = reshape(zhat,rows,cols);
    sample.data=rescale(imageresize(img-zhat,2,2),0,255); %sample(ix).data-zhat,0,255);
    clear x y P zhat rows cols
catch
    disp('Error in flattening image: ran out of memory. Continuing with a slower method')
    
    tmp=sample.data; tmp(:,1:2:end)=[]; tmp(1:2:end,:)=[];
    [rows,cols] = size(tmp);
    [x,y] = meshgrid(1:rows,1:cols);
    P = polyfitn([x(:),y(:)],tmp(:),2);
    zhat = polyvaln(P,[x(:),y(:)]);
    zhat = reshape(zhat,rows,cols);
    b = ones(size(zhat)).*NaN;
    c = reshape([zhat(:) b(:)]',2*size(zhat,1), []);
    d = ones(size(c)).*NaN; c=c'; d=d';
    e = reshape([c(:) d(:)]',2*size(c,1), [])';
    zhat=inpaintn(e,1);
    sample.data=rescale(sample(ii).data-zhat,0,255);
    clear x y P zhat rows cols b c d e tmp
    
end


