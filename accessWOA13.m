function [M, X, Y, Z] = accessWOA13(vv,tt,ff,gg)

%Download data from World Ocean Atlas (WOA) 2013 v2,
%and save the matrices
%Authors: Benoit Pasquir, Syed Faizanul Haque, Francois Primeau
%accessWOA13.m

% The function will prompt the user about downloading the file or not:
% Note this is necessary if you cannot use the OPeNDAP URL.

% Use as:
%  >> [M , X , Y , Z] = accessWOA13(vv,tt,ff,gg)

%input:
%     ??? vv = variable (string, required - no default). Possible choices:
%     ?         't'   for Temperature
%     ?         's'   for Salinity
%     ?         'I'   for Density
%     ?         'C'   for Conductivity
%     ?         'o'   for Dissolved Oxygen
%     ?         'O'   for Percent Oxygen Saturation
%     ?         'A'   for Apparent Oxygen Utilization
%     ?         'i'   for silicate
%     ?         'p'   for phosphate
%     ?         'n'   for nitrate
%     ??? tt = time period (number, optional - default 0). Possible choices:
%     ?           0   for annual average
%     ?        1-12   for monthly average
%     ?          13   for Winter average
%     ?          14   for Spring average
%     ?          15   for Summer average
%     ?          16   for Autumn average
%     ??? ff = field type (string, optional - default 'an'). Possible choices:
%     ?        'an'   for objectively analyzed mean
%     ?        'mn'   for Statistical mean
%     ?        'dd'   for Number of observations
%     ?        'sd'   for Standard deviations
%     ?        'se'   for Standard error of the mean
%     ?        'ma'   for Season/month minus annual mean
%     ?        'gp'   for Grid points
%     ??? gg = grid resolution (string, optional - default '01'). Possible choices:
%              '04'   for 0.25°x025°
%              '01'   for 1°x1°
%              '5d'   for 5°x5°

% For citation of WOA13 Data, see:
%   https://www.nodc.noaa.gov/OC5/woa13/pubwoa13.html
%
% Note that you can directly use the bibtex entries that are available
% in the bib file of my texmf repository on github, at:
%   https://github.com/briochemc/texmf
% (Search for WOA in the bib file, or fork/clone the textmf repo directly.)
%
% Note that this function requires inpaint_nans from John d'Errico,
% available on mathworks, at:
%   https://www.mathworks.com/matlabcentral/fileexchange/4551-inpaint-nans
% or in Benoit Pasquir's github repository, at:
%   https://github.com/briochemc/Inpaint_Nans
%
%Examples
%
%Example 1:
%
%Example 2:
%
%Example 3: Automate download without the prompt
%
%
%%See also ncdisp, ncread, ncinfo, websave, exist

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

%%%----------------------------------------------------------------%%
%%%                Use OPeNDAP URL or download file                %%
%%%----------------------------------------------------------------%%
[nc_file, my, tt, ff, gg] = get_WOA_names_right(vv,tt,ff,gg) ;
% ask if want to download data file
reply = input(['\n  Do you want to download the NetCDF file ' nc_file.name '? [y/n]:\n    '],'s');
switch reply
    case {'y','Y','yes','YES'}
        use_OPeNDAP = 0 ;
    case {'n','N','no','NO'}
        use_OPeNDAP = 1 ;
    otherwise
        fprintf('\n')
        error('    I don''t understdand your answer! Aborting...')
end
if use_OPeNDAP % test OPeNDAP and don't use if not
    try % try to use the OPeNDAP URL
        ncinfo(nc_file.url.OPeNDAP) ;
    catch exception % tell what the problem is
        fprintf('  ? Warning: your MATLAB''s ncread function\n')
        fprintf('  ? does not seem to work with the OPeNDAP URL...\n')
        mversion = version ; mversion = mversion(end-6:end-1) ;
        fprintf(['  ? If your version (' mversion ') is pre-2017a,\n'])
        fprintf('  ? then you are probably encountering this bug:\n')
        fprintf('  ?   https://www.mathworks.com/support/bugreports/1072120\n')
        use_OPeNDAP = 0 ;
    end
end
% Use OPeNDAP or the download file
if use_OPeNDAP
    file_path = nc_file.url.OPeNDAP ; where = 'remote OPeNDAP URL' ;
else
    file_path = [nc_file.name] ; where = 'current directory' ;
    if exist(nc_file.name, 'file') == 2
        fprintf( 'File already exists in the local machine.');
 
    elseif exist(nc_file.name, 'file') == 0
        websave(nc_file.name,nc_file.url.download );
        fprintf('File does not exist in the local machine.' );
        fprintf('  Downloading the NetCDF file...')
        fprintf('Done!\n')
    end
end


%%%----------------------------------------------------------------%%
%%%            Read the .nc file             %%
%%%----------------------------------------------------------------%%
% attributes of the variable
fprintf(['\n?????? About to read ' nc_file.var_name ': ??????\n']);
ncdisp(file_path,[vv '_' ff],'min') ;
fprintf('??????????????????????????????????????????????????????????\n');
fprintf(['\nReading NetCDF file from ' where '...']);
X = ncread(file_path,'lon') ;
Y = ncread(file_path,'lat') ;
Z = ncread(file_path,'depth') ;
M = ncread(file_path,[vv '_' ff]) ;

fprintf(' Done!\n');
