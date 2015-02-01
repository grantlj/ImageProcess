CC	= g++
CFLAGS	= -O3 -static -D__STDC_CONSTANT_MACROS
#BIN_DIR = ../bin
BIN_DIR	= ./bin
INC_DIR	= ./include
LIB_DIR	= ./lib
OBJ	= SiftMotionFFmpeg.o Motion_SIFT_feature.o convert.o AFGVideo.FF.o
INCL	= -I$(INC_DIR) `pkg-config --cflags opencv`			\
	   `pkg-config --cflags libswscale libavcodec libavformat libavutil`
LIBS	= -L$(LIB_DIR)		\
	   `pkg-config --libs libswscale libavformat libavcodec libavutil` \
	   `pkg-config --libs opencv` -lpthread -lcxcore -lz -lbz2   #due to some very odd dependency errors, cxcore has to come first
BIN     = siftmotionffmpeg bin2txt txt2bin gzip2txt txt2gzip txyc bof spbof 

all: $(BIN)
	chmod +x $(BIN_DIR)/siftmotionffmpeg
	chmod +x $(BIN_DIR)/bin2txt
	chmod +x $(BIN_DIR)/txt2bin
	chmod +x $(BIN_DIR)/gzip2txt
	chmod +x $(BIN_DIR)/txt2gzip
	chmod +x $(BIN_DIR)/txyc
	chmod +x $(BIN_DIR)/bof
	chmod +x $(BIN_DIR)/spbof

siftmotionffmpeg: $(OBJ)
	$(CC) $(CFLAGS) $(LIB_DIR)/SiftMotionFFmpeg.o $(LIB_DIR)/Motion_SIFT_feature.o $(LIB_DIR)/convert.o $(LIB_DIR)/AFGVideo.FF.o  -o $(BIN_DIR)/$@ $(LIBS)

SiftMotionFFmpeg.o: SiftMotionFFmpeg.cpp
	$(CC) $(CFLAGS) $(INCL) -c SiftMotionFFmpeg.cpp -o $(LIB_DIR)/$@

Motion_SIFT_feature.o: Motion_SIFT_feature.cpp
	$(CC) $(CFLAGS) $(INCL) -c Motion_SIFT_feature.cpp -o $(LIB_DIR)/$@

AFGVideo.FF.o: AFGVideo.FF.cpp
	$(CC) $(CFLAGS) $(INCL) -c AFGVideo.FF.cpp -o $(LIB_DIR)/$@

convert.o: convert.cpp
	$(CC) $(CFLAGS) $(INCL) -c convert.cpp -o $(LIB_DIR)/$@

txyc: txyc.cpp convert.o
	$(CC) $(CFLAGS) $(INCL) txyc.cpp $(LIB_DIR)/convert.o -o $(BIN_DIR)/$@

bof: bof.cpp convert.o
	$(CC) $(CFLAGS) $(INCL) bof.cpp $(LIB_DIR)/convert.o -o $(BIN_DIR)/$@

spbof: spbof.cpp convert.o
	$(CC) $(CFLAGS) $(INCL) spbof.cpp $(LIB_DIR)/convert.o -o $(BIN_DIR)/$@

bin2txt: bin2txt.cpp
	$(CC) $(CFLAGS) $(INCL) bin2txt.cpp $(LIB_DIR)/convert.o -o $(BIN_DIR)/$@

txt2bin: txt2bin.cpp
	$(CC) $(CFLAGS) $(INCL) txt2bin.cpp $(LIB_DIR)/convert.o -o $(BIN_DIR)/$@

gzip2txt: gzip2txt.cpp
	$(CC) $(CFLAGS) $(INCL) gzip2txt.cpp $(LIB_DIR)/convert.o -o $(BIN_DIR)/$@

txt2gzip: txt2gzip.cpp
	$(CC) $(CFLAGS) $(INCL) txt2gzip.cpp $(LIB_DIR)/convert.o -o $(BIN_DIR)/$@
clean:
	rm -f *~ ./include/*~ ./lib/*.o core

.PHONY: clean
