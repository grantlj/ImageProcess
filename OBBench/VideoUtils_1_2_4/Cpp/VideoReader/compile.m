clc

% if (ispc)
%     mex -I./ -I../3rdParty/Ffmpeg/win/include -L../3rdParty/Ffmpeg/win/lib -lavcodec -lavdevice -lavformat -lavutil -lswscale mexVideoReader.cpp VideoReader.cpp
%     %mex -I./ -I../../Bin/Win64/3rdParty/ffmpeg-win64/include -L../../Bin/Win64/3rdParty/ffmpeg-win64/lib -lavcodec -lavdevice -lavformat -lavutil -lswscale mexVideoReader.cpp VideoReader.cpp
% end
if (ispc)
    mex -I./ -I../3rdParty/include -L../3rdParty/lib -lavcodec -lavdevice -lavformat -lavutil -lswscale mexVideoReader.cpp VideoReader.cpp
    %mex -I./ -I../../Bin/Win64/3rdParty/ffmpeg-win64/include -L../../Bin/Win64/3rdParty/ffmpeg-win64/lib -lavcodec -lavdevice -lavformat -lavutil -lswscale mexVideoReader.cpp VideoReader.cpp
end

if (ismac)
else
    if (isunix)
        mex -I./ -I/usr/include -L/usr/lib -lavcodec -lavdevice -lavformat -lavutil -lswscale mexVideoReader.cpp VideoReader.cpp
    end
end