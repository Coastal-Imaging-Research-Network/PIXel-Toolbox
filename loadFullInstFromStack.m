function [allUV, names, xyz, cam, epoch, data, err, rawxyz, stats] = ...
    loadFullInstFromStack(stackNames, r, instTypeStr, instNameStr)

%
%   [allUV, names, xyz, cam, epoch, data, err, rawxyz] = ...
%       loadFullInstFromStack(stackNames, r, instTypeStr, instNameStr)
%
% Routine to load all instruments of type 'instTypeStr' from
% a set of synchronous stacks with names stacknames, and parameters
% ps and r.  This routine would typically follow a call
% call to loadAllStackInfo, with inputs based on that call
% (see examples).  All data of the particular type are returned.
%
%  if the instNameStr is provided, then those instruments with the
%  specified name will be returned.
%
%  Inputs:
%   stackNames  - array of (usually 2) associated stacks
%   r           - r parameter from the collect - only one
%   instTypeStr - instrument type, e.g., 'matrix'
%   instNameStr - instrument name, e.g., 'mBW'
%  Output:
%   allUV       - Nx2 array of UVs, cat-ed
%   names       - Nx1 vector of specific instrument names
%   xyz         - Nx3 array of pixel locations
%   cam         - Nx1 vector indicating which camera pixel came from
%   epoch       - times for stack for each cam - NtxNcams
%   data        - stack data - NxNt array, packed in order of Names
%   err         - error code
%   rawxyz      - raw xyz data (not back-calculated)
%   stats       - stats from stackStats, after call to fixStack
%
%  fixStack! Warning: this function calls a function called fixStack.
%  fixStack examines the epoch times for each stack and tries to reconcile
%  errors such as unequal start times, dropped or missed frames, differing
%  sample periods, or time errors (error in reading firewire cycle time).
%  It does this by creating an array of canonical epoch times for each line
%  and interpolating the data to that time. 
%  
%  As part of the process, the data you get may NOT be the same number of
%  samples or run the full time as the raw data. Do NOT assume that a stack
%  with 2048 samples in the raw stack file will return 2048 samples after
%  being fixed. 
%
%  If you DO NOT want this corrective action applied to your data, set the
%  global variable NOFIXSTACK to 1. 
%
%  ALSO: there are times when there are multiple errors in the time. Most
%  notably, a failed cycle time reading combined with a dropped frame (or
%  more). This failure will result in no data returned, unless you set
%  either NOFIXSTACK (so no fixing at all takes place) or IGNORECYCLEFAIL
%  (which will ignore the cycle fail/drop combo and return a best guess.
%
%  stats is the returned epoch time statistics from the function
%  stackStats.

global NOFIXSTACK;
global IGNORECYCLEFAIL;

errStr = []; err = 0;
sn = stackNames;
UV = []; rawUV = []; xyz = []; bNames = []; errCode = [];
whichCam = []; data = []; allUV = []; etime = []; rawxyz = [];
bathyInsts = strmatch(lower(instTypeStr), lower(r.types), 'exact');
xyz = []; names = [];
if any(bathyInsts)    % at least one bathy inst.
    for cam = 1: length(stackNames)  % get all from each stack at once
        pn = parseFilename( stackNames{cam} );
        bathyNames = r.names(bathyInsts);
        uniqueNames = unique(bathyNames);
        if( nargin == 4 )   % passed in a single name, please
            if( isempty( strmatch( instNameStr, uniqueNames, 'exact' )) )
                continue;   % no inst with that name here.
            end;
            uniqueNames = {instNameStr};
        end;
        UV = [];
        myXYZ = [];
        myRawXYZ = [];
        bNames = [];
        % get all the UV/xyz for all the names  in THIS file
        % not the raw xyz, the processed (which is also uniqueOnly
        % processed.
        for j = 1: length(uniqueNames)
            [foo1, foo2, foo4, foo3] = PIXFindUVByName(pn.camera, r, uniqueNames(j));
            UV = [UV; foo1];
            bNames = [bNames; repmat(uniqueNames(j), size(foo1,1),1)];
            myXYZ = [myXYZ; foo3];
            myRawXYZ = [myRawXYZ; foo4];
        end
        
	% fix problem of no instruments in THIS stack file, but there
	% are in the main set of stacks.
	if( isempty(UV) )
		continue;
	end
        [foo, epoch, msc, temp] = loadStack(char(sn(cam)), UV);
        % Danger. loadStack may flag bogus UV! Must clean up
        % foo.order == -1 for bad columns
        good = find(foo.order > 0);
        UV = UV(good,:);
        xyz = [xyz myXYZ(good,:)'];
        rawxyz = [rawxyz myRawXYZ(good,:)'];
        names = [names bNames(good)'];
        
        %% this is handled by fixStack later
        % now we worry about time difference -- late starts
        % there should be no more than 1/2 delta difference
        % but I can only do this if I already have data.
%         if ~isempty(etime)
%             tdiff = mean(diff(etime(:,1)));
%             offset = 0;
%             % is there a problem?
%             if (abs(etime(1,1)-epoch(1)) > tdiff/2)
%                 % more than half a tick early
%                 if(etime(1,1)-epoch(1) > 0)
%                     
%                     offset = floor((etime(1,1)-epoch(1)+tdiff/2)/tdiff) + 1;
%                     % this stack starts earlier, copy from offset, duplicate
%                     % end
%                     ndata = temp(offset:end,:);
%                     ndata = [ndata; temp(end-offset+2:end,:)];
%                     temp = ndata;
%                     epoch = etime(:,1)';
%                 else % more than half a tick late
%                     offset = floor((epoch(1)-etime(1,1)+tdiff/2)/tdiff) + 1;
%                     % this stack starts later, duplicate start, copy from end
%                     ndata = temp(1:offset-1,:);
%                     ndata = [ndata; temp(1:end-offset+1,:)];
%                     temp = ndata;
%                     epoch = etime(:,1)';
%                 end
%                 if offset > 0
%                     warning( ['Epoch offset ' num2str(offset-1) ' samples in ' sn{cam} ]);
%                 end
%             end
%         end
%         
        try
            data = [data temp(:,good)];
            etime = [etime epoch'];
        catch ME
            warning(['failed with file names ' sn{1} ]);
            rethrow(ME);
        end
        whichCam = [whichCam; repmat(pn.camera, size(UV,1),1)];
        allUV = [allUV; UV];
        
    end
else    % not bathy instruments - error code
    errStr = [errStr ' No bathy Instruments in Stack.'];
    errCode = 5;
end

xyz = xyz';
rawxyz = rawxyz';
cam = whichCam;
epoch = etime;
err = errCode;

if isempty(epoch)
    return;
end

% one last check -- time failures in stack collection. did they all start
% at the same time? if fixing, this error will be fixed later
if NOFIXSTACK
    pixTimeEps = 0.25;
    pixTimeEps = mean(diff(etime(:,1)))/2;
    pixTimeDiff = max(diff(etime(1,:)));
    if( pixTimeDiff > pixTimeEps )
        err = -1;
        warning('PIXEL:TimeError', ...
            ['Epoch start times differ ', num2str(pixTimeDiff), ' > ', num2str( pixTimeEps ), ' secs'] );
    end
    
    stats = [];
    return;
end

se = size(epoch,2);
[epoch, data, opts] = PIXfixStack( epoch, data, cam );
epoch = repmat( epoch, 1, se );
stats = opts.stats;

if( IGNORECYCLEFAIL == 1 )
    return;
end

if( max([opts.failedCycle(:)]) == 1 )
    allUV = [];
    names = [];
    xyz = [];
    cam = [];
    epoch = [];
    data = [];
    err = 'failed cycle time fix';
    rawxyz = [];
end


%
% $Id: loadFullInstFromStack.m 21 2016-02-11 22:21:37Z  $
%
% $Log: loadFullInstFromStack.m,v $
% Revision 1.7  2015/02/24 22:28:01  stanley
% moved pixTimeEps error test inside test for NOFIXSTACK
%
% Revision 1.6  2014/11/04 23:11:01  stanley
% added fixstack call, removed internal fixes
%
% Revision 1.5  2012/10/26 21:18:28  stanley
% add warning about time problems
%
% Revision 1.4  2011/04/15 21:55:08  stanley
% add test for instNAME as input 4
%
% Revision 1.3  2011/03/04 00:46:31  stanley
% removed references to 'ps', added 'instNameStr' and related
%
% Revision 1.2  2010/02/25 20:52:01  stanley
% fix to ignore bad UV from hotm bug
%
% Revision 1.1  2004/08/19 21:54:55  stanley
% Initial revision
%
%
%key bathy pixelExtract
%comment  Uses data on sibling stacks to load pixel insts
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

