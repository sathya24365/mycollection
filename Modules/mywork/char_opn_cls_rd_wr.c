#include <linux/module.h>
#include <linux/version.h>
#include <linux/kernel.h>
#include <linux/fs.h>
#include <linux/cdev.h>

#define MAJORNO 190
#define MINORNO 0
#define SUCCESS 0



static int char_dev_open(struct inode *inode, struct file *file)
{
        pr_info("Open operation invoked");
        return SUCCESS;
}


static int char_dev_read(struct inode *inode, struct file *file)
{
 
        pr_info("Read operation invoked");
        return SUCCESS;
       
}

static ssize_t char_dev_write(struct file *file, const char __user * buf,
                              size_t lbuf, loff_t * offset)
{
        pr_info("Rec'vd data : %s, of len=%ld\n", buf, lbuf);
        return lbuf;
}


static int char_dev_release(struct inode *inode, struct file *file)
{
        pr_info("Close operation invoked");
        return SUCCESS;
}








static struct file_operations char_dev_fops = {
        .owner = THIS_MODULE,
        .write = char_dev_write,
        .open = char_dev_open,
        .release = char_dev_release
};















static int __init char_dev_init(void)
{
        int ret;
        mydev = MKDEV(MAJORNO, MINORNO);
        register_chrdev_region(mydev, count, CHAR_DEV_NAME);

        /* Allocate cdev instance */
        veda_cdev = cdev_alloc();

        /* initialize cdev with fops object */
        cdev_init(veda_cdev, &char_dev_fops);

        /* register cdev with vfs(devtmpfs) */
        ret = cdev_add(veda_cdev, mydev, count);
        if (ret < 0) {
                pr_err("Error registering device driver");
                return ret;
        }
        pr_info("Device Registered %s", CHAR_DEV_NAME);
        return SUCCESS;
}


static void __exit char_dev_exit(void)
{
        /* remove cdev */
        cdev_del(veda_cdev);

        /* free major/minor no's used */
        unregister_chrdev_region(mydev, count);
        pr_info("Driver unregistered");
}

module_init(char_dev_init);
module_exit(char_dev_exit);

MODULE_AUTHOR("www.techveda.org");
MODULE_DESCRIPTION("LKD_CW: Character Device Driver - Test");
MODULE_LICENSE("GPL");

