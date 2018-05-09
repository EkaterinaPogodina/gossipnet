
TF_INC="/home/ubuntu/anaconda3/envs/tensorflow_p36/lib/python3.6/site-packages/tensorflow/include"

.PHONY: all

all: nms_net/matching_module/det_matching.so nms_net/roi_pooling_layer/roi_pooling.so imdb/file_formats/AnnoList_pb2.py

nms_net/roi_pooling_layer/roi_pooling.so: nms_net/roi_pooling_layer/roi_pooling_op.o nms_net/roi_pooling_layer/roi_pooling_op_gpu.o
	g++ -std=c++11 -shared $^ -o $@ -fPIC -O2

%.o: %.cc
	g++ -std=c++11 -c $< -o $@ -fPIC -I ${TF_INC} -I${TF_INC}/external/nsync/public -O2

%.o: %.cu
	nvcc -std=c++11 -c $< -o $@ -I ${TF_INC} -I${TF_INC}/external/nsync/public -O2 -x cu -arch=sm_37 -D GOOGLE_CUDA=1 -Xcompiler -fPIC

%.so: %.cc
	g++ -std=c++11 -shared $< -o $@ -fPIC -I ${TF_INC} -I${TF_INC}/external/nsync/public -O2

%_pb2.py: %.proto
	protoc --python_out=. $<
