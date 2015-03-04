classdef myvideo < handle
    properties
        cap = [];
        captype = 'otherplateform';
    end
    methods    
        function vd = myvideo(str)
%             if ~isempty(findstr(version, '2013')) % on loptop
%                 vd.cap = cv.VideoCapture(str);
%             elseif ~isempty(findstr(version, '2012')) % on PC
%                 vd.captype = 'pc';
%                 vd.cap = VideoReader(str);
%                 open(vd.cap);
%             else
                vd.captype = 'otherplateform';
                vd.cap = VideoPlayer(str);
%             end
        end
        function pos = getFramePos(vd)
            % get current position of frame;
            pos = -1;
            if ~isempty(vd.cap)
                if strcmpi(vd.captype, 'laptop')
                    pos = vd.cap.get('PosFrames');
                elseif strcmpi(vd.captype, 'pc')
                    pos = 0;
                else
                    pos = vd.cap.FrameNum;
                end
            end
        end
        function frame = getFrameAt(vd, k)
            % get a frame at position of k
            frame = [];
            if ~isempty(vd.cap)
                if strcmpi(vd.captype, 'laptop')
                    vd.cap.set('PosFrames', k);
                    frame = vd.cap.read;
                elseif strcmpi(vd.captype, 'pc')
                    frame = read(vd.cap, k);
                else
                    frame = vd.cap.getFrameAtNum(k);
                end
            end
        end
        function iCount = getFrameCount(vd)
            % get the number of frames 
            iCount = 0;
            if ~isempty(vd.cap)
                if strcmpi(vd.captype, 'laptop')
                    iCount = vd.cap.get('FrameCount');
                elseif strcmpi(vd.captype, 'pc')
                    iCount = vd.cap.NumberOfFrames;
                else
                    iCount = vd.cap.NumFrames;
                end
            end
        end
        function height = getFrameHeight(vd)
        % get the frame height
            height = 0;
            if ~isempty(vd.cap)
                if strcmpi(vd.captype, 'laptop')
                    height = vd.cap.get('FrameHeight');
                elseif strcmpi(vd.captype, 'pc')
                    height = vd.cap.Height;
                else
                    height = vd.cap.FrameHeight;
                end
            end
        end
        function width = getFrameWidth(vd)
            % get frame width
            width = 0;
            if ~isempty(vd.cap)
                if strcmpi(vd.captype, 'laptop')
                    width = vd.cap.get('FrameWidth');
                elseif strcmpi(vd.captype, 'pc')
                    width = vd.cap.Width;
                else
                    width = vd.cap.FrameWidth;
                end
            end
        end
        function FrameNum = getFrameNumByTime(vd, value)
            % value is time (second)
            if strcmpi(vd.captype, 'laptop') || strcmpi(vd.captype, 'pc')
                FrameNum =  -1;
            else
                FrameNum = vd.cap.getFrameNumByTime(value);
            end
        end
    end
end