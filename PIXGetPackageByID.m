function p = PIXGetPackageByID( id )

% P = PIXGetPackageByID( id )
%
%  returns the package structure for the package with given ID.
%

global PIXPackages;

i = find( [PIXPackages(:).id] == id );

if isempty(i) 
	warning( 'No package matches that id.' );
	return;
end;

p = PIXPackages(i);

% 

%
% $Id: PIXGetPackageByID.m 21 2016-02-11 22:21:37Z  $
%
% $Log: PIXGetPackageByID.m,v $
% Revision 1.2  1904/03/26 11:20:04  stanley
% auto insert keywords
%
%
%key internal pixel pixelDesign 
%comment  Returns the package structure for the package with given ID 
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

