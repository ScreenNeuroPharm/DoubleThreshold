/*=================================================================
 * mexfunction.c
 *
 * This example demonstrates how to use mexFunction.  It returns
 * the number of elements for each input argument, providing the
 * function is called with the same number of output arguments
 * as input arguments.
 

 * This is a MEX-file for MATLAB.
 * Copyright 1984-2018 The MathWorks, Inc.
 * All rights reserved.
 *=================================================================*/
#include "mex.h"

void mexFunction(int nlhs, mxArray* plhs[], int nrhs, const mxArray* prhs[]) {
    int i;

    /* Examine input (right-hand-side) arguments. */
    mexPrintf("\n%d input argument(s).", nrhs);
    for (i = 0; i < nrhs; i++) {
        mexPrintf("\n\tInput Arg %i is of type:\t%s ", i, mxGetClassName(prhs[i]));
    }

    /* Examine output (left-hand-side) arguments. */
    mexPrintf("\n\n%d output argument(s).\n", nlhs);
    if (nlhs > nrhs)
        mexErrMsgIdAndTxt("MATLAB:mexfunction:inputOutputMismatch",
                          "Cannot specify more outputs than inputs.\n");

    for (i = 0; i < nlhs; i++) {
        mwSize nel = mxGetNumberOfElements(prhs[i]);
#if MX_HAS_INTERLEAVED_COMPLEX
        plhs[i] = mxCreateDoubleScalar((mxDouble)nel);
        *mxGetDoubles(plhs[i]) = (mxDouble)mxGetNumberOfElements(prhs[i]);
#else
        plhs[i] = mxCreateDoubleScalar((double)nel);
        *mxGetPr(plhs[i]) = (double)mxGetNumberOfElements(prhs[i]);
#endif
    }
}
