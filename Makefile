CC ?= clang
V_COMPILER ?= $(shell which v)
V_FLAGS ?= -skip-unused -gc none -autofree
CFLAGS ?= -O2 -DVALLOC_POOL_SIZE=16000

BIN = smalloc_demo

ifdef DEBUG
	V_FLAGS += -cg
	CFLAGS =  -g3 -O0
endif

all: sallocdemo

sallocdemo:
	$(V_COMPILER) . $(V_FLAGS) -cflags $(CFLAGS) -o $(BIN)

clean:
	$(RM) -f $(BIN)
