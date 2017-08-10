#include <stdio.h>
#include <string.h>

union Data {
   int i;
   float f;
   char str[20];
};

struct Data1 {
   int i;
   float f;
   char str[20];
};

int main( ) {

    union Data data;
    struct Data1 data1;

    printf( "Memory size occupied by data : %d\n", sizeof(data));
    printf( "Memory size occupied by data : %d\n", sizeof(data.i));
    printf( "Memory size occupied by data : %d\n", sizeof(data.f));
    printf( "Memory size occupied by data : %d\n", sizeof(data.str));
    printf("\n");
    printf( "Memory size occupied by data : %d\n", sizeof(data1));
    printf( "Memory size occupied by data : %d\n", sizeof(data1.i));
    printf( "Memory size occupied by data : %d\n", sizeof(data1.f));
    printf( "Memory size occupied by data : %d\n", sizeof(data1.str));

    return 0;
}
