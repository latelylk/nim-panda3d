PANDA_DIR=$(shell python -c "import panda3d.core,os;print(os.path.dirname(os.path.dirname(panda3d.core.__file__)))")

.PHONY: all clean

all: test

test: test.nim panda3d/*.nim direct/*.nim direct/*/*.nim
	nim --cincludes:${PANDA_DIR}/include --clibdir:${PANDA_DIR}/lib cpp test.nim

clean:
	rm -f test
