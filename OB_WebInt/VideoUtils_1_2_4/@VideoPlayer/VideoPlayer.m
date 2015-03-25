classdef  ...
        ( ...
          Hidden = false, ...          %If set to true, the class does not appear in the output of MATLAB commands or tools that display class names.
          InferiorClasses = {}, ...    %Use this attribute to establish a precedence relationship among classes. Specify a cell array of meta.class objects using the ? operator. The built-in classes double, single, char, logical, int64, uint64, int32, uint32, int16, uint16, int8, uint8, cell, struct, and function_handle are always inferior to user-defined classes and do not show up in this list.
          ConstructOnLoad = false, ... %If true, the class constructor is called automatically when loading an object from a MAT-file. Therefore, the construction must be implemented so that calling it with no arguments does not produce an error.
          Sealed = false ...           %If true, the class can be not be subclassed
         ) VideoPlayer < handle
% VideoPlayer   Class for read and play videos.
%
% Copyright (C) 2012  Marc Vivet - marc.vivet@gmail.com
% All rights reserved.
%
%   $Revision: 27 $
%   $Date: 2013-03-09 21:27:56 +0000 (Sat, 09 Mar 2013) $
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
%
%      Description
%      =============
%        Author: Marc Vivet - marc@vivet.cat
%        $Date: 2013-03-09 21:27:56 +0000 (Sat, 09 Mar 2013) $
%        $Revision: 27 $
%
%      Special Thanks
%      ===============
%        Oriol Martinez
%        Pol Cirujeda
%        Luis Ferraz 
%        Le Hai
%        Kensaku Nomoto
%        Steve Mintz
%
%      Syntax:
%      ============
%
%        % Initialization
%        vp = VideoPlayer(videoName);
%        % Or
%        vp = VideoPlayer(videoName, 'PropertyName', PropertyValue, ...);
%        
%        % Next Frame
%        vp.nextFrame();
%        % Or 
%        vp + 1;
%
%        %Plots the Actual Frame
%        plot(vp);
%
%        %Reproduces the video file
%        vp.play();
%
%        % Delete the object
%        delete(vp);
%        % Or
%        clear vp;
%
%      Configurable Properties:
%      =========================
%        +--------------------+------------------------------------------+
%        | Property Name      | Description                              |
%        +====================+==========================================+
%        | Verbose            | Shows the internal state of the object   |
%        |                    | by generating messages.                  |
%        |                    | Is useful when debugging                 |
%        +--------------------+------------------------------------------+
%        | ShowTime           | Show the secods nedeed for each function |
%        |                    | of this classe. This paramter must be    |
%        |                    | combined with the Verbose mode.          |
%        +--------------------+------------------------------------------+
%        | InitialFrame       | Sets the initial frame of the video.     |
%        |                    | By default is 1. (It have to be an       |
%        |                    | integer).                                |
%        +--------------------+------------------------------------------+
%        | ImageSize          | Sets the returned image size.            |
%        |                    | The format is [width height].            |
%        +--------------------+------------------------------------------+
%        | StepInFrames       | Sets the number of skipped frames when we|
%        |                    | call the member function vp.NextFrame(). |
%        |                    | By default is 1. (It have to be an       |
%        |                    | integer).                                |
%        +--------------------+------------------------------------------+
%        | ValidRectangle     | Only shows the video region inside this  |
%        |                    | rectangle. (cuts the image) This option  |
%        |                    | is useful for cutting high resolution    |
%        |                    | videos.                                  |
%        +--------------------+------------------------------------------+
%        | UseStaticPicture   | Generates a video sequence using only an |
%        |                    | image. You have to specify the           |
%        |                    | transformation between each frame using  |
%        |                    | this format:                             |
%        |                    |    [shiftX shiftY Rotation Scalation]    |
%        +--------------------+------------------------------------------+
%        | MaxFrames          | Determines the max number of frames of   |
%        |                    | the current video.                       |
%        +--------------------+------------------------------------------+
%        | TransformOutput    | Apply a transformation to the output of  |
%        |                    | video frame using this format:           |
%        |                    |    [shiftX shiftY Rotation Scalation]    |
%        +--------------------+------------------------------------------+
%        | Binarize           | Binarizes the output image (true/false)  |
%        +--------------------+------------------------------------------+
%        | BinaryThreshold    | Let you define the threshold used to     |
%        |                    | binarize the image.                      |
%        +--------------------+------------------------------------------+
%        | Title              | Let you set the figure title             |
%        +--------------------+------------------------------------------+
%        | UseSetOfVideos     | Let you open a ISV video (image set      |
%        |                    | video). You have to create this video by |
%        |                    | using the VideoRecorder class.           |
%        +--------------------+------------------------------------------+
%        | InitialSecond      | Let you specify the initial time of the  |
%        |                    | video. Shoult be a double value (seconds)|
%        +--------------------+------------------------------------------+

    properties (GetAccess='public', SetAccess='public')
        CurrentPosition
    end

    properties (GetAccess='public', SetAccess='private')
        % Name of the video + path
        VideoName
        % Initial frame
        InitialFrame = 1;
        % This value is used to increment the number of frame when using
        % nextFrame function.
        StepInFrames = 1;
        % Current frame number
        FrameNum
        % Current video time in seconds
        Time
        % Video sequence duration in seconds
        TotalTime = 'Uknown'
        % Double frame
        Frame
        
        % Max number of frame that will be reproduced
        MaxFrames = 0;
        
        % Frame width after transforming the frame
        Width
        % Frame height after transforming the frame
        Height
        % Original frame with
        FrameWidth
        % Original frame height
        FrameHeight
        % Total number of frames (approx)
        NumFrames
        % Number of channels RGB or gray scale
        Channels
        
        % Indicates if it is necessary to resize the original frame size
        ResizeImage = 0;
        % New frame size
        ImageSize = [-1 -1];
        
        % Image handler
        Hima
        % Figrue handler
        Hfig
        % Axes handler
        Haxes
        
        % Used by reproducing a set of videos as a single video
        SetVideoCurrentSet 
        SetVideoName  
    end
    
    properties (Hidden, Access = private)
        % VideoReader ID used to comunicate with the c++ part 
        Id
        % Indicates if the quit button was hit
        Quit = 0;
        
        % Indicats if it is necessary to cut the image
        CuttingImage = 0;
        % Region that will be cutted from the original frame
        ValidRectangle = [0 0 0 0];
        
        % Inidicates if the output must be transformed
        TransformOutput = false;
        
        % Variables needed to generate the videoplayer toolbar
        VideoPlayerIcons
        ToolButtonPlayStop
        ToolButtonQuick
        ToolButtonSlow
        ToolButtonStop
        ToolButtonAbout
        ToolButtonAntF
        ToolButtonNextF
        
        % Indicates if the video is an static picture
        UseStaticPicture = 0;
        % Increments applyied at each frame
        Increments
        % Original frame
        MainFrame
        PMFCenter
        % Frame corners
        FrameCorners
        % Image corners
        ImageCorners
        % Transformation to center the image
        Tf
        % Inverse of Tf
        Tfinv
        % Transformation matrix used to generate videos from a single image
        Tgp
        % Image Center
        ImageCenter
        % Projective transfor object used to transform the image
        PT
        
        % Indicates that the video is an static picture
        IsStaticPicture = 0;
        % Indicates that the video is a video file
        IsVideo = 0;
        % Indicates that the video is a set of videos
        IsSetOfVideos        = false;
        % Max frames per video
        SetVideoMaxFrames
        % Number of videos used in the set of videos
        SetVideoNumSets
        % video formats
        SetVideoFormat       
        % Folder where the videos are stored
        SetVideoDir
        % Number of frames for each video
        SetVideoFrameNum
        
        % Is a Sequence of images
        IsISV = 0;
        % Name of the sequence of images
        ISVName = '';
        % Extencion of these images
        ISVExt = '';
        
        % Show information in the cpp ffmpeg matlab library
        Verbose = false;
        % show process time of the cpp ffmpeg matlab library
        ShowTime = false;
        
        % Title bar text
        Title
        
        % Idicates if the image should be binarized
        Binarize = false;
        % Threshold used to binarize the image
        BinarizeThreshold = 0.5;
        
        % Variable used to start the video into a concrete second
        InitialSecond = -1;  
        
        PlayMode = false;
    end
    
    methods
        % Constructor
        function obj = VideoPlayer(videoName, varargin)
            % ----------------------------
            % Checking Input Parameters
            % ----------------------------
            p = inputParser;   % Create instance of inputParser class.

            p.addRequired ( 'videoName' );
            
            p.addParamValue ( 'Verbose',            obj.Verbose,              @(x)x==false || x==true  );
            p.addParamValue ( 'ShowTime',           obj.ShowTime,             @(x)x==false || x==true  );
            p.addParamValue ( 'InitialFrame',       obj.InitialFrame,         @obj.check_param_InitialFrame );
            p.addParamValue ( 'InitialSecond',      obj.InitialSecond,        @obj.check_param_InitialSecond );
            p.addParamValue ( 'ImageSize',          obj.ImageSize,            @obj.check_param_ImageSize );
            p.addParamValue ( 'MaxFrames',          obj.MaxFrames,            @obj.check_param_MaxFrames );
            p.addParamValue ( 'StepInFrames',       obj.StepInFrames,         @obj.check_param_StepInFrames );
            p.addParamValue ( 'UseStaticPicture',   obj.UseStaticPicture,     @obj.check_param_UseStaticPicture );
            p.addParamValue ( 'ValidRectangle',     obj.ValidRectangle,       @obj.check_param_ValidRectangle );
            p.addParamValue ( 'TransformOutput',    obj.TransformOutput,      @obj.check_param_TransformOutput );
            p.addParamValue ( 'Title',              videoName,                @isstr );
            p.addParamValue ( 'UseSetOfVideos',     obj.IsSetOfVideos,        @obj.check_param_UseSetOfVideos );
            p.addParamValue ( 'Binarize',           obj.Binarize,             @(x)x==false || x==true  );
            p.addParamValue ( 'BinaryThreshold',    obj.BinarizeThreshold,    @obj.check_param_BinaryThreshold  );
            p.parse(videoName, varargin{:});
            
            obj.Verbose             = p.Results.Verbose;
            obj.ShowTime            = p.Results.ShowTime;
            obj.VideoName           = p.Results.videoName;
            obj.Title               = p.Results.Title;
            obj.Binarize            = p.Results.Binarize;
            % ----------------------------
         
                                               
            obj.FrameNum = obj.InitialFrame;
            
            if (exist(obj.VideoName) == 0)
                error(['File ''' videoName ''' do not exist!']);   
            end

            if (obj.UseStaticPicture) 
                % Reading Image
                
                obj.IsStaticPicture = 1;

                if (~obj.CuttingImage) 
                    error('In order to use static pictures you must define the ValidRectangle.');
                end

                frame = double(imread(obj.VideoName)) / 255.0;
                obj.MainFrame = frame;

                [hI wI ~] = size(frame);

                obj.PT = ProjectiveTransform ();

                [obj.Tf, obj.Tfinv] = obj.PT.getTf ( frame );

                obj.Tgp = eye(3);                    

                if (obj.ValidRectangle(1) == 0)
                    widthAux = obj.ValidRectangle(3);
                    heightAux = obj.ValidRectangle(4);                                           

                    offsetX = round((wI - widthAux) / 2.0) + 1;
                    offsetY = round((hI - heightAux) / 2.0) + 1;

                    obj.ValidRectangle = [offsetX offsetY round(widthAux) round(heightAux)];
                end

                obj.FrameWidth     = wI;
                obj.FrameHeight    = hI;

                %obj.NumFrames = Inf;
                
                if (obj.ResizeImage)
                    frame = imresize(frame, [obj.ImageSize(2) obj.ImageSize(1)]);
                    obj.Width = obj.ImageSize(1);
                    obj.Height = obj.ImageSize(2);
                    frame( frame > 1 ) = 1;
                    frame( frame < 0 ) = 0;
                end
            else                     
                % Opening Video
                
                if ( obj.IsSetOfVideos )
                    k = strfind(obj.VideoName, '/');
                    i = strfind(obj.VideoName, '_');
                    j = strfind(obj.VideoName, '.');
                    
                    obj.SetVideoCurrentSet = str2num(obj.VideoName(i(end) + 1:j(end) - 1));
                    
                    obj.SetVideoFormat = obj.VideoName(end-2:end);

                    if (numel(k) > 0)
                        obj.SetVideoName   = obj.VideoName(k(end)+1:i(end) - 1);
                        obj.SetVideoDir    = obj.VideoName(1:k(end));
                        
                    else
                        obj.SetVideoName = obj.VideoName(1:i(end) - 1);
                        obj.SetVideoDir  = '';
                    end                
                    
                                   
                        
                    if (obj.ResizeImage)                        
                        info  = mexVideoReader(0, [obj.SetVideoDir obj.SetVideoName '_' num2str(obj.SetVideoCurrentSet) '.' obj.SetVideoFormat],...
                            'Verbose', obj.Verbose, 'ShowTime', obj.ShowTime, 'Scale', obj.ImageSize);
                    else
                        info  = mexVideoReader(0, [obj.SetVideoDir obj.SetVideoName '_' num2str(obj.SetVideoCurrentSet) '.' obj.SetVideoFormat],...
                            'Verbose', obj.Verbose, 'ShowTime', obj.ShowTime);
                    end

                    obj.ResizeImage = 0;
                    
                    aux = dir([obj.SetVideoDir obj.SetVideoName '_*']);
                    obj.SetVideoNumSets = size(aux, 1);
                    
                    obj.Id                = info.Id;
                    obj.Width             = info.Width;
                    obj.Height            = info.Height;
                    obj.FrameWidth        = info.FrameWidth;
                    obj.FrameHeight       = info.FrameHeight;
                    obj.SetVideoMaxFrames = info.NumFrames;
                    
                    obj.NumFrames = obj.SetVideoNumSets * obj.SetVideoMaxFrames;

                    obj.SetVideoFrameNum = mod(obj.InitialFrame, obj.SetVideoMaxFrames); 
                    
                    currSet = floor(obj.InitialFrame / obj.SetVideoMaxFrames);
                    
                    if ( currSet ~= obj.SetVideoCurrentSet )
                       obj.SetVideoCurrentSet = currSet;
                       mexVideoReader(2, obj.Id);
                       
                       if (obj.ResizeImage)                        
                            info  = mexVideoReader(0, [obj.SetVideoDir obj.SetVideoName '_' num2str(obj.SetVideoCurrentSet) '.' obj.SetVideoFormat],...
                                'Verbose', obj.Verbose, 'ShowTime', obj.ShowTime, 'Scale', obj.ImageSize);
                        else
                            info  = mexVideoReader(0, [obj.SetVideoDir obj.SetVideoName '_' num2str(obj.SetVideoCurrentSet) '.' obj.SetVideoFormat],...
                                'Verbose', obj.Verbose, 'ShowTime', obj.ShowTime);
                        end

                        obj.Id = info.Id;
                    end

                    if ( obj.SetVideoFrameNum ~= 1)
                        mexVideoReader(4, obj.Id, obj.SetVideoFrameNum);
                        frame = mexVideoReader(3, obj.Id);
                        obj.FrameNum = obj.InitialFrame + obj.SetVideoCurrentSet * obj.SetVideoMaxFrames;
                    else
                        frame = mexVideoReader(3, obj.Id);
                        obj.FrameNum = 1 + obj.SetVideoCurrentSet * obj.SetVideoMaxFrames;
                    end
                    
                    obj.Time = obj.getTime();

                    if ( obj.TransformOutput )
                        obj.PT = ProjectiveTransform ();

                        [obj.Tf, obj.Tfinv] = obj.PT.getTf ( frame );

                        obj.Tgp = eye(3);
                    end
                else
                    if isdir(obj.VideoName)
                        obj.IsISV = 1;

                        k = strfind(obj.VideoName, '/');

                        if (numel(k) > 0)
                            obj.ISVName = obj.VideoName(k(end)+1:end-4);
                        else
                            obj.ISVName = obj.VideoName(1:end-4);
                        end

                        aux = dir([obj.VideoName '/*_*']);

                        obj.ISVExt = aux(end).name(end-3:end);
                        obj.NumFrames = size(aux, 1);

                        frame = obj.getISVFrame(obj.InitialFrame);

                        obj.FrameWidth  = size(frame, 2);
                        obj.FrameHeight = size(frame, 1);

                        if (obj.ResizeImage)
                            frame = imresize(frame, [obj.ImageSize(2) obj.ImageSize(1)]);
                            obj.Width = obj.ImageSize(1);
                            obj.Height = obj.ImageSize(2);
                            frame( frame > 1 ) = 1;
                            frame( frame < 0 ) = 0;
                        end     

                    else                    
                        obj.IsVideo = 1;                   

                        if (obj.ResizeImage)                        
                            info  = mexVideoReader(0, obj.VideoName,...
                                'Verbose', obj.Verbose, 'ShowTime', obj.ShowTime, 'Scale', obj.ImageSize);
                        else
                            info  = mexVideoReader(0, obj.VideoName,...
                                'Verbose', obj.Verbose, 'ShowTime', obj.ShowTime);
                        end

                        obj.ResizeImage = 0;

                        obj.Id          = info.Id;
                        obj.Width       = info.Width;
                        obj.Height      = info.Height;
                        obj.FrameWidth  = info.FrameWidth;
                        obj.FrameHeight = info.FrameHeight;
                        obj.NumFrames   = info.NumFrames;
                        obj.TotalTime   = info.TotalTime;

                        if ( obj.InitialFrame ~= 1)
                            mexVideoReader(4, obj.Id, obj.InitialFrame);
                            frame = mexVideoReader(3, obj.Id);
                            obj.FrameNum = obj.InitialFrame;
                        else
                            if ( obj.InitialSecond ~= -1 ) 
                                mexVideoReader(6, obj.Id, obj.InitialSecond); 
                                frame = mexVideoReader(3, obj.Id);
                                obj.FrameNum = mexVideoReader(7, obj.Id);
                            else
                                frame = mexVideoReader(3, obj.Id);
                            end
                        end

                        obj.Time = obj.getTime();

                        if ( obj.TransformOutput )
                            obj.PT = ProjectiveTransform ();
                            [obj.Tf, obj.Tfinv] = obj.PT.getTf ( frame );
                            obj.Tgp = eye(3);
                        end
                    end
                end
            end
             
            if (obj.CuttingImage)
                if ((obj.ValidRectangle(1) + obj.ValidRectangle(3) - 1) > ...
                        obj.Width)

                    error('The Valid Rectangle does not fit to the video.');
                end

                if ((obj.ValidRectangle(2) + obj.ValidRectangle(4) - 1) > ...
                        obj.Height)

                    error('The Valid Rectangle does not fit to the video.');
                end          

                obj.Width     = obj.ValidRectangle(3);
                obj.Height    = obj.ValidRectangle(4);                   
            end

            obj.Channels = size(frame, 3);

            obj.Frame = frame;
            if ( obj.Binarize )
                obj.Frame(obj.Frame >= obj.BinarizeThreshold) = 1;
                obj.Frame(obj.Frame <= obj.BinarizeThreshold) = 0;

            end
            
            if (obj.CuttingImage)
                obj.Frame = obj.cutImage(obj.Frame, obj.ValidRectangle);
            end

            obj.ImageCenter = [obj.Width obj.Height] / 2.0;
        end
        
        % Class Functions
        
        % Overlap a frame to the current frame, and returns the
        % percentage of ocluded pixels. The transparency is defined by the
        % parameter <mask>, which it is an array of 3 values -> [r g b];
        oclusion = addFrameToFrame ( obj, frame, varargin ) 

        % Adds gaussian noise to the current frame.
        addGaussianNoise(obj, value);
        
        % Changes the transform increment when using static pictures to
        % generate the video sequences.
        changeTransformIncrement (obj, value);
        
        % Cuts an image given a rectangle
        subIm = cutImage (obj, ima, rec );
        
        % Destructor
        delete(obj); 
        
        % Shows the class help
        disp(obj);
        
        % Returns the image of a concrete frame number
        frame = getFrameAtNum ( obj, num );
        
        % Returns the current frame formated as Unigned Char
        res = getFrameUInt8 ( obj );
        
        % Function used to read frames from Image Set Videos or videos that
        % in fact are only a set of images. You can create this kind of
        % videos using the VideoRecorder class. Usefull when the process is
        % inestable and could need days to finish.
        frame = getISVFrame(obj, num);
        
        % Returns the current frame time in seconds
        time = getTime ( obj );
        
        % Go to specified second of the video
        goToSecond( obj, value );
        
        % Shift and image with a given offset.
        res = imShift( obj, im, offset );
        
        % Transform the image given a transformation matrix
        varargout = imTransform( obj, im, trans );
        
        % Operator- to decrement the frame number
        res = minus(obj, value)   
        
        % Reads the next frame
        res = nextFrame(obj, varargin);
        
        % Reproduces the video sequence 
        play( obj, varargin );
        
        % Show the current frame into a window
        plot(obj, varargin);
        
        % Operator+ in order to increment the frame number
        res = plus (obj1, obj2);
        
        % Places the plot window to a concrete position into the screen the
        % position parameter should be -> [x y with height]
        setPlotPosition( obj, position );
        
        % Let you definde the frame increment when using nextFrame
        setStepInFrames(obj, value);     
    end
       
    methods (Static, Hidden)
        % Auxiliary disp functions
        disp_Methods(obj);
        disp_HelpVideoPlayer(obj);
        disp_HelpNextFrame(obj);
        
        disp_HelpGetFrameUInt8(obj);
        disp_HelpGetFrameAtNum(obj);
        disp_HelpImShift(obj);
        disp_HelpImTransform(obj);
        disp_HelpCutImage(obj);
        disp_HelpAddGaussianNoise(obj);
        disp_HelpAddFrameToFrame(obj);
        
        disp_HelpChangeTransformIncrement(obj);
        disp_HelpGetTime(obj);
        disp_HelpGoToSecond(obj);
        disp_HelpPlay(obj);
        disp_HelpSetPlotPosition(obj);
        disp_HelpSetStepInFrames(obj);
    end
    
    methods (Hidden, Access = public)
        % Check auxiliary function for param checking.
        check_param_InitialFrame(obj, value);        
        check_param_StepInFrames(obj, value);
        check_param_ValidRectangle(obj, value);
        check_param_MaxFrames(obj, value);
        check_param_UseStaticPicture(obj, value);
        check_param_ImageSize(obj, value);
        check_param_TransformOutput(obj, value);
        check_param_InitialSecond(obj, value);
        check_param_BinaryThreshold(obj, value);
    end
       
    methods (Access = private)       
        % Tool Bar functions
        tool_PauseVideo(obj);
        tool_ContinueVideo(obj);
        tool_AntFrame(obj);
        tool_NextFrame(obj);
        tool_QuickVideo(obj);
        tool_SlowVideo(obj);
        tool_About(obj);
        tool_Quit(obj);
    end
end
