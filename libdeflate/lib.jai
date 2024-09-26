//
// This file was auto-generated using the following command:
//
// jai ./libdeflate/generate.jai
//



LIBDEFLATE_VERSION_MAJOR :: 1;
LIBDEFLATE_VERSION_MINOR :: 21;
LIBDEFLATE_VERSION_STRING :: "1.21";

/* ========================================================================== */
/*                             Compression                                    */
/* ========================================================================== */
libdeflate_compressor :: struct {}

/*
* libdeflate_alloc_compressor() allocates a new compressor that supports
* DEFLATE, zlib, and gzip compression.  'compression_level' is the compression
* level on a zlib-like scale but with a higher maximum value (1 = fastest, 6 =
* medium/default, 9 = slow, 12 = slowest).  Level 0 is also supported and means
* "no compression", specifically "create a valid stream, but only emit
* uncompressed blocks" (this will expand the data slightly).
*
* The return value is a pointer to the new compressor, or NULL if out of memory
* or if the compression level is invalid (i.e. outside the range [0, 12]).
*
* Note: for compression, the sliding window size is defined at compilation time
* to 32768, the largest size permissible in the DEFLATE format.  It cannot be
* changed at runtime.
*
* A single compressor is not safe to use by multiple threads concurrently.
* However, different threads may use different compressors concurrently.
*/
libdeflate_alloc_compressor :: (compression_level: s32) -> *libdeflate_compressor #foreign libdeflate;

/*
* Like libdeflate_alloc_compressor(), but adds the 'options' argument.
*/
libdeflate_alloc_compressor_ex :: (compression_level: s32, options: *libdeflate_options) -> *libdeflate_compressor #foreign libdeflate;

/*
* libdeflate_deflate_compress() performs raw DEFLATE compression on a buffer of
* data.  It attempts to compress 'in_nbytes' bytes of data located at 'in' and
* write the result to 'out', which has space for 'out_nbytes_avail' bytes.  The
* return value is the compressed size in bytes, or 0 if the data could not be
* compressed to 'out_nbytes_avail' bytes or fewer.
*
* If compression is successful, then the output data is guaranteed to be a
* valid DEFLATE stream that decompresses to the input data.  No other
* guarantees are made about the output data.  Notably, different versions of
* libdeflate can produce different compressed data for the same uncompressed
* data, even at the same compression level.  Do ***NOT*** do things like
* writing tests that compare compressed data to a golden output, as this can
* break when libdeflate is updated.  (This property isn't specific to
* libdeflate; the same is true for zlib and other compression libraries too.)
*/
libdeflate_deflate_compress :: (compressor: *libdeflate_compressor, in: *void, in_nbytes: u64, out: *void, out_nbytes_avail: u64) -> u64 #foreign libdeflate;

/*
* libdeflate_deflate_compress_bound() returns a worst-case upper bound on the
* number of bytes of compressed data that may be produced by compressing any
* buffer of length less than or equal to 'in_nbytes' using
* libdeflate_deflate_compress() with the specified compressor.  This bound will
* necessarily be a number greater than or equal to 'in_nbytes'.  It may be an
* overestimate of the true upper bound.  The return value is guaranteed to be
* the same for all invocations with the same compressor and same 'in_nbytes'.
*
* As a special case, 'compressor' may be NULL.  This causes the bound to be
* taken across *any* libdeflate_compressor that could ever be allocated with
* this build of the library, with any options.
*
* Note that this function is not necessary in many applications.  With
* block-based compression, it is usually preferable to separately store the
* uncompressed size of each block and to store any blocks that did not compress
* to less than their original size uncompressed.  In that scenario, there is no
* need to know the worst-case compressed size, since the maximum number of
* bytes of compressed data that may be used would always be one less than the
* input length.  You can just pass a buffer of that size to
* libdeflate_deflate_compress() and store the data uncompressed if
* libdeflate_deflate_compress() returns 0, indicating that the compressed data
* did not fit into the provided output buffer.
*/
libdeflate_deflate_compress_bound :: (compressor: *libdeflate_compressor, in_nbytes: u64) -> u64 #foreign libdeflate;

/*
* Like libdeflate_deflate_compress(), but uses the zlib wrapper format instead
* of raw DEFLATE.
*/
libdeflate_zlib_compress :: (compressor: *libdeflate_compressor, in: *void, in_nbytes: u64, out: *void, out_nbytes_avail: u64) -> u64 #foreign libdeflate;

/*
* Like libdeflate_deflate_compress_bound(), but assumes the data will be
* compressed with libdeflate_zlib_compress() rather than with
* libdeflate_deflate_compress().
*/
libdeflate_zlib_compress_bound :: (compressor: *libdeflate_compressor, in_nbytes: u64) -> u64 #foreign libdeflate;

/*
* Like libdeflate_deflate_compress(), but uses the gzip wrapper format instead
* of raw DEFLATE.
*/
libdeflate_gzip_compress :: (compressor: *libdeflate_compressor, in: *void, in_nbytes: u64, out: *void, out_nbytes_avail: u64) -> u64 #foreign libdeflate;

/*
* Like libdeflate_deflate_compress_bound(), but assumes the data will be
* compressed with libdeflate_gzip_compress() rather than with
* libdeflate_deflate_compress().
*/
libdeflate_gzip_compress_bound :: (compressor: *libdeflate_compressor, in_nbytes: u64) -> u64 #foreign libdeflate;

/*
* libdeflate_free_compressor() frees a compressor that was allocated with
* libdeflate_alloc_compressor().  If a NULL pointer is passed in, no action is
* taken.
*/
libdeflate_free_compressor :: (compressor: *libdeflate_compressor) -> void #foreign libdeflate;

/* ========================================================================== */
/*                             Decompression                                  */
/* ========================================================================== */
libdeflate_decompressor :: struct {}

/*
* libdeflate_alloc_decompressor() allocates a new decompressor that can be used
* for DEFLATE, zlib, and gzip decompression.  The return value is a pointer to
* the new decompressor, or NULL if out of memory.
*
* This function takes no parameters, and the returned decompressor is valid for
* decompressing data that was compressed at any compression level and with any
* sliding window size.
*
* A single decompressor is not safe to use by multiple threads concurrently.
* However, different threads may use different decompressors concurrently.
*/
libdeflate_alloc_decompressor :: () -> *libdeflate_decompressor #foreign libdeflate;

/*
* Like libdeflate_alloc_decompressor(), but adds the 'options' argument.
*/
libdeflate_alloc_decompressor_ex :: (options: *libdeflate_options) -> *libdeflate_decompressor #foreign libdeflate;

/*
* Result of a call to libdeflate_deflate_decompress(),
* libdeflate_zlib_decompress(), or libdeflate_gzip_decompress().
*/
libdeflate_result :: enum s32 {
    SUCCESS            :: 0;

    BAD_DATA           :: 1;

    SHORT_OUTPUT       :: 2;

    INSUFFICIENT_SPACE :: 3;

    LIBDEFLATE_SUCCESS            :: SUCCESS;

    LIBDEFLATE_BAD_DATA           :: BAD_DATA;

    LIBDEFLATE_SHORT_OUTPUT       :: SHORT_OUTPUT;

    LIBDEFLATE_INSUFFICIENT_SPACE :: INSUFFICIENT_SPACE;
}

/*
* libdeflate_deflate_decompress() decompresses a DEFLATE stream from the buffer
* 'in' with compressed size up to 'in_nbytes' bytes.  The uncompressed data is
* written to 'out', a buffer with size 'out_nbytes_avail' bytes.  If
* decompression succeeds, then 0 (LIBDEFLATE_SUCCESS) is returned.  Otherwise,
* a nonzero result code such as LIBDEFLATE_BAD_DATA is returned, and the
* contents of the output buffer are undefined.
*
* Decompression stops at the end of the DEFLATE stream (as indicated by the
* BFINAL flag), even if it is actually shorter than 'in_nbytes' bytes.
*
* libdeflate_deflate_decompress() can be used in cases where the actual
* uncompressed size is known (recommended) or unknown (not recommended):
*
*   - If the actual uncompressed size is known, then pass the actual
*     uncompressed size as 'out_nbytes_avail' and pass NULL for
*     'actual_out_nbytes_ret'.  This makes libdeflate_deflate_decompress() fail
*     with LIBDEFLATE_SHORT_OUTPUT if the data decompressed to fewer than the
*     specified number of bytes.
*
*   - If the actual uncompressed size is unknown, then provide a non-NULL
*     'actual_out_nbytes_ret' and provide a buffer with some size
*     'out_nbytes_avail' that you think is large enough to hold all the
*     uncompressed data.  In this case, if the data decompresses to less than
*     or equal to 'out_nbytes_avail' bytes, then
*     libdeflate_deflate_decompress() will write the actual uncompressed size
*     to *actual_out_nbytes_ret and return 0 (LIBDEFLATE_SUCCESS).  Otherwise,
*     it will return LIBDEFLATE_INSUFFICIENT_SPACE if the provided buffer was
*     not large enough but no other problems were encountered, or another
*     nonzero result code if decompression failed for another reason.
*/
libdeflate_deflate_decompress :: (decompressor: *libdeflate_decompressor, in: *void, in_nbytes: u64, out: *void, out_nbytes_avail: u64, actual_out_nbytes_ret: *u64) -> libdeflate_result #foreign libdeflate;

/*
* Like libdeflate_deflate_decompress(), but adds the 'actual_in_nbytes_ret'
* argument.  If decompression succeeds and 'actual_in_nbytes_ret' is not NULL,
* then the actual compressed size of the DEFLATE stream (aligned to the next
* byte boundary) is written to *actual_in_nbytes_ret.
*/
libdeflate_deflate_decompress_ex :: (decompressor: *libdeflate_decompressor, in: *void, in_nbytes: u64, out: *void, out_nbytes_avail: u64, actual_in_nbytes_ret: *u64, actual_out_nbytes_ret: *u64) -> libdeflate_result #foreign libdeflate;

/*
* Like libdeflate_deflate_decompress(), but assumes the zlib wrapper format
* instead of raw DEFLATE.
*
* Decompression will stop at the end of the zlib stream, even if it is shorter
* than 'in_nbytes'.  If you need to know exactly where the zlib stream ended,
* use libdeflate_zlib_decompress_ex().
*/
libdeflate_zlib_decompress :: (decompressor: *libdeflate_decompressor, in: *void, in_nbytes: u64, out: *void, out_nbytes_avail: u64, actual_out_nbytes_ret: *u64) -> libdeflate_result #foreign libdeflate;

/*
* Like libdeflate_zlib_decompress(), but adds the 'actual_in_nbytes_ret'
* argument.  If 'actual_in_nbytes_ret' is not NULL and the decompression
* succeeds (indicating that the first zlib-compressed stream in the input
* buffer was decompressed), then the actual number of input bytes consumed is
* written to *actual_in_nbytes_ret.
*/
libdeflate_zlib_decompress_ex :: (decompressor: *libdeflate_decompressor, in: *void, in_nbytes: u64, out: *void, out_nbytes_avail: u64, actual_in_nbytes_ret: *u64, actual_out_nbytes_ret: *u64) -> libdeflate_result #foreign libdeflate;

/*
* Like libdeflate_deflate_decompress(), but assumes the gzip wrapper format
* instead of raw DEFLATE.
*
* If multiple gzip-compressed members are concatenated, then only the first
* will be decompressed.  Use libdeflate_gzip_decompress_ex() if you need
* multi-member support.
*/
libdeflate_gzip_decompress :: (decompressor: *libdeflate_decompressor, in: *void, in_nbytes: u64, out: *void, out_nbytes_avail: u64, actual_out_nbytes_ret: *u64) -> libdeflate_result #foreign libdeflate;

/*
* Like libdeflate_gzip_decompress(), but adds the 'actual_in_nbytes_ret'
* argument.  If 'actual_in_nbytes_ret' is not NULL and the decompression
* succeeds (indicating that the first gzip-compressed member in the input
* buffer was decompressed), then the actual number of input bytes consumed is
* written to *actual_in_nbytes_ret.
*/
libdeflate_gzip_decompress_ex :: (decompressor: *libdeflate_decompressor, in: *void, in_nbytes: u64, out: *void, out_nbytes_avail: u64, actual_in_nbytes_ret: *u64, actual_out_nbytes_ret: *u64) -> libdeflate_result #foreign libdeflate;

/*
* libdeflate_free_decompressor() frees a decompressor that was allocated with
* libdeflate_alloc_decompressor().  If a NULL pointer is passed in, no action
* is taken.
*/
libdeflate_free_decompressor :: (decompressor: *libdeflate_decompressor) -> void #foreign libdeflate;

/*
* libdeflate_adler32() updates a running Adler-32 checksum with 'len' bytes of
* data and returns the updated checksum.  When starting a new checksum, the
* required initial value for 'adler' is 1.  This value is also returned when
* 'buffer' is specified as NULL.
*/
libdeflate_adler32 :: (adler: u32, buffer: *void, len: u64) -> u32 #foreign libdeflate;

/*
* libdeflate_crc32() updates a running CRC-32 checksum with 'len' bytes of data
* and returns the updated checksum.  When starting a new checksum, the required
* initial value for 'crc' is 0.  This value is also returned when 'buffer' is
* specified as NULL.
*/
libdeflate_crc32 :: (crc: u32, buffer: *void, len: u64) -> u32 #foreign libdeflate;

/*
* Install a custom memory allocator which libdeflate will use for all memory
* allocations by default.  'malloc_func' is a function that must behave like
* malloc(), and 'free_func' is a function that must behave like free().
*
* The per-(de)compressor custom memory allocator that can be specified in
* 'struct libdeflate_options' takes priority over this.
*
* This doesn't affect the free() function that will be used to free
* (de)compressors that were already in existence when this is called.
*/
libdeflate_set_memory_allocator :: (malloc_func: #type (unknown0: u64) -> *void #c_call, free_func: #type (unknown0: *void) -> void #c_call) -> void #foreign libdeflate;

/*
* Advanced options.  This is the options structure that
* libdeflate_alloc_compressor_ex() and libdeflate_alloc_decompressor_ex()
* require.  Most users won't need this and should just use the non-"_ex"
* functions instead.  If you do need this, it should be initialized like this:
*
*	struct libdeflate_options options;
*
*	memset(&options, 0, sizeof(options));
*	options.sizeof_options = sizeof(options);
*	// Then set the fields that you need to override the defaults for.
*/
libdeflate_options :: struct {
    /*
    * This field must be set to the struct size.  This field exists for
    * extensibility, so that fields can be appended to this struct in
    * future versions of libdeflate while still supporting old binaries.
    */
    sizeof_options: u64;

    /*
    * An optional custom memory allocator to use for this (de)compressor.
    * 'malloc_func' must be a function that behaves like malloc(), and
    * 'free_func' must be a function that behaves like free().
    *
    * This is useful in cases where a process might have multiple users of
    * libdeflate who want to use different memory allocators.  For example,
    * a library might want to use libdeflate with a custom memory allocator
    * without interfering with user code that might use libdeflate too.
    *
    * This takes priority over the "global" memory allocator (which by
    * default is malloc() and free(), but can be changed by
    * libdeflate_set_memory_allocator()).  Moreover, libdeflate will never
    * call the "global" memory allocator if a per-(de)compressor custom
    * allocator is always given.
    */
    malloc_func:    #type (unknown0: u64) -> *void #c_call;
    free_func:      #type (unknown0: *void) -> void #c_call;
}

#scope_file

#import "Basic"; // For assert

libdeflate :: #library "./libdeflate";

#run {
    {
        instance: libdeflate_options;
        assert(((cast(*void)(*instance.sizeof_options)) - cast(*void)(*instance)) == 0, "libdeflate_options.sizeof_options has unexpected offset % instead of 0", ((cast(*void)(*instance.sizeof_options)) - cast(*void)(*instance)));
        assert(size_of(type_of(libdeflate_options.sizeof_options)) == 8, "libdeflate_options.sizeof_options has unexpected size % instead of 8", size_of(type_of(libdeflate_options.sizeof_options)));
        assert(((cast(*void)(*instance.malloc_func)) - cast(*void)(*instance)) == 8, "libdeflate_options.malloc_func has unexpected offset % instead of 8", ((cast(*void)(*instance.malloc_func)) - cast(*void)(*instance)));
        assert(size_of(type_of(libdeflate_options.malloc_func)) == 8, "libdeflate_options.malloc_func has unexpected size % instead of 8", size_of(type_of(libdeflate_options.malloc_func)));
        assert(((cast(*void)(*instance.free_func)) - cast(*void)(*instance)) == 16, "libdeflate_options.free_func has unexpected offset % instead of 16", ((cast(*void)(*instance.free_func)) - cast(*void)(*instance)));
        assert(size_of(type_of(libdeflate_options.free_func)) == 8, "libdeflate_options.free_func has unexpected size % instead of 8", size_of(type_of(libdeflate_options.free_func)));
        assert(size_of(libdeflate_options) == 24, "libdeflate_options has size % instead of 24", size_of(libdeflate_options));
    }
}

