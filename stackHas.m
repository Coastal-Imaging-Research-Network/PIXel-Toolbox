function insts = stackHas( fn, what )

%  function insts = stackHas( fn, what );
%
%   Return information about the stacks listed in 'fn'.
%
%   'fn' is an array of names of stack files, either a cell array
%   of strings or an array of chars as returned by findArgusImages.
%
%   'what', if present, is a string containing either a type or name
%   of an instrument to test for. 
%
%   'insts' is an array of structs with the stack and R info for
%   instrument types and names in that stack. If 'what' is provided,
%   each 'insts' struct contains a member named 'matches' that is 1
%   if that type or name is in the stack, 0 otherwise.
%
%   To convert 'insts' into a cell array of stack names that have the 
%   'what' instrument:
%
%      extractFileName = { insts([insts(:).matches]==1).name };
%
%   This function makes heavy use of the 'stack' and 'R' database
%   tables.

% figure out what we got input
numF = -1;

if ischar(fn) 
	numF = size(fn,1);
end
if iscell(fn) 
	if size(fn,1) == 1
		fn = fn';
	end
	numF = size(fn,1);
end

if numF < 0
	error('invalid input type');
end
if numF < 1
	error('no input files!');
end

% for each input file
for ii = 1:numF

	me = char(fn(ii,:));

	mepfn = parseFilename( me );
	stInfo = DBGetTableEntry('stack', ...
			'station', mepfn.station, ...
			'camNum', mepfn.camera, ...
			'epoch', mepfn.time );

	if ~isempty(stInfo)
		instInfo = DBGetTableEntry('R', ...
			'station', mepfn.station, ...
			'epoch', stInfo.aoiEpoch, ...
			'camNum', mepfn.camera );
	else
		instInfo = [];
	end

	aa.stackInfo = stInfo;
	aa.instInfo = instInfo;
	aa.name = me;
	
	tinsts(ii) = aa;

end

if nargin < 2
	insts = tinsts;
	return;
end

for ii = 1:length(tinsts)

	tinsts(ii).matches = 0;

	% look for 'what' in names and types.
	all = [ tinsts(ii).instInfo.names tinsts(ii).instInfo.types ];
	while( 1 )

		[xxthis,all] = strtok(all,';');

		if isempty(xxthis) break; end;

		if( strcmp( xxthis, what ) )
			tinsts(ii).matches = 1;
			break;
		end
	end
end

insts = tinsts;






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

