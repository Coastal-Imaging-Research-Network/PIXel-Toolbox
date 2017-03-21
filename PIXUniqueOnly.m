function val = PIXUniqueOnly()

% helper function, returns 16, which is flag to indicate we should use
% unique pixels only and recalc XYZ for each one used. I.e., a line 
% of pixels or a patch.
%
%   NOTE: this value has changed, since the mechanism for accomplishing
%   it has changed. Old value is 16. Old means was to sort in XY and uniq
%   in XY. New value 32, unique is done on PIXFindUVByName -- after
%   collection is over. This allows keeping the same XY order but with
%   unique XY.
%

val = 32;

% 

%
% $Id: PIXUniqueOnly.m 21 2016-02-11 22:21:37Z  $
%
% $Log: PIXUniqueOnly.m,v $
% Revision 1.2  2012/01/31 00:12:50  stanley
% changed value, changed mechanism for action elsewhere
%
% Revision 1.1  2011/04/15 22:00:21  stanley
% Initial revision
%
%
%key pixel pixelDesign 
%comment  helper function, returns 16, flag to indicate unique 
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

