#include <linux/module.h>       //kmod interface

unsigned int myvar;


int set_var (unsigned int a)
{
        myvar = a;
	return 0;
}

int get_var (void)
{
        return myvar;
}

int myinit (void)
{
        printk("module inserted \n");
	return 0;
}

void myexit (void)
{
        printk("module removed\n");
}



module_init (myinit);
module_exit (myexit);

EXPORT_SYMBOL_GPL (set_var);
EXPORT_SYMBOL_GPL (get_var);


/*Kernel module Comments*/
MODULE_AUTHOR ("sathya");
MODULE_DESCRIPTION ("First kernel module");
MODULE_LICENSE ("GPL");
