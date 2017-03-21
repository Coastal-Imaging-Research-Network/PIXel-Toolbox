
function [instID, matrixID] = PIXMakePlane( x1, y1, x2, y2, z1, z2, name );

% function [instID] = PIXMakePlane( x1, y1, x2, y2, z1, z2, name );
%
%   make a Plane -- an area of every pixel between X1,Y1/X2,Y2
%    from elevation z1 to z2
%    name it 'name'. 
%
%  a vertical plane.
%
%   returns intrument ID so you can build it into a package and the
%   matrix ID so you can do whatever.
%

% -- .1m spacing on all dimensions. lines.

instID = PIXCreateInstrument( name, 'patch', PIXUniqueOnly+PIXFixedZ );
zm = z1:.2:z2;

for( ii=1:length(zm) )
    matrixID = PIXAddLine( instID, x1, y1, x2, y2, zm(ii), .2, name );
end


%
% $Id: PIXMakePlane.m 21 2016-02-11 22:21:37Z  $
%
% $Log: PIXMakePlane.m,v $
% Revision 1.1  2016/02/11 22:13:44  stanley
% Initial revision
%
% Revision 1.1  2010/09/11 17:57:59  stanley
% Initial revision
%
%
%key pixel pixelDesign 
%comment  helper function, returns 4, flag to indicate interp enabled 
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

