#include <linux/init.h>
#include <linux/module.h>
#include <linux/kernel.h>
#include <asm/io.h>
#include <linux/fs.h>
#include <linux/sched.h>
#include <asm/uaccess.h>
#include <linux/miscdevice.h>
#include "sample.h"

static unsigned char get_rtc(unsigned char addr)
{
        outb(addr, ADDRESS_REG);
        return inb(DATA_REG);
}

static void set_rtc(unsigned char data, unsigned char addr)
{

        outb(addr, ADDRESS_REG);
        outb(data, DATA_REG);
}

static int rtc_open(struct inode *rtc_inode, struct file *file)
{
        pr_info("rtc node opened\n");
        return 0;
}

static int rtc_close(struct inode *rtc_inode, struct file *file)
{
        pr_info("rtc node closed\n");
        return 0;
}

static ssize_t
rtc_read(struct file *file, char __user * buf, size_t cnt, loff_t * f_pos)
{
        unsigned int ret;
        struct rtc_user input = { 0 };

        if (cnt != sizeof(struct rtc_user)) {
                pr_err("invalid request");
                return -EINVAL;
        }
        pr_info("rtc user invoked\n");

        user.data = get_rtc(RD);

        ret = copy_to_user(buf, &data, sizeof(data));

        return cnt;
}


static ssize_t
rtc_write(struct file *file, char __user * buf, size_t cnt, loff_t * f_pos)
{
        unsigned int ret;
        struct rtc_user input= { 0 };

        if (cnt != sizeof(struct rtc_user)) {
                pr_err("invalid request");
                return -EINVAL;
        }
        pr_info("rtc user invoked\n");

        user.data = get_rtc(WR);

        ret = copy_from_user(buf, &data, sizeof(data));

        return cnt;
}



/* ioctl ---> sys_ioctl---> unlocked_ioctl(file_operations) */
static long rtc_ioctl(struct file *file, unsigned int cmd, unsigned long arg
{

        unsigned char data = arg;
	pr_info("rtc ioctl\n");

        if (_IOC_TYPE(cmd) != SAMPLE_MAGIC)
                return -ENOTTY;

        if (_IOC_DIR(cmd) & _IOC_READ)
                if (!access_ok(VERIFY_WRITE, (void *)arg, _IOC_SIZE(cmd)))
                        return -EFAULT;

        if (_IOC_DIR(cmd) & _IOC_WRITE)
                if (!access_ok(VERIFY_READ, (void *)arg, _IOC_SIZE(cmd)))
                        return -EFAULT;   

       	switch (cmd) {

        case SET_RD:
                set_rtc(data, RD);
                break;
        case SET_WR:
                set_rtc(data, WR);
           	break;
        }


	return 0;
}

static struct file_operations rtc_ops = {
        .open = rtc_open,
        .release = rtc_close,
        .read = rtc_read,
	.write = rtc_write,
        .unlocked_ioctl = rtc_ioctl,
};

static struct miscdevice RtcMisc = {
        .minor = MISC_DYNAMIC_MINOR,
        .name = DEV_NAME,
        .fops = &rtc_ops,
};

static int __init rtc_init(void)
{


	return SUCCESS;

}

static void __exit rtc_exit(void)
{
        

}

module_init(rtc_init);
module_exit(rtc_exit);

MODULE_LICENSE("GPL");
MODULE_AUTHOR("support@techveda.org");
MODULE_DESCRIPTION("LKD_CW: sample char driver for cmos realtime clock");

