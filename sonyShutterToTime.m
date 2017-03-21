function t = sonyShutterToTime( s, c )

% sonyShutterToTime -- convert shutter values for sony cams to time.
%
%  t = sonyShutterToTime( shutter, camera ) returns integration time
%  in seconds corresponding to the digital shutter values for the camera
%  specified as either an argusDB camera struct or by the string. I.e.
%  camera is a struct with member "modelID" of DX700 or SX900, or the
%  string 'DX700' or 'SX900'.

if( isstruct(c) ) 
	type = c.modelID;
elseif (ischar(c))
	type = c;
else
	error('unknown input for camera');
end;

% do DX700 first

t = zeros(size(s));

if( strcmp(type, 'DX700') )

	xx = find(s==2047);
	t(xx) = 1/15;

	xx = find(s>2047);
	t(xx) = (2848.4-s(xx)) / 11962.0;

	xx = find(s<2047);
	t(xx) = (2048-s(xx)) / 15;

	xx = find(s==2848);
	t(xx) = 1/20000;

elseif (strcmp(type, 'SX900' ) )

	xx = find(s==2047);
	t(xx) = 1/7.5;

	xx = find(s>2047);
	t(xx) = (3116.4-s(xx))/7999.0;

	xx = find(s<2047);
	t(xx) = (2048-s(xx))/7.5;

	xx = find(s==3116);
	t(xx) = 1/10000;

	xx = find(s==3117);
	t(xx) = 1/20000;

else

	error( ['unknown camera ' type] );

end

return;

%
% $Id: sonyShutterToTime.m 21 2016-02-11 22:21:37Z  $
%
% $Log: sonyShutterToTime.m,v $
% Revision 1.1  2004/08/18 01:00:28  stanley
% Initial revision
%
%
%key pixelExtract 
%comment  Convert shutter values for sony cams to time  
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

