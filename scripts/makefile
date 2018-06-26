# a test makefile for ROSE
# e.g. make all -k -j32
C_SOURCE_FILES = $(shell ls ../micro-benchmarks/*.c)
CXX_SOURCE_FILES = $(shell ls ../micro-benchmarks/*.cpp)

POLYFLAG="../micro-benchmarks/utilities/polybench.c -I ../micro-benchmarks -I ../micro-benchmarks/utilities -DPOLYBENCH_NO_FLUSH_CACHE -DPOLYBENCH_TIME -D_POSIX_C_SOURCE=200112L"

C_OBJ_FILES = $(C_SOURCE_FILES:.c=*.o)
CXX_OBJ_FILES = $(CXX_SOURCE_FILES:.cpp=*.o)

all:$(C_OBJ_FILES) $(CXX_OBJ_FILES)

%.o: %.c
	$(ROSE_INSTALL)/bin/identityTranslator -c -std=c99 -rose:openmp:ast_only $< 
%.o: %.cpp
	$(ROSE_INSTALL)/bin/identityTranslator -c -rose:openmp:ast_only $< 

clean:
	rm -rf *.o rose_*.c rose_*.cpp
