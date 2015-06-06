#include <linux/module.h>


static int *ptr;

int init_module (void)
{
        ptr = (int *) __symbol_get ("myvar");
        if (ptr)
          {
                  *ptr = 800;
                  __symbol_put ("myvar");
                  return 0;
          }
        else
          {
                  pr_err ("Symbol not available\n");
          }
        return 0;
}

void cleanup_module (void)
{
}

MODULE_AUTHOR ("support@techveda.org");
MODULE_DESCRIPTION ("LKD_CW : Accessing exported data symbols");
MODULE_LICENSE ("GPL");
                            
