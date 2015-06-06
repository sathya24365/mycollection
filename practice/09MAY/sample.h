#define  RD         0x00   
#define  WR         0x02 

# define SUCCESS 0
# define DEV_NAME "test"

struct rtc_user {
unsigned int data;
};




#define SAMPLE_MAGIC 'V'
#define  SET_RD  _IOR(SAMPLE_MAGIC, 1, 1024)
#define  SET_WR  _IOW(SAMPLE_MAGIC, 2, 1024)

