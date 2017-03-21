function dataStruct = loadInstsFromStack(stackName,varargin)

% usage: dataStruct = loadInstsFromStack(stackName,instType,instNames)
%
%	LOADINSTSFROMSTACK will return all (N) of the instruments (by default)
%	of type INSTTYPE from STACKNAME (strings).  The program will also
%	return data from the instruments of type INSTTYPE contained in 
%	other stack files from different cameras, when applicable.
%	The data returned will be interpolated if the instrument was 
%	created to do so. INSTNAMES is an optional argument, a cell array that
%	contains the specific instruments to be loaded.   
% 	The (1xN) DATASTRUCT structure contains the fields:
%		data - cell array of data from each camera
%		UV - cell array of u's and v's from each camera
%		rawUV - cell array of interped u's and v's from each camera
%		XYZ - cell array of real world coords. from each camera
%		epoch - cell array of epoch time vectors from each camera 
%		stackName - cell array stack names from each camera
%		instName - instrument name
%               msc - media stream counter (shutter and gain for argus III)	
%               r - r structure from the stack schedules	
%
%	see also: loadStack, PIXInterp

% Chris Chickadel  10/24/2001
% updated 10/23/2003

%test% stackName ='1047303557.Mon.Mar.10_13_39_17.GMT.2003.argus02a.c3.stack.ras.Z'; varargin = { 'vbar','vbar1'}

% stackName = '1012422607.Wed.Jan.30_20_30_07.GMT.2002.blacky.c1.stack.ras'; varargin = { 'vbar','v-700.75'};

% stackName = '1012422607.Wed.Jan.30_20_30_07.GMT.2002.blacky.c1.stack.ras'; varargin = { 'alpha','a-700230'};

% stackName = '1067626800.Fri.Oct.31_19_00_00.GMT.2003.blacky3.c1.stack.ras.Z';

% check for input arguments
switch length(varargin)
  case 1
    instType = varargin{1};
  case 2
    instType = varargin{1};
    instNames = varargin{2};
    if ~iscell(instNames)
      instNames = {instNames};
    end  
  otherwise
    disp('wrong number of inputs')
    %exit
end

% parse filename
p = parseFilename(stackName);

% does file exist, is it a stack
try
  params = loadStack(stackName,'info');
catch
  disp(lasterr);
  %exit;
end

% is it the correct stack type
try
  r = PIXGetRFromAOIName(stackName,params.aoifile);
catch
  disp(lasterr);
  error(['No R file found for ' stackName])
end

% are there instruments of the correct type in the stack, what are they
try
  availInstTypeAll = [r.cams.types];
catch
  availInstTypeAll = [r.cams.names];
end
availInstType = unique(availInstTypeAll(:));
findInst = strmatch(instType,availInstTypeAll);
if ~sum(findInst)
  disp(['No ' instType ' instruments in ' stackName])
end
allCamNames = [r.cams.names];
if length(varargin)<2
  instNames = unique(allCamNames(strmatch(instType,availInstTypeAll)));
end

% find other stacknames if we need them
info = p; 
info.format = '*';
try
for j = 1:length(r.cams)
  if sum(strncmp(instType,r.cams(j).types,4))>0
    info.camera = r.cams(j).cameraNumber;
    stackNames{j} = findArgusImages(info,5);
  end 
end
catch
for j = 1:length(r.cams)
  if sum(strncmp(instType,r.cams(j).names,4))>0;
    info.camera = r.cams(j).cameraNumber;
    stackNames{j} = findArgusImages(info,20);
  end 
end
end
stackNames = deblank(stackNames);

% load the data
dataStruct = repmat(struct('instName',[],'data',[],'msc',[],'epoch',[],'XYZ',[],'UV',[],'rawUV',[],'stackName',[]),length(instNames),1);
for j = 1:length([r.cams.cameraNumber])
  for jj = 1:length(instNames)
  dataStruct(jj).instName = instNames{jj};
  try %%
    clear  UV rawUV XYZ epoch data
    [UV, rawUV, XYZ] = PIXFindUVByName(r.cams(j).cameraNumber,r,instNames{jj});
    if ~isempty(UV)
      [params,epoch,msc,data] = loadStack(stackNames{j},UV);
      if length(UV)>length(rawUV)
        if length(params.order ~= size(UV,1))
	  tempUV = [params.U(params.order) params.V(params.order)];
	  dataTemp = [];
          for jjj = 1:length(UV)
	    dInd = find(tempUV(:,1) == UV(jjj,1) & tempUV(:,2) == UV(jjj,2));
            dataTemp(:,jjj) = data(:,dInd(1)); 
	  end
        end
	data = PIXInterp(dataTemp,rawUV);	
      end  
      dataStruct(jj).data = [dataStruct(jj).data {data}];
      dataStruct(jj).msc = [dataStruct(jj).msc {msc}];
      dataStruct(jj).UV = [dataStruct(jj).UV {UV}];
      dataStruct(jj).rawUV = [dataStruct(jj).rawUV {rawUV}];
      dataStruct(jj).XYZ = [dataStruct(jj).XYZ {XYZ}];
      dataStruct(jj).epoch = [dataStruct(jj).epoch {epoch}];
      dataStruct(jj).stackName = [dataStruct(jj).stackName stackNames(j)];
    end
  catch %%
    disp(lasterr)
  end %%
  end 
end

% output r file
dataStruct(1).R = r;

%
% $Id: loadInstsFromStack.m 21 2016-02-11 22:21:37Z  $
%
% $Log: loadInstsFromStack.m,v $
% Revision 1.1  2004/08/19 21:39:19  stanley
% Initial revision
%
%
%key pixelExtract vbar 
%comment Extracts pixel instruments from video stack 
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

