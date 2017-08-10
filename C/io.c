#include <stdio.h>
int main( ) {

   char str1[100];
   char str2[100];
   int i;
   int c;

 //  printf( "Enter a string and value :");
 //  scanf("%s %d", str1, &i);

 //  printf( "\nYou entered: %s %d ", str1, i);



   printf( "\nEnter a value :");
   c = getchar( );

   printf( "\nYou entered: ");
   putchar( c );



   printf( "\nEnter a value :");
   gets( str2 );

   printf( "\nYou entered: ");
   puts( str2 );

   return 0;
}
