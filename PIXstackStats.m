function stats = PIXstackStats( epoch, fe )

% function stats = PIXstackStats( sampledEpoch, canonicalEpoch )
%
%   where 'sampledEpoch' is the epoch times from the stack collection
%            of NxM, where N is the number of samples and M is the number
%            of stacks.
%         'canonicalEpoch' is the optional 'correct' epoch time of
%            Nx1.
%
%   and 'stats' is a struct with statistics about the epoch times with
%   the following fields:
%
%   multiInterval: a 1xM array indicating there was a change of interval.
%           0 if no change, otherwise it will be the detected second interval
%   noCanonical: a 0/1 flag indicating whether a canonicalEpoch was provided
%   intervalStd: 5% of the reported interval
%   longInts5: an Mx5 array of the five longest detected intervals, one
%      row per stack. 
%   longInts5When: an array associated with longInts5 that records when
%      the long interval occured.
%   shortInts5: same as longInts5, except the five minimum intervals
%   shortInts5When: epoch time when those shorts occured
%   overrun: how much "too long" was the stack. requires a canonical epoch.
%   intervalError: how far away from the true interval (canonical) was the
%      interval I calculate.
%   numLong: a 1xM array of how many intervals exceeded two standard 
%      deviations from the calculated interval
%   numShort: same, except short by that much.
%   interval: 1xM calculated interval for each stack.
%   startDelay: assuming the first stack to start is correct, how late did
%      each stack start. 
%   startError: how late did each stack start compared to the canonical epoch
%      times. Zero if noCanonical.
%   endError: duplicate of overrun. Sigh.
%   epochs: copy of the incoming epoch data for later study.
% 

%
%

% find "canonical interval", if we can
if nargin == 2
    feint = mean(diff(fe));
else
    feint = -1;  % flag that says we don't have it.
end

% swap epochs into the col/row shape I want 
% we have two different versions -- one from loadStack (1xN)
% and one from the .mat files (NxM) where M is the number of stacks
%  in the data. M << N in that case, so we can tell
[N,M] = size(epoch);
if N<M 
    epoch = epoch';
end

% per camera stats first

for ii = 1:length(epoch(1,:))
    
    % per camera interval
    [pcint,pcstd] = myFindInterval(epoch(:,ii));
    
    % sigh. another thing to look for: multi-interval stacks
    % some at duck changed at 15 minutes into the run
    % do the same calc as above, but use only the last 100 epochs
    pcint100 = myFindInterval(epoch(end-100:end,ii));
    
    % define change of more than 5% as "multi". Return 
    % the value of the second interval, or 0 if not.
    stats.multiInterval(ii) = 0;
    if( abs(1-pcint/pcint100) > .05 )
        stats.multiInterval(ii) = pcint100;
    end;
        
    % if no fixed epoch int, use per-cam.
    if feint < 0
        stats.noCanonical = 1;
        ceint = pcint;
    else
        stats.noCanonical = 0;
        ceint = feint;
    end
    
    % gaps in sampling, return top five
    stats.intervalStd(ii) = pcstd;
    [gaps,gi] = sort(diff(epoch(:,ii)));
    stats.longInts5(ii,:) = gaps(end:-1:end-4);
    stats.longInts5When(ii,:) = epoch(gi(end:-1:end-4),ii);
    
    % "catchups", top 5 minimum intervals
    stats.shortInts5(ii,:) = gaps(1:5);
    stats.shortInts5When(ii,:) = epoch(gi(1:5),ii);
    
    % how long should this record have been, list under/overrun
    expLen = ceint*(length(epoch(:,1))-1);
    stats.overrun(ii) = epoch(end,ii) - epoch(1,ii) - expLen;
    
    stats.intervalError(ii) = ceint - pcint; % will be zero if noCanonical
    
    stats.numLong(ii) = length(find((diff(epoch(:,ii)) > ceint+pcstd )));
    stats.numShort(ii) = length(find((diff(epoch(:,ii)) < ceint-pcstd )));
    stats.interval(ii) = ceint;  % from last camera, or canonical if present
    
end

% intercamera

stats.startDelay = epoch(1,:) - min(epoch(1,:));
if stats.noCanonical
    stats.startError = stats.startDelay;
else
    stats.startError = epoch(1,:) - fe(1);
end

stats.endError = epoch(end,:) - epoch(1,:) - expLen;

% and finally, save the incoming epoch for later use
stats.epochs = epoch;

return;
end


function [pcint, pcstd] = myFindInterval( epoch )

%  this code works really great, except when it doesn't.
%  I have a duck stack where the cycle time is so wacked
%  that this gives a NEGATIVE interval. Sigh. 
%     de = diff(epoch);
%     pcstd = std(de);
%     valid = find( abs(de-mean(de)) < 2*pcstd );
%     pcint = mean(de(valid));

% but a simple mode works. Sigh again. 
    pcint = mode(diff(epoch));
    pcstd = 0.05 * pcint;
    
    return;
    
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

