#include "mex.h"
#include "matrix.h"
#include <math.h>

void mexFunction(int nout, mxArray *out[], int nin, const mxArray *in[]) {
	// check argument numbers
	if (nin < 5)
		mexErrMsgTxt("At least six arguments are required!");
	else if (nout > 1)
		mexErrMsgTxt("Too many output arguments!");

    // index of input and output variables
	enum {DX, DY, DT, MAG, AT};
	enum {LBP};

	// input matrix dimensions and pointers
	const int* ndims = mxGetDimensions(in[DX]);
	int nrows = ndims[0];
	int ncols = ndims[1];
	int nfrms = ndims[2];

	const double* dx = mxGetPr(in[DX]);
	const double* dy = mxGetPr(in[DY]);
	const double* dt = mxGetPr(in[DT]);
    const double* mag = mxGetPr(in[MAG]);

	// threshold
	double lamda = (double) *mxGetPr(in[AT]);

	// initialize ouput matrix without nullifying
	int *lbp;
    out[LBP] = mxCreateNumericArray(3, ndims, mxINT32_CLASS, mxREAL);
	lbp  = (int *)mxGetData(out[LBP]);
    
    int f, r, c, i;
    const int STEP[8][2] = { {-1,-1}, {-1,0}, {-1,1}, {0,-1}, {0,1}, {1,-1}, {1,0}, {1,1} };
    double nx, ny, nt, nmag, nxtmp, nytmp, nttmp, nmagtmp;
    for( f=0; f<nfrms; ++f )
        for( c=1; c<ncols-1; ++c )
            for( r=1; r<nrows-1; ++r ) {
                int value = 0;
                int index, idxtmp;
                index = f * (nrows * ncols) + c * nrows + r;
                nx = dx[index];
                ny = dy[index];
                nt = dt[index];
                nmag = mag[index];
                
                for( i=0; i<8; ++i){
                    idxtmp = f * (nrows * ncols) + (c+STEP[i][0]) * nrows + r+STEP[i][1];
                    nxtmp = dx[idxtmp];
                    nytmp = dy[idxtmp];
                    nttmp = dt[idxtmp];
                    nmagtmp = mag[idxtmp];
                    
                    double costheta = nx*nxtmp + ny*nytmp + nt*nttmp + nmag*nmagtmp;
                    if( costheta < lamda && costheta !=0)
                        // value += 2^(7-i);
                        value += (int)pow(2, 7-i);
                }
                // mexPrintf("f=%d, c =%d, r =%d, value=%d\n", f,c,r,value);
                lbp[index] = value;
            }
}