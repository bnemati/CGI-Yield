#!/usr/bin/env python
################################################################################
# PROGRAM: CG.py
################################################################################
'''
**PROGRAM:**


'''
################################################################################
# import built-in modules
################################################################################

import sys
import os
import numpy as np
from collections import defaultdict
from datetime import datetime, timedelta
import tempfile
import subprocess
import shutil
try:
        import argparse
except:
        print( "Error import argparse, this is a python > 2.7 module" )
        exit(1)



################################################################################
# define input parameters as standalone script
################################################################################

def _getParser():
    '''
    This function defines the input parameters for the script
    '''
    argParser = argparse.ArgumentParser(description= __doc__,\
            formatter_class=argparse.\
            RawDescriptionHelpFormatter ) 
    argParser.add_argument('-inFile', required= True, help='input excel file.\n\n')
    argParser.add_argument('-obsMode', required = False, default = 'IFS 1comp',help = 'Observation Mode.\n\n')
    argParser.add_argument('-SNRTarget', required = False, type = int, default = 15,\
            help = 'Target signal to noise ratio.\n\n')	
    argParser.add_argument('-DetectorType', required = False, default = 'PC EMCCD',\
            help = 'type of the detector.\n\n')
    argParser.add_argument('-CoronographType', required = False, default = 'SPC',\
            help = 'type of the coronograph.\n\n')
    argParser.add_argument('-RvSys', required = False, type = int, default= 13,\
            help = 'type of the RV system.\n\n')
    argParser.add_argument('-FrameTime', required = False, type = int, default = 30,\
            help = 'Time for teh frame.\n\n')
    argParser.add_argument('-PostProcFactor', required = False, type = float, default = 7.0)
    argParser.add_argument('-planetPhaseAng', required = False, type = float, default = 45)
    argParser.add_argument('-ExoZodiSet',required = False, type = int, default = int)
    argParser.add_argument('-ContrastFloor', required = False, type = float, default = 2E-9,\
            help = 'Contrast Floor .\n\n')
    return argParser


def getArgs():
    args = _getParser().parse_args()
    return args	


################################################################################
#webQAMain()
################################################################################
if __name__ == '__main__':
    '''
    
    '''
    ## obtain the input arguments
    args = getArgs()

