%  Pixel array design, scheduling and data extraction routines.
%
%  Flags to control operation
%
%    PIXInterpUV        - generate pixels to interpolate to exact X,Y,Z
%    PIXFixedXY         - do not round X and Y back to pixel location
%    PIXFixedZ          - use Z from the instrument an dnot the build
%    PIXDeBayerStack    - for Bayer encoded cameras, debayer each point
%                         instead of simply retruning pixel. APPLIES TO
%                         ENTIRE STACK.
%  
%  Pixel instrument design.
%    alphaPIXArray	- array for measurement of wave direction
%    bathyPIXArray	- array for estimation of a bathymetry profile
%    runupPIXArray	- array for measurement of wave runup
%    shearPIXArray	- array for measurement of shear waves and u(tau)
%    vbarPIXArray	- array for measurement of longshore current
%
%  Approximate bathymetry routines.
%    approxDuckBathy	- approximate bathymetry for Duck, NC
%    approxAgateBathy	- approximate bathymetry for Agate Beach, OR
%    approxSIOBathy	- approximate bathymetry for Scripps, CA
%    approxWaimeaBathy	- approximate bathymetry for Waimea Bay, HI
%    approxDroskynBathy	- approximate bathymetry for Droskyn, England
%    approxNoordwijkBathy- approximate bathymetry for Noordwijk
%    approxEgmondBathy	- approximate bathymetry Egmond, The Netherlands
%    approxPBBathy	- approximate bathymetry for Palm Beach, Australia
%    approxMuriwaiBathy	- approximate bathymetry for Muriwai, New Zealand
%
%  Site designs
%    AgatePIXArray	- constructs and schedules collects for Agate
%    DuckPIXArray	- constructs and schedules collects for Duck
%    SIOPIXArray	- constructs and schedules collects for Scripps
%
%  Pixel instrument construction and scheduling.
%    PIXCreateInstrument- create new empty instrument
%    PIXAddPoints	- add more of more points to an instrument
%    PIXAddLine		- add a line to an instrument, defined by endpoints
%    PIXAddMatrix	- add a matrix of points to an instrument
%    PIXCreatePackage	- creates or appends to a package of instruments
%    PIXAddInstrument	- adds an instrument to a package
%    PIXMakeVBAR	- create a VBAR instrument
%    PIXMakePatch	- create a Patch instrument
%    PIXBuildCollect	- builds collection for a package at a time
%    PIXScheduleCollect	- builds the files necessary to run an Argus collection
%    
%  Extraction of data from stacks.
%    loadStack		- load a stack or it's collection parameters
%    PIXGetRFromAOIName	- gets schedule collection data for AOIFile
%    PIXFindUVByName	- find UV coords for a named instrument
%    PIXInterp		- Interpolates bracketting pixels to rawUV locations
%    PIXFindCollect	- load the collection structure for a stack.
%    loadFullInstFromStack - load all instruments of a particular type
%    loadAllStackInfo - load p and r structures for any stack.
%    loadDataAboutStack - retrieve a minimal 'r' for a 'cx' extracted
%                         stack, by filename.
%
%  Saving or loading designed instruments
%    PIXSetStation	- select station and load any existing instruments
%    PIXForget		- clear all local station data changes (like init)
%    PIXCommit		- save current instruments in database (sort of)
%    PIXGetInstruments	- load all instruments for a station
%    PIXGetInstrumentByID - load a specific instrument
%
%  Demo and general
%    PIXDemoFile	- demonstration m-file for collection and retrieval
%    showPIXInstruments	- shows the locations and names of instruments
%
%  Pixel Analysis Tools
%
%  Bathymetry
%   findBathyFromData -- finds bathymetry from loaded stack data
%
%  Vbar
%   processVbarStack  -- process OCM master routine.
%   videoCurrent    -- process video current meter from stack data

% Id: Contents.m 1.1 4/24/2 17:13:44
% Notes:  

%key doc 
%comment  

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

