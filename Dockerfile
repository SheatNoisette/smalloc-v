from ubuntu:latest

run apt-get update
run apt-get install valgrind gcc git make -y
run git clone https://github.com/vlang/v.git /opt/v
run cd /opt/v; make -j;./v symlink

entrypoint ["/bin/bash"]
