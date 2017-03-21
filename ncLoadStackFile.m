function [p,e,m,d] = ncLoadStackFile( fn )

%  quick and dirty "loadStack" for netCDF version
%  doesn't have all the bells/whistles of the old one, just 
%   a demo to show the mechanics of doing this.

% open and read the file
x = loadncfile( fn );

% parse x into p, e, m, and d
% first, p. all global attributes
a = x.attr;
p = [];
for ii = 1:length(a)
    p = setfield( p, a(ii).name, a(ii).value );
end

if( ~isfield(p,'magic') || (p.magic ~= 1.504078485000000e+09) )
    p.err = 'this is not a stack file!';
    warning(['File ' fn ' is not a valid stack file.'] );
    return;
end

order = 1:length(p.U);
p.order = order';

% backwards compatible variables not required in netcdf file
p.increment = 1;  % from dipix, but someone may look at this
p.ust = 0.0;  % unadjusted system time is always 0, leftover from SGI
p.syncTime = p.when;

% switch orientation of variables to match older stacks
p.U = p.U';
p.V = p.V';

% I know what is in x.var.
v = x.var;
for ii = 1:length(v)
    eval( [ v(ii).name '= v(ii).value;' ] );
end

% and make them look like the older stacks.
e = epoch';
d = pix';
m = [ gain intTime ]';

%
% $Id: ncLoadStackFile.m 21 2016-02-11 22:21:37Z  $
%
% $Log: ncLoadStackFile.m,v $
% Revision 1.1  2016/02/11 22:07:12  stanley
% Initial revision
%
% Revision 1.1  2012/12/12 22:48:13  stanley
% Initial revision
%
%
%key 
%comment  
%

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

