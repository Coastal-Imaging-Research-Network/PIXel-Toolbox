function [x,y,z] = PIXExpandCoord( c )

% [x,y,z] = PIXExpandCoord( c )
%
%  expand the coord struct 'c' into an x and y and z arrays. I.e., a line gets
%  converted into the x,y, coords for the line, a point returns just x,y.

if (c.dx == 0) & (c.dy == 0)

	% simple -- a point
	x = c.x1; y = c.y1; z = c.z;

elseif (c.dy == 0)

	% simple -- a line
	% find total length
	lx = ((c.x2-c.x1)^2 + (c.y2-c.y1)^2) ^ .5;
	% find each contribution from dx to y and x
	dx = (c.x2-c.x1) * c.dx/lx;
	dy = (c.y2-c.y1) * c.dx/lx;
	% now assign data
	xs = c.x1; ys = c.y1;
	x = []; y = [];
	for ii = 0:c.dx:lx,
		x=[x xs]; xs = xs + dx;
		y=[y ys]; ys = ys + dy;
	end

	z = c.z .* ones( 1, length(x) );

elseif ( c.dx == 0 )

	% should not get here! 
	error('coords failure! no x dimension on box!');

else

	% build a matrix!
	% oops, watch for inverted directions!
	if c.y2 < c.y1
		t = c.y1; c.y1 = c.y2; c.y2 = t;
	end;
	if c.x2 < c.x1
		t = c.x1; c.x1 = c.x2; c.x2 = t;
	end;

	[x,y] = meshgrid( c.x1:c.dx:c.x2, c.y1:c.dy:c.y2 );
	x = x(:)'; y = y(:)';

	z = c.z .* ones( size(x) );

end;

% 

%
% $Id: PIXExpandCoord.m 21 2016-02-11 22:21:37Z  $
%
% $Log: PIXExpandCoord.m,v $
% Revision 1.4  2016/02/11 22:10:56  stanley
% allow Nx1 array of z
%
% Revision 1.3  1904/03/26 11:20:02  stanley
% auto insert keywords
%
%
%key internal pixel pixelDesign 
%comment  Expand the coord struct 'c' into an x & y & z arrays 
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

