include "numeric.pxi"
import numpy

cdef extern from "gromacs_xtc.h":

    ctypedef int XDR
    ctypedef int bool_t

    int xdropen(XDR *xdrs, char *filename, char *type)
    int xdrclose(XDR *xdrs)
    int xdr3dfcoord(XDR *xdrs, float *fp, int *size, float *precision)
    bool_t xdr_int(XDR *xdrs, int *ip)
    bool_t xdr_float(XDR *xdrs, float *fp)


cdef class XTCTrajectory:

    cdef XDR xdr_handle
    cdef int is_open
    cdef public int natoms
    cdef public int frame_counter
    cdef public object box
    cdef public object coordinates
    cdef public int step
    cdef public float time

    def __init__(self, filename):
        cdef int magic
        if xdropen(&self.xdr_handle, filename, "r") == 0:
            raise IOError("Error opening file %s" % filename)
        xdr_int(&self.xdr_handle, &magic)
        if magic != 1995:
            raise IOError("File %s is not an xtc file" % filename)
        xdr_int(&self.xdr_handle, &self.natoms)
        xdrclose(&self.xdr_handle)
        if xdropen(&self.xdr_handle, filename, "r") == 0:
            raise IOError("Error opening file %s" % filename)
        self.box = numpy.zeros((3, 3), numpy.float32)
        self.coordinates = numpy.zeros((self.natoms, 3), numpy.float32)
        self.frame_counter = 0
        self.is_open = 1

    def close(self):
        if self.is_open:
            xdrclose(&self.xdr_handle)
            self.is_open = 0
            
    def readStep(self):
        cdef int magic
        cdef int natoms
        cdef float prec
        cdef ndarray box_array, coordinate_array

        prec = 1000.
        if not self.is_open:
            raise IOError("File has been closed")
        if xdr_int(&self.xdr_handle, &magic) == 0:
            xdrclose(&self.xdr_handle)
            self.is_open = 0
            return False
        if magic != 1995:
            raise IOError("File is not an xtc file")
        if xdr_int(&self.xdr_handle, &natoms) == 0 or \
           xdr_int(&self.xdr_handle, &self.step) == 0 or \
           xdr_float(&self.xdr_handle, &self.time) == 0:
            raise IOError("Read error")
        if natoms != self.natoms:
            raise IOError("Unexpected number of coordinates: " +
                          "%d != %d" % (natoms, self.natoms))
        box_array = self.box
        coordinate_array = self.coordinates
        for i from 0 <= i < 9:
            if xdr_float(&self.xdr_handle, &(<float *>box_array.data)[i]) == 0:
                raise IOError("Read error")
        if xdr3dfcoord(&self.xdr_handle, <float *>coordinate_array.data,
                       &natoms, &prec) == 0:
                raise IOError("Read error")
        self.frame_counter = self.frame_counter + 1
        return True
