function [p, epoch, MSC, data] = loadStack( filename, UV );

% loadStack -- load the data from a stack file
% 
%   [PARAMS, EPOCH, MSC, DATA] = loadStack( FILENAME ) returns
%   the epoch time, media stream counter (MSC), the parameters,
%   and the data, from the stack contained in the specified
%   file. The epoch time is the time each line was sampled, to
%   the millisecond. MSC is the frame counter for the line,
%   and params is a struct with lots of good info about the stack.
%   DATA is the array of pixel data: DATA(1,9) is the 9th UV, sample
%   1.
%
%   IN ARGUS 3 stacks -- modern ones -- the MSC has been replaced with
%   an Nx2 array of gain and shutter times. The first column is gain,
%   the second is shutter (integration) time. If the stack has been
%   collected with NoAutoOnCollect or NoAutoOnStack flags (which aren't
%   recorded in the stack but are internal to the collection code) those
%   numbers won't change during a stack collection.
%
%   FILNAME is either the full (or relative) path to the file (which
%   Matlab will be able to open directly), or it is the name of a stack
%   in the argus data directory (which can be expanded using FTPpath).
%   If you are reading compressed files, be watchful of your space in 
%   /tmp. 
% 
%   loadStack( FILENAME, UV ) returns the data corresponding to the UV
%   coordinates in the 2xN or Nx2 array UV, in the same order as the UV 
%   array.
%
%   PARAMS = loadStack( FILENAME, 'info' ) returns just the parameters
%   for the stack. This is how you can determine what UV are there before 
%   trying to load ones that aren't. 
%
%   Nota bene: loading an entire stack can be VERY slow. It is good
%   to know which UV coords you want to load. But it ain't as slow
%   as it used to be, 'cause I sped it up alot. How? Magic. Cache.
%
%   loadStack('', 'clearCache') clears the data cache that is used
%   to speed things up a lot. You probably will never need it.
%
%   If you specify a U and V that is not in the stack, you will get
%   a warning, but you will also get the data for the other UV you
%   got right. PARAMS.U(PARAMS.order) will give you the list of U's
%   corresponding to the data you got back. Similar V.
%
%   Further note: did I already say that loading an entire stack can 
%   be VERY slow?  Well, it ain't so bad no more.
%
%   A note about color: loading a color stack will result in a data array
%   that is three times the size you expect. The color data is interleaved
%   with the intensity data. Y, Cb, Cr, Y, Cb, Cr, ... So, for example, the
%   indices of the Y data will be 1:3:length(data), the Cb will be
%   2:3:length(data). Cr is left as an exercise to the reader.
%
%   Further note about color: old versions of 'm' didn't set the color
%   flag properly in at least one case, probably more. I'm now checking
%   for triplicate UVs that indicate color to set the inColor flag in
%   those cases.
%
%   Another further note about "color": ArgusIII uses raw images from
%   the cameras to produce stacks. Raw images are Bayer-encoded! It's
%   faster that way, and has no effect on time-series. However, if you
%   are trying to compare two pixels in the same frame, as in a wave
%   direction array, it's bogus. For THOSE stacks, a flag has been set
%   in the collection to cause a four-pixel nearest neighbor deBayering
%   to produce the intensity (only intensity, not full color) pixel.
%   This flag is recorded in the stack by setting isColor to 2. 
%
%   Because the process can be VERY slow, there are many display commands
%   to tell you the progress in loading.

% This is the top level. It uses the cached copy of the stack if
%  possible. It turns out many people make many sequential calls
%   to loadStack for the same file, so caching should be helpful.

% place to keep cache. be a struct.
global lsCache;		% the data
global lsCachedFile; 	% the name of the file

if nargin == 2
	allData = 0;
	if ischar(UV)
		% all I want is info, or to clear cache
	elseif size(UV,1) ~= 2
		if size(UV,2) ~= 2
			error( 'Wrong dimension on UV array, must be 2xN or Nx2' );
		end;
		UV = UV';
	end
else
	allData = 1;
	UV = [];
end

% if all I want is to clear the cache.
if ischar(UV) & strcmp(UV,'clearCache')
	clear lsCache;
	lsCachedFile = '';
	return;
end;

% if all I ask for is 'p', set 'info' flag
if nargout == 1
	UV = 'info';
end

% look for a cache 'hit'
if ~strcmp(filename, lsCachedFile)
	[lsCache.p, lsCache.epoch, lsCache.MSC, lsCache.data] = ...
		loadStackFile( filename );
	lsCachedFile = filename;
	% get camera data for width, height
	lsCache.cam = DBGetCameraByImage( filename );
	% if no cam data found, assume umax and vmax are for Scorpion 
	if isempty(lsCache.cam) 
		lsCache.umax = 1280; lsCache.vmax = 960;
	else
		% look for IP data for width and height
		ip = DBGetTableEntry('IP','id', lsCache.cam.IPID );
		lsCache.umax = ip.width; lsCache.vmax = ip.height;
	end
end;

% p is used by lots later
p = lsCache.p;

% test consistency of epoch -- no missing 

% if all I want is the info from the stack, here we are.
if ischar(UV) & strcmp(UV,'info')
	return;
end;

% set up for invalid/missing pixel requests
baddies = [];
umax = lsCache.umax; vmax = lsCache.vmax;

% figure out from p.U/p.V and UV which columns of data and what order to return.
if allData == 0
	% order = []; % ooooh so slow one at a time. change to preallocate
    if p.isColor == 1 % color has 3x the data
        order = zeros( 1, 3 * size(UV,2) );
    else
        order = zeros( 1, size(UV,2) );
    end
    optr = 1; % pointer into order array, need because of color
	oob = 0; nf = 0; % out-of-borders, not found counters
	for j = 1:size(UV,2)
		myU = UV(1,j);
		myV = UV(2,j);
		% check for out of bounds
		if( myU < 1 || myU > umax || myV < 1 || myV > vmax )
			baddies = [baddies j];
			%%order = [order 1]; % placeholder % don't need in prealloc
            optr = optr+ 1;
			oob = oob + 1;
			continue;
		end;
		% now check existance and find column
		x = find(p.U == myU & p.V == myV);
		if isempty(x)
			% not found! stupid user!
			baddies = [baddies j];
			%%order = [order 1];  % still placeholder
            optr = optr + 1;
			nf = nf + 1;
		else
			if p.isColor == 1
				%order = [order min(x(1:end/3))];
				%order = [order min(x(end/3+1:2*end/3))];
				%order = [order min(x(2*end/3+1:end))];
				order(optr) = min(x(1:end/3)); optr = optr + 1;
				order(optr) = min(x(end/3+1:2*end/3)); optr = optr + 1;
				order(optr) = min(x(2*end/3+1:end)); optr = optr + 1;
			else
				order(optr) = x(1); optr = optr + 1;
			end;
		end;
	end
	p.order = order(1:optr-1)';
	if ~isempty(baddies) 
		p.order(baddies) = -1;
	end
else
	order = 1:length(p.U);
	p.order = order';
end

epoch = lsCache.epoch;
MSC   = lsCache.MSC; 

% have to create a temp order without -1 flags ...
ptemp = p.order;
ptemp(ptemp<0) = 1;
data  = lsCache.data(:,ptemp);
if ~isempty( baddies ) 
	data(:,baddies) = 0;
	warning(['Errors in UV request to loadStack: %d out-of-bounds, ' ...
		 '%d not found.\nMissing data flagged as -1 in p.order.\nUse ' ...
		 'PIXCleanup to clean up data.'], ...
		 oob, nf );
end;

% 

%
% $Id: loadStack.m 21 2016-02-11 22:21:37Z  $
%
% $Log: loadStack.m,v $
% Revision 1.8  2016/02/11 22:06:24  stanley
% changed "order" processing
%
% Revision 1.7  2010/02/25 20:51:16  stanley
% fix for bug in hotm, invalid UV
%
% Revision 1.6  2008/07/22 18:18:55  stanley
% added gain/shutter help
%
% Revision 1.5  1904/08/17 16:33:45  stanley
% change to cached version
%
%
%key pixelExtract 
%comment  Load a stack or its coillections parameters 
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

