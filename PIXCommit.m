function PIXCommit()

% PIXCommit();
%
%  Commit changes to the pixel database for the station in use.
%  This is what writes the data to the disk.
%
%  IF YOU DO NOT CALL THIS FUNCTION BEFORE YOU EXIT MATLAB, YOUR 
%  CAREFULLY CRAFTED EXPERIMENT PACKAGES AND PIXEL INSTRUMENTS GO
%  POOF!
%
%  See also PIXForget.

global PIXPackages;
global PIXInstruments;
global PIXCoords;
global PIXStation;
global PIXModified;

% figure out where to save
PIXPath = strrep( which('PIXDatabase'), 'PIXDatabase.m', '' );
file = [PIXPath filesep 'data' filesep 'PIX' PIXStation '.mat'];

save( file, 'PIXPackages', 'PIXInstruments', 'PIXCoords', 'PIXStation');

PIXModified = 0;

% 

%
% $Id: PIXCommit.m 21 2016-02-11 22:21:37Z  $
%
% $Log: PIXCommit.m,v $
% Revision 1.3  1904/03/26 11:20:01  stanley
% auto insert keywords
%
%
%key pixel pixelDesign 
%comment  Save current instrumnets in database (sort of) 
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

