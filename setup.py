# By default, this script compiles the C version of the GromacsTrajectory
# module. To compile the original Pyrex code, uncomment the line containing
# 'GromacsTrajectory.pyx' and comment out the following line containing
# 'GromacsTrajectory.c'
#

from distutils.core import setup, Extension
try:
    from Cython.Distutils import build_ext
except ImportError:
    from distutils.command.build_ext import build_ext
import numpy.distutils.misc_util


setup (name = "GromacsTrajectoryReader",
       version = "0.12",
       description = "Gromacs trajectory file reader",

       ext_modules = [Extension('GromacsTrajectory',
#                                ['GromacsTrajectory.pyx',
                                ['GromacsTrajectory.c',
                                 'gromacs_xtc.c'],
                                include_dirs = numpy.distutils.misc_util.get_numpy_include_dirs(),
                                )],
       cmdclass = {'build_ext': build_ext}
       )
