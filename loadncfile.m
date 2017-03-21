function x = loadncfile( fn )

% x = loadncfile( fn )
%
%   load a netCDF file in as generic a way as possible. this handles all
%   the fiddly bits of finding variables, etc.
%
%   x.attr will be a struct containing the global attributes
%   x.data will be an array of structs containing data and the 
%      associated attributes.
%

%%

ncid = netcdf.open( fn, 'NC_NOWRITE' );

[ndims, nvars, natts, unlim] = netcdf.inq( ncid );

gatt = netcdf.getConstant('NC_GLOBAL');

for ii=1:natts
    
    x.attr(ii).name = netcdf.inqAttName( ncid, gatt, ii-1 );
    x.attr(ii).value = netcdf.getAtt( ncid, gatt, x.attr(ii).name );
    
end

for ii=1:ndims
    
    [ x.dims(ii).name, x.dims(ii).length ] = netcdf.inqDim(ncid, ii-1);
    if unlim == ii-1
        x.dims(ii).unlimited = 1;
    else
        x.dims(ii).unlimited = 0;
    end
    
end

%%
for ii=1:nvars
    
    [x.var(ii).name, x.var(ii).type, x.var(ii).dim, x.var(ii).natts] = ...
        netcdf.inqVar( ncid, ii-1 );
    if x.var(ii).type == 7    % kludge for matlab not knowing about uint8 data
        x.var(ii).value = netcdf.getVar( ncid, ii-1, 'uint8' );
    else 
        x.var(ii).value = netcdf.getVar( ncid, ii-1 );
    end
    
    for jj=1:x.var(ii).natts
        x.var(ii).attr(jj).name = netcdf.inqAttName( ncid, ii-1, jj-1 );
        x.var(ii).attr(jj).value = ...
            netcdf.getAtt( ncid, ii-1, x.var(ii).attr(jj).name );
    end
    
end

        
%
%   Copyright (C) 2017  Coastal Imaging Research Network
%                       and Oregon State University

%    This program is free software: you can redistribute it and/or
%    modify it under the terms of the GNU General Public License as
%    published by the Free Software Foundation, version 3 of the
%    License.

%    This program is distributed in the hope that it will be useful,
%    but WITHOUT ANY WARRANTY; without even the implied warranty of
%    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
%    GNU General Public License for more details.

%    You should have received a copy of the GNU General Public License
%    along with this program.  If not, see
%                                <http://www.gnu.org/licenses/>.

% CIRN: https://coastal-imaging-research-network.github.io/
% CIL:  http://cil-www.coas.oregonstate.edu
%

