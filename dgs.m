
function dgs(config_file)

%  EXAMPLE USAGES:
%  dgs
%  dgs('dgs.config')
%  config_file = 'dgs.config'; dgs(config_file)
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

warning off all
addpath(genpath(pwd))

% mkdir([pwd,filesep,'outputs'])

disp('<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<')
fprintf(2,'Digital Grain Size Batch Processor\n');
fprintf(2,'by Daniel Buscombe\n');
fprintf(2,'version 1.0, June 2013\n');
fprintf(2,'A program to estimate grain size from images of sediment\n');
disp('>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>')
fprintf(2,'\n');

%==================================================================
%==== Part 1: read the config file, and check it for errors ==============
%==================================================================
try
    tmp.fid = fopen(config_file);
    
    if tmp.fid<0
        fprintf(2,...
            'error: config_file can''t be read. Is it on your MATLAB path?\n');
        
        out = get_folders();
    else
        tmp.str=fgets(tmp.fid);
        while ischar(tmp.str)
            if min([~(tmp.str(1)=='%') ~(length(tmp.str)<4)])
                eval(['Setts.' tmp.str ';']);
            end
            tmp.str=fgets(tmp.fid);
        end
    end
    fclose(tmp.fid);
    
    if ~isfield(Setts,'verbose') || isempty(Setts.verbose)  || ~isnumeric(Setts.verbose)
        disp('No ''verbose'' setting given.')
        disp('Setting to 0 (output will not be printed to screen but a progress bar will. ')
        disp('To change this, input verbose=1 in the config file)')
        Setts.verbose=0;
        fprintf(2,'\n');
    end
    
    
    if ~isfield(Setts,'filter') || isempty(Setts.filter)  || ~isnumeric(Setts.filter)
        if Setts.verbose==1
            disp('No setting for filter given.')
            disp('Will not filter (to change this, rerun with filter=1 in the config file)')
        end
        Setts.filter=0;
        Setts.filtoptions=0;
        fprintf(2,'\n');
    end
    
    if Setts.filter==1 && ~isfield(Setts,'filteroptions')
        if Setts.verbose==1
            disp('Filter requested, but no filter options given.')
            disp('Setting filter values to defaults ')
            disp('(to change this, rerun with filteroptions set in the config file)')
        end
        Setts.filtoptions.boost=3;
        Setts.filtoptions.CutOff=.2;
        Setts.filtoptions.order=2;
        fprintf(2,'\n');
    end
    
    if Setts.filter==0
        Setts.filtoptions=0;
        fprintf(2,'\n');
    end
    
    if ~isfield(Setts,'flatten') || isempty(Setts.flatten)  || ~isnumeric(Setts.flatten)
        if Setts.verbose==1
            disp('No ''flatten'' setting given.')
            disp('Setting to 1 to filter out strong light contamination ')
            disp('(to change this, input flatten=0 in the config file)')
        end
        Setts.flatten=1;
        fprintf(2,'\n');
    end
    
    if ~isfield(Setts,'return_used_image') || isempty(Setts.return_used_image)  || ~isnumeric(Setts.return_used_image)
        if Setts.verbose==1
            disp('No ''return_used_image'' setting given.')
            disp('Setting to 0 (the filtered, flattened greyscale image will not be returned. ')
            disp('To change this, input return_used_image=1 in the config file)')
        end
        Setts.return_used_image=0;
        fprintf(2,'\n');
    end
    
    
    if ~isfield(Setts,'res') || isempty(Setts.res)  || ~isnumeric(Setts.res)
        if Setts.verbose==1
            disp('No resolution given.')
            disp('Setting resolution to 1 mm/pixel (multiply grain sizes by correct mm/pixel value)')
        end
        Setts.res=1;
        fprintf(2,'\n');
    end
    
    if ~isfield(Setts,'start_size') || isempty(Setts.start_size)  || ~isnumeric(Setts.start_size)
        if Setts.verbose==1
            disp('No ''start_size'' given.')
            disp('Setting to 1 x supplied resolution ')
            disp('(to change this, start_size= in the config file)')
        end
        Setts.start_size=1;
        fprintf(2,'\n');
        start_size=Setts.start_size*Setts.res;
    else
        if Setts.res==1
            start_size=Setts.start_size*Setts.res;
        else
            start_size=Setts.start_size;
        end
    end
    
    if ~isfield(Setts,'density') || isempty(Setts.density)  || ~isnumeric(Setts.density)
        if Setts.verbose==1
            disp('No sampling density given.')
            disp('Setting density to 50 (analysis of every 50th row through the image)')
        end
        Setts.density=50;
        fprintf(2,'\n');
    end
    
catch
    out = get_folders();
    
    Setts.res=1;
    Setts.filter=0;
    Setts.filtoptions=0;
    Setts.verbose=0;
    Setts.flatten=1;
    Setts.return_used_image=0;
    Setts.start_size=1;
    start_size=Setts.start_size*Setts.res;
    Setts.density=50;
end

clear tmp ans


%==================================================================
%============ Part 2: select directory(s) ==============
%==================================================================

if ~exist('out','var')
    
    if strmatch(Setts.folder,'directories.txt')
        
        tmp.fid = fopen(Setts.folder);
        tmp.str=fgets(tmp.fid);
        counter=0;
        while ischar(tmp.str)
            counter=counter+1;
            eval(['out.dir',num2str(counter),'=strtrim(tmp.str);'])
            tmp.str=fgets(tmp.fid);
        end
        
        fclose(tmp.fid);
        
    else
        
        if iscell(Setts.folder) % cell of mutiple folders
            
            for folderloop=1:length(Setts.folder)
                if ~exist(eval(['Setts.folder{',num2str(folderloop),'}']),'dir')
                    fprintf(2,...
                        'error: supplied directory does not exist\n');
                    return
                end
                eval(['out.dir',num2str(folderloop),'=Setts.folder{',num2str(folderloop),'};'])
            end
            
        elseif ~isfield(Setts,'folder') || isempty(Setts.folder)
            
            out = get_folders();
            
        else % folder is a string of just 1 directory
            if isnumeric(Setts.folder)
                out = get_folders();
            else
                if ~exist(Setts.folder,'dir')
                    fprintf(2,...
                        'error: supplied directory does not exist\n');
                    return
                end
                out.dir1=Setts.folder;
                addpath(out.dir1)
                
            end
            
        end
        
    end
    
end


%==================================================================
%============ Part 3: cycle through folders and images therein =======
%==================================================================

files=cell(length(fieldnames(out)),1);

for i=1:length(fieldnames(out))
    
    addpath(eval(['out.dir',num2str(i)]))
    
    files{i}=readimdir2(eval(['out.dir',num2str(i)]),...
        {'bmp','jpg', 'jpeg', 'png', 'tiff', 'tif','BMP', 'JPG', 'JPEG', 'PNG',  'TIFF', 'TIF'});
    
%     if strmatch(strtrim(files{i}(1,:)),strtrim(files{i}(2,:)))
%         files{i}=files{i}(1:2:end,:);
%     end
    
    
    if Setts.verbose==0
        L=[];for ll=1:size(files{i},1); L=[L,'-'];end
        disp(['start ',L,' end'])
        fprintf(2,['      '])
    end
    
    
    for ii = 1:size(files{i},1) % main loop
        if Setts.verbose==0
            fprintf(2,'>')
        else
            disp(['processing ',deblank(files{i}(ii,:))]);
        end
        
        sample.data=imread([eval(['out.dir',num2str(i)]),filesep,deblank(files{i}(ii,:))]);
        if numel(size(sample.data))==3
            sample.data=double(0.299 * sample.data(:,:,1) + 0.5870 * ...
                sample.data(:,:,2) + 0.114 * sample.data(:,:,3));
        else
            sample.data=double(sample.data);
        end
        
        batch_calc_psd
        
        batch_save_psd
        
    end
    
    
    if Setts.verbose==0
        fprintf(2,' finished!\n')
    end
    
end


%==================================================================
%============ subfunctions ==============
%==================================================================

function out = get_folders()

if isunix
    out.dir1 = uigetdir(pwd,'Pick a Directory'); %getenv('HOME'),
else
    out.dir1 = uigetdir(pwd, 'Pick a Directory');
end

ButtonName = questdlg('another directory?', '', 'No');

counter=1;
lastdir =out.dir1;
while strcmp(ButtonName,'Yes')
    counter=counter+1;
    if strcmp(ButtonName,'Yes')
        if isunix
            eval(['out.dir',num2str(counter),' = uigetdir(lastdir, ''Pick a Directory'');'])
        else
            eval(['out.dir',num2str(counter),' = uigetdir(lastdir, ''Pick a Directory'');'])
        end
        
    end
    ButtonName = questdlg('another directory?', '', 'No');
    eval(['lastdir=out.dir',num2str(counter),';'])
end


