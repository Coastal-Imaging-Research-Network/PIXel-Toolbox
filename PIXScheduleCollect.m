function err = PIXScheduleCollect( cams, samples, hertz, r )

% PIXScheduleCollect -- schedule a pixel sampling 
% 
%   err = PIXScheduleCollect( CAMS, SAMPLES, HERTZ, COLLECT ) builds the 
%   files necessary to run an argus station stack collection and returns 
%   an error flag if it fails. CAMS is a scalar or 1x2 array of camera 
%   numbers to include in this schedule. SAMPLES is the number of samples 
%   (lines) to collect in this collection. HERTZ is how often to collect. 
%   The maximum value is 2 for a two camera collections. COLLECT is a 
%   collection structure as produced by PIXBuildCollect.
%
%   The actual product from this routine will be documented later.
%

global PIXStation;

if isempty(cams)
	error('no cameras to schedule');
elseif length(cams) > 2
	error('too many cams to schedule');
end
if (length(cams) == 2) & (hertz > 2)
	error('too fast for two cameras');
end

err = 0;

% increment is based on 30 fps.
inc = fix(30/hertz);
run = samples / (30/inc);
disp(['This collection will run ' num2str(run) ' seconds (' ...
	num2str(run/60,4) ' minutes)']);

% create a place to put things -- my own temp
[status,msg] = mkdir('temp');

fname = ['temp' filesep num2str(r.epoch) '.sched'];
[mfid,message] = fopen( fname, 'w' );
fprintf(mfid,['sitename: ' PIXStation '\n' ...
	'videodevice: 2\n' ...
	'debug: 0\n']);

% counter for product 
counter = 1;

% foreach camera scheduled, build a UV list based on the epoch and camera
for thisCam = cams,

	% find the index in the collect array
	thisI = find( [r.cams(:).cameraNumber] == thisCam );
	if isempty(thisI)
		error(['Camera ' num2str(thisCam) ...
			' is not in the collect struct!']);
	elseif length(thisI) ~= 1
		error(['There are more than one camera ' num2str(thisCam) ...
			' in the collect struct!']);
	end

	disp(['Building camera number ' num2str(thisCam)]);

	myU = r.cams(thisI).U; myV = r.cams(thisI).V;
	if ~isempty(myU) & ~isempty(myV)
	    % if I want to uniq these, here is the place. not now, maybe later
	    fname = [num2str(r.epoch) '.c' num2str(thisCam) '.pix'];
	    [fid,message] = fopen( ['temp' filesep fname], 'w' );
	    if fid == -1
		    error(['Cannot open file ' fname ' for output: ' message]);
	    end

            % ok, let's unique this, rely on retrieving by UV later
	    zz = unique( myU * 10000 + myV );
	    myU = floor(zz/10000); myV = mod(zz,10000);

	    myUV = [myU';myV'];
	    fprintf( fid, '%d %d\n', myUV );
	    fclose(fid);

	    kramerB = r.cams(thisI).kramerButton;

	    % is the kramer button -1 (no kramer)?
	    if( r.cams(thisI).kramerButton == -1 ) 
		kramerB = 0;
	    end;
	    % is the kramer button 0 (invalid data)?
	    if( r.cams(thisI).kramerButton == 0 ) 
		error(['Invalid kramer button in database for camera ' ...
			num2str(r.cams(thisI).cameraNumber) ]);
	    end;

	    % fill in sched file for m
	    fprintf( mfid, ['Product: ' num2str(counter) '\n' ...
			    'doSnap: 1\n' ...
			    'doStack: 1\n' ...
			    'KramerButton: ' ...
				    num2str(kramerB) '\n' ...
			    'KramerBus: a\n' ...
			    'cameraNumber: ' ...
				    num2str(r.cams(thisI).cameraNumber) '\n' ...
			    'aoilistfile: '  fname '\n' ...
			    'samples: ' num2str(samples) '\n' ...
			    'increment: ' num2str(inc) '\n'] );
	    counter = counter + 1;
	end;
end

fclose(mfid);

% now save the collect struct for later use. 
disp('Saving collect structure');
fname = ['temp' filesep num2str(r.epoch) '.mat'];
save( fname, 'r' );

% 

%
% $Id: PIXScheduleCollect.m 21 2016-02-11 22:21:37Z  $
%
% $Log: PIXScheduleCollect.m,v $
% Revision 1.5  1904/03/26 11:20:05  stanley
% auto insert keywords
%
%
%key pixel pixelDesign 
%comment  Schedule a pixel sampling for Argus II 
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

