function PIXSetStation( station )

% PIXSetStation( station )
%
%  select the station at which to create pixel arrays and such
%
%  IT IS AN ERROR TO CALL THIS FUNCTION TO CHANGE STATIONS IF YOU
%  HAVE MODIFIED INFORMATION AT ANOTHER STATION! You must call PIXCommit
%  or PIXForget prior to calling PIXStation if you have created
%  packages, instruments or modified instruments.

global PIXPackages;
global PIXInstruments;
global PIXCoords;
global PIXStation;
global PIXModified;

if (~isempty(PIXStation) & PIXModified)
	error(['Station ' PIXStation ' has modified data! PIXCommit or PIXForget']);
end;

PIXPath = strrep( which('PIXDatabase'), 'PIXDatabase.m', '' );
newstation = [PIXPath filesep 'data' filesep 'PIX' station '.mat'];

try
	s = load(newstation);
	PIXPackages = s.PIXPackages;
	PIXInstruments = s.PIXInstruments;
	PIXCoords = s.PIXCoords;
	PIXStation = s.PIXStation;
catch
	PIXPackages = [];
	PIXInstruments = [];
	PIXCoords = [];
	PIXStation = station;
end;

PIXModified = 0;

% 

%
% $Id: PIXSetStation.m 21 2016-02-11 22:21:37Z  $
%
% $Log: PIXSetStation.m,v $
% Revision 1.4  1904/03/26 11:20:05  stanley
% auto insert keywords
%
%
%key pixel pixelDesign 
%comment  Select the station at which to create pixel arrays and such  
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

