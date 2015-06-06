#include<linux/module.h>
extern int set_var (unsigned int arg);
extern int get_var(void);

int myinit(void)
{

set_var(100);
return 0;

}

void myexit(void)
{

unsigned int ret;
ret = get_var();
pr_info(-"value:%u \n",ret);

}

module_init (myinit);
module_exit (myexit);



/*Kernel module Comments*/
MODULE_AUTHOR ("sathya");
MODULE_DESCRIPTION ("First kernel module");
MODULE_LICENSE ("GPL");

