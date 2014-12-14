function disp(obj)
% Copyright (C) 2012  Marc Vivet - marc.vivet@gmail.com
% All rights reserved.
%
%   $Revision: 25 $
%   $Date: 2013-03-09 14:19:06 +0000 (Sat, 09 Mar 2013) $
%
% Redistribution and use in source and binary forms, with or without
% modification, are permitted provided that the following conditions are 
% met: 
%
% 1. Redistributions of source code must retain the above copyright notice, 
%    this list of conditions and the following disclaimer. 
% 2. Redistributions in binary form must reproduce the above copyright 
%    notice, this list of conditions and the following disclaimer in the 
%    documentation and/or other materials provided with the distribution. 
%
% THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS 
% "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED 
% TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A 
% PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER 
% OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, 
% EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, 
% PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR 
% PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF 
% LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING 
% NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS 
% SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
%
% The views and conclusions contained in the software and documentation are
% those of the authors and should not be interpreted as representing 
% official policies, either expressed or implied, of the FreeBSD Project.

    disp('<a href = "matlab:help VideoPlayer">VideoPlayer</a> < <a href = "matlab:help handle">handle</a> ')
    disp(' ');
    disp('Properties:');
    m.VideoName = obj.VideoName;
    m.Frame = obj.Frame;

    progress = round((obj.Time / obj.TotalTime) * 20);
    
    m.FrameWidth = obj.FrameWidth;
    m.FrameHeight = obj.FrameHeight;
    m.Width = obj.Width;
    m.Height = obj.Height;
    m.Channels = obj.Channels;
    m.StepInFrames = obj.StepInFrames;
    m.FrameNum = obj.FrameNum;
    m.NumFrames = obj.NumFrames;
    m.Time = obj.Time;
    m.TotalTime = obj.TotalTime;
    
    m.Progress = '[';
    
    for i = 1:1:progress - 1
        m.Progress = [m.Progress '='];
    end
    
    if ( obj.Time == obj.TotalTime ) 
        m.Progress = [m.Progress '='];
    else
        m.Progress = [m.Progress '>'];
    end
    
    for i = progress + 1:1:20
        m.Progress = [m.Progress '-'];
    end
    
    m.Progress = [m.Progress ']'];
    
    disp(m);
    disp([...
        '<a href = "matlab:VideoPlayer.disp_Methods">Methods</a>, '...
        '<a href = "matlab:methods(''VideoPlayer'')">All methods</a>, '...
        '<a href = "matlab:events(''VideoPlayer'')">Events</a>, '...
        '<a href = "matlab:superclasses(''VideoPlayer'')">Superclasses</a>'...
         ]);

     disp(' ');
end