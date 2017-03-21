function id = PIXCreatePackage( packageName, instrumentList, instrumentNames );

%  id = PIXCreatePackage( packageName, [instrumentList], [instrumentNames] );
%
%  PIXCreatePackage creates an instrument package, and optionally adds
%   the listed instruments to that package. It returns a package ID, which 
%   is used when building a pixel collection.
%
%  packageName is a string of less than 32 characters naming the package.
%  instrumentList is an array of instrument IDs to be included in this 
%     package. Instruments can be added to a package later. Packages with
%     no instruments are not very interesting.
%  instrumentNames is an array of 'local' instrument 
%     names to be assigned to the instrument. This name is how the pixels 
%     for that instrument will be retrieved from the stack. Notice in the
%     example the correct syntax for the array of names. 
%
%  instrument(Names|List) are optional. If both are not present, you will
%  have to add instruments to the package if you want anything to happen.
%
%  If you don't include the instrument names, the names assigned to the
%  instruments when they were created will be used.
%
% id = PIXCreatePackage( 'js 1', [1,2,3,4], {'js1', 'js2', 'js3', 'js4'} );
%

% where we keep things
global PIXInstruments;
global PIXPackages;
global PIXModified;

% get now
p.whenCreated = epochtime;

% handle optional args
if nargin == 3
	p.instrumentList = [instrumentList];
	p.instrumentNames = instrumentNames;
elseif nargin == 2
	% get names from instruments
	p.instrumentList = [instrumentList];
	p.instrumentNames = { PIXInstruments(instrumentList).name };
elseif nargin == 1
	p.instrumentList = [];
	p.instrumentNames = {};
else 
	error( 'Wrong number of arguments to PIXCreatePackage.');
end

% check for one name per instrument
if length(p.instrumentList) ~= length(p.instrumentNames)
	error('Must be as many names as instruments');
end

% save the name
p.name = packageName;

% get an id for this one.
if isempty( PIXPackages ) 
	id = 1;
else
	id = max([PIXPackages(:).id]) + 1; 
end;
p.id = id;

% check for instruments that don't exist.
[c,i] = setdiff( p.instrumentList, [PIXInstruments(:).id] );
if length(c)
	disp('The following instruments you want to use are not defined:');
	for j=1:i,
		disp( ['', num2str(p.instrumentList(j)), ...
			' Name: ' char(p.instrumentNames(j)) ] );
	end;
	error('Try again.');
end;

% ok, all done here. put in PIXPackages for later retrieval
if isempty(PIXPackages)
	PIXPackages = p;
else
	PIXPackages(length(PIXPackages)+1) = p;
end;

% bye!
PIXModified = 1;

% 

%
% $Id: PIXCreatePackage.m 21 2016-02-11 22:21:37Z  $
%
% $Log: PIXCreatePackage.m,v $
% Revision 1.4  2016/02/11 22:16:53  stanley
% fix array issue in getting id
%
% Revision 1.3  1904/03/26 11:20:02  stanley
% auto insert keywords
%
%
%key pixel pixelDesign 
%comment  Creates or appends to a package of instruments 
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

