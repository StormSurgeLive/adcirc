#ifdef unix
#include "cproj.h"
/*  Fortran bridge routine for the UNIX */

void gctp_(double *incoor,long *insys,long *inzone,double *inparm,long *inunit,long *inspheroid,long *ipr,char *efile,long *jpr,char *pfile,
           double *outcoor,long *outsys,long *outzone,double *outparm,long *outunit,long *outspheroid,char *fn27,char *fn83,long *iflg)

//double *incoor;
//long *insys;
//long *inzone;
//double *inparm;
//long *inunit;
//long *inspheroid;
//long *ipr;        /* printout flag for error messages. 0=yes, 1=no*/
//char *efile;
//long *jpr;        /* printout flag for projection parameters 0=yes, 1=no*/
//char *pfile;
//double *outcoor;
//long *outsys;
//long *outzone;
//double *outparm;
//long *outunit;
//long *outspheroid;
//long *iflg;
///* 2/2024 Wesley Ebisuzaki added 2 lines */
//char *fn27;
//char *fn83;
{
gctp(incoor,insys,inzone,inparm,inunit,inspheroid,ipr,efile,jpr,pfile,outcoor,
     outsys,outzone,outparm,outunit,outspheroid,fn27,fn83,iflg);

return;
}
#endif
