function PIXAddInstrument( pid, instrumentList, instrumentNames );

% PIXAddInstrument -- add instrument(s) to a package.
%
%   PIXAddInstrument( packageID, [instrumentList], [instrumentNames] ); adds the
%   instruments in the list with the specified names to the package specified by
%   packageID.
%
%  PIXAddInstrument( pid, [1,2,3,4], {'js1', 'js2', 'js3', 'js4'} );
%

% where we keep things
global PIXInstruments;
global PIXPackages;
global PIXModified;

if pid > length(PIXPackages)
	error('That package does not exist');
end

p = PIXPackages(pid);

if (nargin == 2)
	instrumentNames = { PIXInstruments(instrumentList).name };
end

% check for one name per instrument
if length(instrumentList) ~= length(instrumentNames)
	error('Must be as many names as instruments');
end

% check for instruments that don't exist.
[c,i] = setdiff( instrumentList, [PIXInstruments(:).id] );
if length(c)
	disp('The following instruments you want to use are not defined:');
	for j=1:i,
		disp( ['', num2str(instrumentList(j)), ...
			' Name: ' char(instrumentNames{j}) ] );
	end;
	error('Try again.');
end;

p.instrumentList = [p.instrumentList instrumentList];
nl = length(p.instrumentNames);
p.instrumentNames(nl+1:nl+length(instrumentList)) ...
	 = instrumentNames;

% ok, all done here. put in PIXPackages for later retrieval
PIXPackages(pid) = p;

% bye!
PIXModified = 1;

% 

%
% $Id: PIXAddInstrument.m 21 2016-02-11 22:21:37Z  $
%
% $Log: PIXAddInstrument.m,v $
% Revision 1.2  1904/03/26 11:20:00  stanley
% auto insert keywords
%
%
%key pixel pixelDesign 
%comment  Adds an instrument to a package    
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

