function Download_interpolate_and_save_data_from_WOA2013v2(M3d,grid,vv,tt,ff,gg)
% Download data from World Ocean Atlas (WOA) 2013 v2,
% then interpolates the data to the OCIM grid,
% and saves it in the results/data/ directory.
% The function will prompt the user about downloading the file or not:
% Note this is necessary if you cannot use the OPeNDAP URL.
%
% Use as:
%   >> Download_interpolate_and_save_data_from_WOA2013v2(M3d,grid,vv,tt,ff,gg)
%
%   input:
%     ├── M3d - the ocean grid boxes (standard in OCIM)
%     ├── grid - the associated grid variables (standard in OCIM)
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
% or in my github repository, at:
%   https://github.com/briochemc/Inpaint_Nans

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
    fprintf('  │ Warning: your MATLAB''s ncread function\n')
    fprintf('  │ does not seem to work with the OPeNDAP URL...\n')
    mversion = version ; mversion = mversion(end-6:end-1) ;
    fprintf(['  │ If your version (' mversion ') is pre-2017a,\n'])
    fprintf('  │ then you are probably encountering this bug:\n')
    fprintf('  │   https://www.mathworks.com/support/bugreports/1072120\n')
    use_OPeNDAP = 0 ;
  end
end
% Use OPeNDAP or the download file
if use_OPeNDAP
  file_path = nc_file.url.OPeNDAP ; where = 'remote OPeNDAP URL' ;
else
  raw_data_path = '../../raw_data/' ;
  wget_command = ['wget ' nc_file.url.download ' -q -P ' raw_data_path ' >/dev/null 2>&1'] ;
  fprintf('  Downloading the NetCDF file...')
  foo = system(wget_command) ; fprintf('Done!\n')
  file_path = [raw_data_path nc_file.name] ; where = 'local raw_data/ directory' ;
end

%%%----------------------------------------------------------------%%
%%%            Read the .nc file and build the WOA grid            %%
%%%----------------------------------------------------------------%%
% attributes of the variable
fprintf(['\n────── About to read and interpolate ' nc_file.var_name ': ──────\n'])
ncdisp(file_path,[vv '_' ff],'min') ;
fprintf('──────────────────────────────────────────────────────────\n')
fprintf(['\nReading NetCDF file from ' where '...'])
woa_xt = ncread(file_path,'lon') ;
woa_yt = ncread(file_path,'lat') ;
woa_zt = ncread(file_path,'depth') ;
woa_var_3d = ncread(file_path,[vv '_' ff]) ;
fprintf(' Done!\n')
% Reorder the variable index order (lat <-> lon from WOA to OCIM)
woa_var_3d = permute(woa_var_3d,[2 1 3]) ;
% Rearrange longitude range (WOA data is -180:180 and OCIM is 0:360)
[woa_xt, xt_reordering] = sort(mod(woa_xt,360)) ;
woa_var_3d(:,:,:) = woa_var_3d(:,xt_reordering,:) ;
% Mesh of WOA's grid
[woa_X,woa_Y,woa_Z] = meshgrid(woa_xt,woa_yt,woa_zt) ;

%%----------------------------------------------------------------%%
%%                 Interpolate to the OCIM grid                   %%
%%----------------------------------------------------------------%%
[ny,nx,nz] = size(M3d) ;
[woa_ny,woa_nx,woa_nz] = size(woa_var_3d) ;
fprintf('Inpainting the NaNs...')
for k = 1:woa_nz
  woa_var_3d(:,:,k) = inpaint_nans(woa_var_3d(:,:,k)) ;
end
fprintf(' Done.\nInterpolating in the vertical to the model grid...')
po4tmp = zeros(woa_ny,woa_nx,nz) ;
for i = 1:woa_ny
  for j = 1:woa_nx
    var_3d_tmp(i,j,:) = interp1(squeeze(woa_Z(1,1,:)),squeeze(woa_var_3d(i,j,:)),grid.zt) ;
  end
end
fprintf(' Done.\nInterpolating in the horizontal to the model grid...')
var_3d = 0 * M3d ;
for k = 1:nz
  var_3d(:,:,k) = interp2(woa_X(:,:,1),woa_Y(:,:,1),var_3d_tmp(:,:,k),grid.XT,grid.YT) ;
end
fprintf(' Done.\n')

%%----------------------------------------------------------------%%
%%                Save to appropriate directory                   %%
%%----------------------------------------------------------------%%
% I save the variable in column vector form
% as it uses less space and will be loaded and saved faster!
iocn = find(M3d) ;
var_ocn = var_3d(iocn) ; % no need to save the 3d field - less space
save_path = '../../results/data/' ;
save([save_path my.file_name],'var_ocn')
fprintf(['\nSaved as variable "var_ocn" in ' save_path my.file_name '\n'])

%%----------------------------------------------------------------%%
%%                         Delete raw data?                       %%
%%----------------------------------------------------------------%%
if ~use_OPeNDAP
  reply = input(['\n  Do you want to delete the local NetCDF file' nc_file.name '? y/n:\n    '],'s');
  switch reply
  case {'y','Y','yes','YES'}
    rm_command = ['rm ' file_path] ;
    system(rm_command) ;
    fprintf('  Deleting the NetCDF file.\n\n')
  case {'n','N','no','NO'}
    fprintf('  Keeping the NetCDF file.\n\n')
  otherwise
    fprintf('  I take that as a ''no''... Keeping the NetCDF file.\n\n')
  end
end