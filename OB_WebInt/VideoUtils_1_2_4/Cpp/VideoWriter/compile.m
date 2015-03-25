clc

if (ispc)
    mex -I./ -I../3rdParty/Ffmpeg/win/include -L../3rdParty/Ffmpeg/win/lib -lavcodec -lavdevice -lavformat -lavutil -lswscale mexVideoWriter.cpp VideoWriter.cpp
end

if (ismac)
else
    if (isunix)
        mex -I./ -I/usr/include -L/usr/lib -lavcodec -lavdevice -lavformat -lavutil -lswscale  mexVideoWriter.cpp VideoWriter.cpp
    end
end