function goToSecond( obj, value )
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
    
    if (~isnumeric(value) || value < 0.0)
        error('Input value must be a positive double value representing the seconds.');
    end

    mexVideoReader(6, obj.Id, value); 
    frame = mexVideoReader(3, obj.Id);
    obj.FrameNum = mexVideoReader(7, obj.Id);
    obj.Time = obj.getTime();
    
    if (obj.ResizeImage)
       frame = imresize(frame, [obj.ImageSize(2) obj.ImageSize(1)]);
       frame( frame > 1 ) = 1;
       frame( frame < 0 ) = 0;
    end
    
    if (obj.CuttingImage)
        frame = obj.cutImage(frame, obj.ValidRectangle);
    end  
    
    if ( obj.TransformOutput )
        if (numel(obj.Increments) > 4)
            obj.CurrentPosition(1:5) = obj.CurrentPosition(1:5) + stepNum .* obj.Increments(1:5) ;
            obj.CurrentPosition(6) = obj.CurrentPosition(6) * obj.Increments(6).^stepNum;
        else
            obj.CurrentPosition(1:3) = obj.CurrentPosition(1:3) + stepNum .* obj.Increments(1:3) ;
            obj.CurrentPosition(4) = obj.CurrentPosition(4) * obj.Increments(4).^stepNum;
        end
      
        frame = obj.imTransform(frame, obj.CurrentPosition); 
    end
    
    obj.Frame = frame;
    if ( obj.Binarize )
        obj.Frame(obj.Frame >= obj.BinarizeThreshold) = 1;
        obj.Frame(obj.Frame <= obj.BinarizeThreshold) = 0;       
    end
end