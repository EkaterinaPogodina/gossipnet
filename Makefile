TF_INC = $(shell python -c 'import tensorflow as tf; print(tf.sysconfig.get_include())')
CUDA_LIB = /usr/local/cuda/lib64/
TF_LIB="/home/ubuntu/anaconda3/envs/tensorflow_p36/lib/python3.6/site-packages/tensorflow"

.PHONY: all

all: nms_net/matching_module/det_matching.so nms_net/roi_pooling_layer/roi_pooling.so imdb/file_formats/AnnoList_pb2.py

nms_net/roi_pooling_layer/roi_pooling_op_gpu.o: nms_net/roi_pooling_layer/roi_pooling_op_gpu.cu
	nvcc -std=c++11 -c -o $@ $? -I $(TF_INC) -D GOOGLE_CUDA=1 -x cu -Xcompiler -fPIC -D _GLIBCXX_USE_CXX11_ABI=0

nms_net/roi_pooling_layer/roi_pooling.so: nms_net/roi_pooling_layer/roi_pooling_op.cc nms_net/roi_pooling_layer/roi_pooling_op_gpu.o
	g++ -std=c++11 -shared -o $@ $? -I $(TF_INC) -fPIC -lcudart -L$(CUDA_LIB) -L${TF_LIB} -ltensorflow_framework -D _GLIBCXX_USE_CXX11_ABI=0

nms_net/matching_module/det_matching.so: nms_net/matching_module/det_matching.cc
	g++ -std=c++11 -shared $< -o $@ -fPIC -I ${TF_INC} -lcudart -L$(CUDA_LIB) -L${TF_LIB} -ltensorflow_framework -D _GLIBCXX_USE_CXX11_ABI=0

%_pb2.py: %.proto
	protoc --python_out=. $<

clean:
	rm -f *.o *.so *.pyc *.npy                                 
