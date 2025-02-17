

all:
	./build_rt_patched_kernel.bash

clean:
	rm -rf *.xz *.tar *.patch *.sign *.changes *.deb *linux-*