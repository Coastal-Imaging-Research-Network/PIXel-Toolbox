function outdata = PIXInterp( data, rawUV )

% PIXInterp -- convert stack data taken with interpolation on
%		(i.e. four pixels collected surrounding the real
%               UV coords) into one data point per raw UV pair.
%
%  OUTDATA = PIXInterp( DATA, RAWUV ) converts the stack data
%  in DATA into one point per RAWUV coordinate. DATA is data in 
%  the format from loadStack( ..., UV ). RAWUV are the return 
%  values from PIXFindUVByName. 
%

% assumptions: UV is 4 times the size of RAWUV. UV is "appended" 
% list as built by PIXBuildCollect in interp mode. I.e., If RAWUV
% has four UV's, UV is 2x16, and UV(:,[1 5 9 13]) are all UVs used
% to create one output data point. Also, DATA([1 5 9 13],:) are
% the columns to average together.
%
%  actually, UV is not required. I know how to interp from RAWUV
%  to create UV. All I need to know is that DATA(:,[1 5 9 13])
%  corresponds to RAWUV(:,1);

if size(rawUV,1) ~= 2
	if size(rawUV,2) ~= 2
		error( 'Bad dimensions on RAWUV' );
	end
	rawUV = rawUV';
end

% make sure it's in right size
data = double(data);

S = rawUV(1,:) + .5; S = S - fix(S);
T = rawUV(2,:) + .5; T = T - fix(T);

S = repmat( S, size(data,1), 1);
T = repmat( T, size(data,1), 1);

nUV = size(rawUV,2);

outdata = T .* ( (1-S) .* data(:,1:nUV) + S .* data(:,1+2*nUV:3*nUV) ) ...
    + (1-T) .* ( (1-S) .* data(:,1+nUV:2*nUV) + S .* data(:,1+3*nUV:4*nUV) );

% 

%
% $Id: PIXInterp.m 21 2016-02-11 22:21:37Z  $
%
% $Log: PIXInterp.m,v $
% Revision 1.3  2004/09/02 18:40:43  stanley
% make sure input is double
%
% Revision 1.2  1904/03/26 11:20:04  stanley
% auto insert keywords
%
%
%key pixel pixelExtract 
%comment  Interpolates bracketing pixels to rawUV locations 
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

