function [M,X,Y,Z,del] = accessWOA13(vv,tt,ff,gg)
%
% accessWOA13 fetches World Ocean Atlas (WOA) 2013 v2 data
% from NetCDF files, using a OPeNDAP URL if possible
% (and downloading the NetCDF file if not possible)
% accessWOA13 outputs the requested variable and the corresponding
% spatial coordinates (longitude, latitude, depth) as 3-dimensional
% matrices.
%
% Authors:
%   - Benoit Pasquier (BP)
%   - Syed Faizanul Haque
%   - Francois Primeau
%
% Use as either:
%  >> [M,X,Y,Z] = accessWOA13(vv) ;
%  >> [M,X,Y,Z] = accessWOA13(vv,tt,) ;
%  >> [M,X,Y,Z] = accessWOA13(vv,tt,ff) ;
%  >> [M,X,Y,Z] = accessWOA13(vv,tt,ff,gg) ;
%
% Or as
%  >> [M,X,Y,Z,del] = accessWOA13(...) ;
% if you want to delete the local NetCDF file (if it was downloaded)
%
% input:
%   ├── vv = variable (string, required - no default). Possible choices:
%   │          't'   for Temperature
%   │          's'   for Salinity
%   │          'I'   for Density
%   │          'C'   for Conductivity
%   │          'o'   for Dissolved Oxygen
%   │          'O'   for Percent Oxygen Saturation
%   │          'A'   for Apparent Oxygen Utilization
%   │          'i'   for silicate
%   │          'p'   for phosphate
%   │          'n'   for nitrate
%   ├── tt = time period (number, optional - default 0). Possible choices:
%   │             0   for annual average
%   │          1-12   for monthly average
%   │            13   for Winter average
%   │            14   for Spring average
%   │            15   for Summer average
%   │            16   for Autumn average
%   ├── ff = field type (string, optional - default 'an'). Possible choices:
%   │          'an'   for objectively analyzed mean
%   │          'mn'   for Statistical mean
%   │          'dd'   for Number of observations
%   │          'sd'   for Standard deviations
%   │          'se'   for Standard error of the mean
%   │          'ma'   for Season/month minus annual mean
%   │          'gp'   for Grid points
%   └── gg = grid resolution (string, optional - default '01'). Possible choices:
%              '04'   for 0.25° × 0.25°
%              '01'   for 1° × 1°
%              '5d'   for 5° × 5°
%
% output (3d matrices):
%   ├── M   = variable
%   ├── X   = longitude
%   ├── Y   = latitude
%   ├── Z   = depth
%   └── del = optional output to force deletion of the NetCDF file
%               1 if file was deleted
%               0 otherwise
%
% For citation of WOA13 Data, see:
%   https://www.nodc.noaa.gov/OC5/woa13/pubwoa13.html
%
% Note that you can directly use the bibtex entries that are available
% in the bib file of BP's texmf repository on github, at:
%   https://github.com/briochemc/texmf
% (Search for WOA in the bib file, or fork/clone the textmf repo directly.)
%
% Examples:
%
%   >> [M,X,Y,Z] = accessWOA13('p') ;
% will fetch the annual average of the objectively analyzed mean
% phosphate concentration on WOA's 1° × 1° grid.
%
%   >> [M,X,Y,Z,del] = accessWOA13('p') ;
% same as above, but will delete the NetCDF file if it was downloaded.
%
%   >> [M,X,Y,Z] = accessWOA13('s','1','sd','5d') ;
% will fetch the january average of the standard deviation
% silicate concentration on WOA's 5° × 5° grid.
%
% See also ncdisp, ncread, ncinfo, websave, exist

% MIT License
%
% Copyright (c) 2017 Benoit Pasquier, Syed Faizanul Haque, and Francois Primeau.
%
% Permission is hereby granted, free of charge, to any person obtaining a copy
% of this software and associated documentation files (the "Software"), to deal
% in the Software without restriction, including without limitation the rights
% to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
% copies of the Software, and to permit persons to whom the Software is
% furnished to do so, subject to the following conditions:
%
% The above copyright notice and this permission notice shall be included in all
% copies or substantial portions of the Software.
%
% THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
% IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
% FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
% AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
% LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
% OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
% SOFTWARE.

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

%%----------------------------------------------------------------%%
%%                Use OPeNDAP URL or download file                %%
%%----------------------------------------------------------------%%
[nc_file, my, tt, ff, gg] = get_WOA_names_right(vv,tt,ff,gg) ;

try % try to use the OPeNDAP URL
  ncinfo(nc_file.url.OPeNDAP) ;
  use_OPeNDAP = 1 ;
catch exception % if OPeNDAP does not work, tell the user what the problem is
  fprintf('  │ WARNING: your MATLAB''s version\n')
  fprintf('  │ does not seem to work with the OPeNDAP URL...\n')
  fprintf(['  │ If your version (which is ' version('-release') ') is pre-2017a,\n'])
  fprintf('  │ then you are probably encountering this bug:\n')
  fprintf('  │   https://www.mathworks.com/support/bugreports/1072120\n')
  use_OPeNDAP = 0 ;
end

downloaded = 0 ;
if use_OPeNDAP % Use OPeNDAP URL
  file_path = nc_file.url.OPeNDAP ;
  where = 'remote OPeNDAP URL' ;
else % or download the file
  file_path = [nc_file.name] ; where = 'current directory' ;
  if exist(nc_file.name, 'file') == 2
    fprintf('The NetCDF file already exists locally.') ;
  elseif exist(nc_file.name, 'file') == 0
    websave(nc_file.name,nc_file.url.download) ;
    fprintf('The NetCDF file does not exist locally.') ;
    fprintf('  Downloading the NetCDF file...')
    fprintf('Done!\n')
    downloaded = 1 ;
  end
end

%%----------------------------------------------------------------%%
%%                     Read the NetCDF file                       %%
%%----------------------------------------------------------------%%
% Print attributes of the variable
fprintf(['\n────── About to read ' nc_file.var_name ': ──────\n'])
ncdisp(file_path,[vv '_' ff],'min') ;
fprintf('──────────────────────────────────────────────────────────\n')
fprintf(['\nReading NetCDF file from ' where '...']);
X = ncread(file_path,'lon') ;
Y = ncread(file_path,'lat') ;
Z = ncread(file_path,'depth') ;
M = ncread(file_path,[vv '_' ff]) ;
fprintf(' Done!\n');

%%----------------------------------------------------------------%%
%%                     Delete NetCDF file                         %%
%%----------------------------------------------------------------%%
% Delete the NetCDF file if the user asks for it with the
% additional 5th output "del" and if the file was downloaded.
if nargout == 5
  if downloaded
    rm_command = ['rm ' file_path] ;
    fprintf('  Deleting the NetCDF file.\n\n')
    system(rm_command) ;
    del = 1 ;
  else
    del = 0 ;
  end
end
