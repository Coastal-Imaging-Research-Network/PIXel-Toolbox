function [ fixedEpoch, fixedData, optsOut ] = PIXfixStack( epoch, data, cam, opts )

% function [ fixedEpoch, fixedData, optsOut ] = ...
%                   PIXfixStack( epoch, data, cam, opts )
%
%   deal with timing issues in a stack collection. Sigh.
%
%   Input: 
%       epoch     -- array of epoch data, one column per camera
%       data      -- raw data
%       cam       -- array relating camera to column of data and epoch
%       opts      -- optional structure of options that has fields:
%           interval  -- correct sampling interval
%           method    -- optional method specifier, used by interp1
%                    'linear' -- create fixedEpoch and interpolate columns
%                    'nearest'   -- fill in missing times with next data
%                    'spline'  -- spline 
%
%  Output:
%       fixedEpoch -- epoch (Nx1) times all data are corrected to.
%       fixedData  -- data, fixed. 
%       optsOut    -- output structure with the same fields as 'opts'
%
%  Default interval will be 0.5s if the input 'looks like' 2Hz, otherwise
%  it will be a cleaned mean diff(e). 
%
%  method will default to 'linear'.
%

%% process inputs

method = 'linear';
interval = -1;
doStats = 0;

if nargin > 3
    
    if isfield(opts,'method')
        method = opts.method;
    end
    if isfield(opts,'doStats')
        doStats = 1;
    end
    if isfield(opts,'interval')
        interval = opts.interval;
    end
    
end

% I'm going to use the fabulous stackStats function to calculate
% my guess at the interval. also detect multiple interval stacks (duck when
% collections changed camera rate for another stack at 15 min)
stats = PIXstackStats(epoch);

% now my best guess at desired interval is to mean the calculated
% ones and then heuristically select 0.5 if that's close enough
mi = mean(stats.interval);

% if the mean interval using close points is about 0.5, use that
if( abs( mi - 0.5 ) < .05 )
    mi = 0.5;
end

if interval <  0
    interval = mi;
end

optsOut.method = method;
optsOut.interval = interval;

%% ok, now I can create the fixedEpoch
%  need only an Nx1, all cameras are the same
%  must determine how long the records are, in time. Here's the rule.
%  IF the record is short in time, assume it is because the sample interval
%  changed to something shorter during the collection. That's bad, but it
%  happened at Duck alot. IF the record is LONG in time, assume there were
%  dropped frames and the actual length should be the number of samples
%  times the interval.

% this is the longest in time possible "real" sampling
ti = 0:length(epoch(:,1))-1;
ti = ti * interval;

% find most common starting time, nearest millisecond
startEpoch = mode(round(1000*(epoch(1,:)))/1000);
optsOut.startEpoch = startEpoch;

fixedEpoch = ti' + startEpoch;  % rotate to standard CIL use

% but now, deal with short sampling periods
if( fixedEpoch(end) - min(epoch(end,:)) > 2*interval )
    eind = find(fixedEpoch <= min(epoch(end,:)));
    fixedEpoch = fixedEpoch(eind);
end

%% split data out by camera

% array of camera numbers. I need them in same order as in epoch
% because corrections are based on each camera's epoch.
[cams,ii] = unique(cam);
cams = cam(sort(ii));

%% and now create the fixed data. which method?

fixedData = zeros(length(fixedEpoch),length(cam));

for ii = 1:length(cams)
    cols = find(cam==cams(ii));
    x = epoch(:,ii);
    if( stats.multiInterval(ii)>0 ...
            & stats.longInts5(ii,1)>stats.interval(ii)*1.1 )
        disp( ['cannot properly fix stack at epoch ' ...
            num2str(x(1)) ...
            ' for camera ' num2str(cams(ii)) ...
            ' due to dropped frames and multi-interval collection'] );
    end
    [x,optsOut.neededCycle(ii),optsOut.failedCycle(ii)] ...
        = PIXcleanCycleTime(x, stats.interval(ii) );
    y = double(data(:,cols));
    yi = interp1( x, y, fixedEpoch, method );
    fixedData(:,cols) = yi;
end

%% remove NaNs -- if any
if(find(isnan(fixedData)))
    
    optsOut.hadNaNs = 1;
    for ii=1:length(cam)
        ns = find(isnan(fixedData(1:200,ii)));
        if ~isempty(ns)
        fixedData(ns,ii) = fixedData(max(ns)+1,ii);
        end
        
        limit = size(fixedData,1)-200;
        ns = find(isnan(fixedData(limit+1:end,ii)));
        if ~isempty(ns)
        fixedData(limit+ns,ii) = fixedData(limit+min(ns)-1,ii);
        end
    end
    
end
        
        
 
%% last bit -- stats on stuff
optsOut.stats = PIXstackStats( epoch, fixedEpoch );

% $Id: PIXfixStack.m 21 2016-02-11 22:21:37Z  $


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

