function [nc_file, my, tt, ff, gg] = get_WOA_names_right(vv,tt,ff,gg)
% get_WOA_names_right gets the WOA names for data files and URLs right.
% The function also sets the names of the .mat files that contain the
% interpolated data using a new file-naming convention that is a bit more
% explicit than WOA's.
%
% Use:
%   >> [nc_file, my] = get_WOA_names_right(vv,tt,ff,gg)
%
%   input:
%     ├── vv = variable (string, required - no default). Possible choices:
%     │         't'   for Temperature
%     │         's'   for Salinity
%     │         'I'   for Density
%     │         'C'   for Conductivity
%     │         'o'   for Dissolved Oxygen
%     │         'O'   for Percent Oxygen Saturation
%     │         'A'   for Apparent Oxygen Utilization
%     │         'i'   for silicate
%     │         'p'   for phosphate
%     │         'n'   for nitrate
%     ├── tt = time period (number, optional - default 0). Possible choices:
%     │           0   for annual average
%     │        1-12   for monthly average
%     │          13   for Winter average
%     │          14   for Spring average
%     │          15   for Summer average
%     │          16   for Autumn average
%     ├── ff = field type (string, optional - default 'an'). Possible choices:
%     │        'an'   for objectively analyzed mean
%     │        'mn'   for Statistical mean
%     │        'dd'   for Number of observations
%     │        'sd'   for Standard deviations
%     │        'se'   for Standard error of the mean
%     │        'ma'   for Season/month minus annual mean
%     │        'gp'   for Grid points
%     └── gg = grid resolution (string, optional - default '01'). Possible choices:
%              '01'   for 1°x1°
%              '5d'   for 5°x5°
%
%   output:
%     ├── nc_file = structure which contains
%     │   ├── var_name    variable name for WOA's URLs
%     │   ├── res         resolution name for WOA's URLs
%     │   ├── deca_name   "decade" name for WOA's URLs, default is all or decav (average of
%     │   │                 all available decades. You have to change the code to get other decades)
%     │   ├── name        WOA's actual NetCDF file name
%     │   └── url         sub-structure which contains WOA's URLs
%     │       ├── OPeNDAP    OPeNDAP URL for the NetCDF file
%     │       └── download   URL to download the NetCDF file
%     └── my = structure which contains my preferred names for variables and mat files
%         ├── var_name     variable name, e.g., 'DIP' for '(dissolved inorganic) phosphate'
%         ├── field_type   'mean' or 'STD'
%         ├── res          resolution of the data used from WOA, 'WOA1x1' only
%         └── file_name    the file name for the interpolated .mat file

% Set default values
if nargin < 6
  gg = '01' ;
end
if nargin < 5
  ff = 'an' ;
end
if nargin < 4
  tt = 0 ;
end

switch vv
case 't'
  my.var_name = 'Temp' ; nc_file.var_name = 'temperature' ;
case 's'
  my.var_name = 'Salt' ; nc_file.var_name = 'salinity' ;
case 'I'
  my.var_name = 'Dens' ; nc_file.var_name = 'density' ;
case 'C'
  my.var_name = 'Cond' ; nc_file.var_name = 'conductivity' ;
case 'o'
  my.var_name = 'O2' ; nc_file.var_name = 'oxygen' ;
case 'O'
  my.var_name = 'O2sat' ; nc_file.var_name = 'o2sat' ;
case 'A'
  my.var_name = 'AOU' ; nc_file.var_name = 'AOU' ;
case 'i'
  my.var_name = 'DSi' ; nc_file.var_name = 'silicate' ;
case 'p'
  my.var_name = 'DIP' ; nc_file.var_name = 'phosphate' ;
case 'n'
  my.var_name = 'DIN' ; nc_file.var_name = 'nitrate' ;
otherwise
  fprintf('\n\n--->Your variable does not fit the World Ocean Atlas naming convention:\n')
  fprintf('      vv, the variable (string), nust be either:\n');
  fprintf('        ''t'' for Temperature\n');
  fprintf('        ''s'' for Salinity\n');
  fprintf('        ''I'' for Density\n');
  fprintf('        ''C'' for Conductivity\n');
  fprintf('        ''o'' for Dissolved Oxygen\n');
  fprintf('        ''O'' for Percent Oxygen Saturation\n');
  fprintf('        ''A'' for Apparent Oxygen Utilization\n');
  fprintf('        ''i'' for silicate\n');
  fprintf('        ''p'' for phosphate\n');
  fprintf('        ''n'' for nitrate\n\n');
end

% field type (only mine as all fields are in nc file)
switch ff
case 'an'
  my.field_type = 'mean' ; % because usually we just use this
case 'sd'
  my.field_type = 'STD' ; % because of matlab's std function
otherwise
  fprintf('\n\n--->You need to edit this function to define how to save something else than analyzed mean or STD!\n\n')
end

% resolution name (mine and WOA's urls)
switch gg
case '01'
  my.res = 'WOA1x1' ; nc_file.res = '1.00' ; % because usually we just use this
otherwise
  fprintf('\n\n--->You need to edit this function to deal with another resolution than 1x1!\n\n')
end

% Decade in url and NetCDF file name, decav means the average of all decades, edit here if you want another decade
switch vv
case {'t', 's', 'I', 'C'}
  nc_file.deca_name = 'decav' ;
otherwise
  nc_file.deca_name = 'all' ;
end

my.file_name = sprintf([my.field_type '_' my.var_name '_%02d_' my.res '.mat'],tt) ;

nc_file.name = sprintf(['woa13_' nc_file.deca_name '_' vv '%02d_' gg '.nc'],tt) ;
% odd v2 added at the end for temperature
if strcmp(vv,'t') nc_file.name = [nc_file.name(1:end-3) 'v2' nc_file.name(end-2:end)] ; end ;

nc_file.url.OPeNDAP = ['https://data.nodc.noaa.gov/thredds/dodsC/woa/WOA13/DATAv2/' ...
               nc_file.var_name '/netcdf/' nc_file.deca_name '/' nc_file.res '/' nc_file.name] ;
nc_file.url.download = ['https://data.nodc.noaa.gov/thredds/fileServer/woa/WOA13/DATAv2/' ...
               nc_file.var_name '/netcdf/' nc_file.deca_name '/' nc_file.res '/' nc_file.name] ;
