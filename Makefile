CC ?= clang
V_COMPILER = $(shell which v)
V_FLAGS = -skip-unused -gc none -autofree
CFILE_OUT = smalloc_demo
CFLAGS = -O2

ifdef DEBUG
	V_FLAGS += -cg
	CFLAGS = -g3 -O0
endif

all: sallocdemo

sallocdemo:
	$(V_COMPILER) . $(V_FLAGS) -o $(CFILE_OUT)

clean:
	$(RM) -f $(CFILE_OUT)
