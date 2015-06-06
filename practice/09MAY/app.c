#include <stdio.h>
#include <sys/types.h>
#include <sys/stat.h>
#include <fcntl.h>
#include <stdlib.h>
#include <unistd.h>
#include <sys/ioctl.h>

#include "./sample.h"

int main(void)
{

        int fd;
        struct rtc_user data;

	int data=10;

        fd = open("/dev/test", O_RDWR);
        if (fd < 0) {
                perror("open call");
                return -1;
        }

        ioctl(fd, SET_RD, 1024);
	ioctl(fd, SET_WD, 1024);
        close(fd);
        return 0;
}


