function PIXInsertRintoDB(  newR )

%  function PIXInsertRintoDB( R )
%   insert the relevant bits of the 'r' struct for pixel collections into the
%    database so other things can look them up quickly.
%
%   make sure you log into the database with a writing-able account
%

if( isa( newR, 'char' ) )
	load(newR);
	newR = r;
	clear r;
end

r.epoch = newR.epoch;
r.station = newR.station;

for j = 1:length(newR.cams)

	nr = newR.cams(j);
	r.camNum = nr.cameraNumber;
	r.names = ''; 
	un = unique(nr.names);
	for i=1:length(un)
		r.names = [r.names un{i} ';' ];
	end
	r.types = '';
	try
		un = unique(nr.types);
		for i=1:length(un)
			r.types = [r.types un{i} ';'];
		end
	catch
	end

	if(( length(r.types)+length(r.names)) > 0 )
		xr = DBGetTableEntry('R', 'epoch', r.epoch, 'station', r.station, 'camNum', r.camNum );
		if( ~isempty(xr) )
			warning('already there!');
		else
			r.seq = DBGetSequence('R');
			r
			DBInsert( 'R', r );
		end
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

