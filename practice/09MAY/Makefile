obj-m += chardrv_ioctal.o
all:
	make -C /lib/modules/$(shell uname -r)/build SUBDIRS=$(PWD) modules


clean:
	make -C /lib/modules/$(shell uname -r)/build SUBDIRS=$(PWD) clean

