 dgs_batch.m

MATLAB software to calculate the grain size distribution from an image of sediment or other granular material

To run the program, download and unzip, open MATLAB, cd to the directory, then in the command window type:

dgs('my_config_file')

The 'config file' contains a number of variables which the program needs to use to run the program, such as the location of the images, resolution, and other options. See 'dgs.config' for a full example of arguments the program can understand, 'dgs_minimal.config' for the minimal settings, and 'dgs_manyfolders.config' for an example config file where you want to batch process a lot of directories containing images with the same resolution. 

Any parameter not passed to the program will take on default values (see the source code for details)

This program implements the algorithm of 
Buscombe, D. (2013, in press) Transferable Wavelet Method for Grain-Size Distribution from Images of Sediment Surfaces and Thin Sections, and Other Natural Granular Patterns, Sedimentology
 
Written by Daniel Buscombe, various times in 2012 and 2013
while at
School of Marine Science and Engineering, University of Plymouth, UK
and now:
Grand Canyon Monitoring and Research Center, U.G. Geological Survey, Flagstaff, AZ 

Please contact:
dbuscombe@usgs.gov

to report bugs and discuss the code, algorithm, collaborations

For the latest code version please visit:
https://github.com/dbuscombe-usgs

There is also a GUI-based version of this software available 


See also the project blog: 
http://dbuscombe-usgs.github.com/

Please download, try, report bugs, fork, modify, evaluate, discuss. Thanks for stopping by!
