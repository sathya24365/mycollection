#include<stdio.h>
void main()
{
    int a;
    for(a=1; a<=10;a++)
    {
        if (a==2|a==4|a==6|a==8)
        {
            printf("\nTurn is Even::%d", a);
        }
        else
        {
            printf("\nTurn is Odd::%d", a);
        }
    }

}






