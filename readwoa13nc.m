function [M] = readwoa13nc(n, type)
% M = readwoa13nc(n,type)
% Input:
%    type: 
%    type = 1      temperature
%    type = 2      salinity
%    type = 3      oxygen
%    type = 4      Nitrate
%    type = 5      Phosphate
%    type = 6      Silicate
%    type = 7      Density
%    type = 8      Conductivity
%    type = 9      Percent Oxygen Saturation
%    type = 10     Apparent Oxygen Utilization
%
%    n:
%    n = 0     annual average
%    n = 1:12  monthly average
%    n = 13    Winter average
%    n = 14    Spring average
%    n = 15    Summer average
%    n = 16    Autumn average
%
%   Depending on the n value and type M is either a 180 x 360 x 102 array or a 
%   180 x 360 x 57 array
%
% Example 
%     M = readwoa13nc(0,1);
%     contourf(M(:,:,1)); 
%     title('SST annual average (deg C)')
% Download the netcdf format dataset from woa13
% readwoa13nc.m
% Author: Syed Faizanul Haque
% Nov/5/2017
% This function downloads the 1 degree objectively analyzed dataset
% for the different variables from the World Ocean Atlas 2013 v2 database.
% It reads in the netcdf file and outputs a matrix
%For more information please read the readwoa13ncReadMe file at
%https://github.com/UCI-OCEANOGRAPHY/matlab-tools
%
%See also ncdisp, ncread

if (type == 1)
    %Temperature
    if (n<10)
        fname = sprintf('woa13_decav_t0%i_01v2.nc',n);
    else
        fname = sprintf('woa13_decav_t%i_01v2.nc',n);
    end    
    url = sprintf('https://data.nodc.noaa.gov/woa/WOA13/DATAv2/temperature/netcdf/decav/1.00/%s',fname);
    websave(fname,url);
    M = ncread(fname, 't_an');
end

if (type == 2)
    %Salinity
    if (n<10)
        fname = sprintf('woa13_decav_s0%i_01v2.nc',n);
    else
        fname = sprintf('woa13_decav_s%i_01v2.nc',n);
    end    
    url = sprintf('https://data.nodc.noaa.gov/woa/WOA13/DATAv2/salinity/netcdf/decav/1.00/%s',fname);
    websave(fname,url);
    M = ncread(fname, 's_an');
end

if (type == 3)
    %Oxygen
    if (n<10)
        fname = sprintf('woa13_all_o0%i_01.nc',n);
    else
        fname = sprintf('woa13_all_o%i_01.nc',n);
    end    
    url = sprintf('https://data.nodc.noaa.gov/woa/WOA13/DATAv2/oxygen/netcdf/all/1.00/%s',fname);
    websave(fname,url);
    M = ncread(fname, 'o_an');
end

if (type == 4)
    %Nitrate
    if (n<10)
        fname = sprintf('woa13_all_n0%i_01.nc',n);
    else
        fname = sprintf('woa13_all_n%i_01.nc',n);
    end
    
    url = sprintf('https://data.nodc.noaa.gov/woa/WOA13/DATAv2/nitrate/netcdf/all/1.00/%s',fname);
    websave(fname,url);
    M = ncread(fname, 'n_an');
end

if (type == 5)
    %Phosphate
    if (n<10)
        fname = sprintf('woa13_all_p0%i_01.nc',n);
    else
        fname = sprintf('woa13_all_p%i_01.nc',n);
    end
    
    url = sprintf('https://data.nodc.noaa.gov/woa/WOA13/DATAv2/phosphate/netcdf/all/1.00/%s',fname);
    websave(fname,url);
    M = ncread(fname, 'p_an');
end

if (type == 6)
    %Silicate
    if (n<10)
        fname = sprintf('woa13_all_i0%i_01.nc',n);
    else
        fname = sprintf('woa13_all_i%i_01.nc',n);
    end
    
    url = sprintf('https://data.nodc.noaa.gov/woa/WOA13/DATAv2/silicate/netcdf/all/1.00/%s',fname);
    websave(fname,url);
    M = ncread(fname, 'i_an');
end
if (type == 7)
    %Density
    if (n<10)
        fname = sprintf('woa13_decav_I0%i_01.nc',n);
    else
        fname = sprintf('woa13_decav_I%i_01.nc',n);
    end
    
    url = sprintf('https://data.nodc.noaa.gov/woa/WOA13/DATAv2/density/netcdf/decav/1.00/%s',fname);
    websave(fname,url);
    M = ncread(fname, 'I_an');
end

if (type == 8)
    %Conductivity
    if (n<10)
        fname = sprintf('woa13_decav_C0%i_01.nc',n);
    else
        fname = sprintf('woa13_decav_C%i_01.nc',n);
    end
    
    url = sprintf('https://data.nodc.noaa.gov/woa/WOA13/DATAv2/conductivity/netcdf/decav/1.00/%s',fname);
    websave(fname,url);
    M = ncread(fname, 'C_an');
end

if (type == 9)
    %Percent Oxygen Saturation
    if (n<10)
        fname = sprintf('woa13_all_O0%i_01.nc',n);
    else
        fname = sprintf('woa13_all_O%i_01.nc',n);
    end
    
    url = sprintf('https://data.nodc.noaa.gov/woa/WOA13/DATAv2/o2sat/netcdf/all/1.00/%s',fname);
    websave(fname,url);
    M = ncread(fname, 'O_an');
end

if (type == 10)
    %Apparent Oxygen Utilization
    if (n<10)
        fname = sprintf('woa13_all_A0%i_01.nc',n);
    else
        fname = sprintf('woa13_all_A%i_01.nc',n);
    end
    
    url = sprintf('https://data.nodc.noaa.gov/woa/WOA13/DATAv2/AOU/netcdf/all/1.00/%s',fname);
    websave(fname,url);
    M = ncread(fname, 'A_an');
end
M = permute( M, [2 1 3]);
delete (fname);

end

