#define  RD         0x00   
#define  WR         0x02 

#define SAMPLE_MAGIC 
#define  SET_RD  _IOW(SAMPLE_MAGIC, 1, 1024)
#define  SET_WR  _IOW(SAMPLE_MAGIC, 2, 1024)

