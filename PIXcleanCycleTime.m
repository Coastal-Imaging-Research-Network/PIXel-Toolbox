function [e, needed, failed] = PIXcleanCycleTime( olde, interval )

% [newEpoch, needed, failed] = PIXcleanCycleTime( oldEpoch, interval )
%
%  clean up a screwy cycle time problem.
%
%  symptom: a negative diff (time cannot go backward)
%
%  solution:
%       for each negative diff, 
%           calculate the loss from the right interval
%           reset to the right interval
%           subract error from the next diff
%       use start time, then integrate clean diffs.

if(size(olde,2) == 1)
    col = 0;
else
    col = 1;
end

needed = 0;
failed = 0;

% put into the orientation I want
if col; olde = olde'; end;

de = diff(olde);

for ii = 1:length(de)-1
    
    if( (de(ii)<0) ) 
        
        % keep track of first negative diff in this sequence
        if( firstneg == 0 )
            firstneg = ii;
        end;
        
        % say I needed to clean it up
        needed = 1;

        % find the error
        derr = interval - de(ii);
        % fix this diff
        de(ii) = interval;
        % and fix the next one along
        de(ii+1) = de(ii+1) - derr;
        % oops, 0 diff is BAD! Means multiple kinds of errors
        if(de(ii+1) == 0)   % dropped frame with cycle error
            % I've failed!
            failed = 1;
            % best guess, it was dropped at the most recent
            % negative diff
            de(firstneg) = de(firstneg)+interval;
            % and the next one needs to be non-zero
            de(ii+1) = interval;
        end
    else
        % end of this negative sequence
        firstneg = 0;
    end
    
    
end

% one final point -- the end!
if( de(end) < 0 )
    needed = 1;
    de(end) = interval;
end

% calculate the new epoch times.
e = [ olde(1); cumsum(de)+olde(1) ] ;

% put the epoch back the way we got it.
if col; e = e'; end;



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

