=head1 NAME

Algorithm::FEC - Forward Error Correction using Vandermonde Matrices

=head1 SYNOPSIS

 use Algorithm::FEC;

=head1 DESCRIPTION

This module is an interface to the fec library by Luigi Rizzo et al., see
the file README.fec in the distribution for more details.

This library implements a simple (C<encoded_packets>,C<data_packets>)
erasure code based on Vandermonde matrices.  The encoder takes
C<data_packets> packets of size C<block_size> each, and is able to produce
up to C<encoded_packets> different encoded packets, numbered from C<0>
to C<encoded_packets-1>, such that any subset of C<data_packets> members
permits reconstruction of the original data.

Allowed values for C<data_packets> and C<encoded_packets> must obey the
following equation:

   data_packets <= encoded_packets <= MAXBLOCKS

Where C<MAXBLOCKS=256> for the fast implementation and C<MAXBLOCKS=65536>
for the slow implementation (the implementation is chosen automatically).

=over 4

=cut

package Algorithm::FEC;

require XSLoader;

no warnings;

$VERSION = 0.01;

XSLoader::load Algorithm::FEC, $VERSION;

=item $fec = new data_packets, encoded_packets, blocksize

=item $fec->set_blocks ([array_of_blocks])

Sets the data blocks used for the encoding. Each member of the array can either be:

=over 4

=item * a string of size C<blocksize> C<exactly>.

This is useful for small files (encoding entirely in memory).

=item * a filehandle of a file of size C<blocksize> C<exactly>.

This is useful when the amount of data is large and resides in single files.

=item * a reference to an array containing a filehandle and, optionally, an offset into that file.

This is useful if the amount of data is large and resides in a single
file. Needless to say, all parts must not overlap and must fit into the
file.

=back

If your data is not of the required size (i.e. a multiple of C<blocksize>
bytes), then you must pad it (e.g. with zero bytes) on encoding, and
truncate it after decoding.

If called without arguments, the internal storage associated with the
blocks is freed again.

=item $block = $fec->encode (block_index)

Creates a single encoded packet of index C<block_index>, which must be
between C<0> and C<encoded_packets-1> (inclusive). The blocks from C<0> to
C<data_packets-1> are simply copies of the original data blocks.

The encoded block is returned as a perl scalar (so the blocks should fit
into memory. If this is a problem for you mail me and I'll make it a file.

=item $fec->decode ([array_of_blocks], [array_of_indices])

Decode C<data_packets> of blocks (see C<set_blocks> for the
C<array_of_blocks> parameter).

Since these are not necessarily the original data blocks, an array of
indices (ranging from C<0> to C<encoded_packets-1>) must be supplied as
the second arrayref.

Both arrays must have exactly C<data_packets> entries.

After decoding, the blocks will be modified in place (if necessary), and
the array of indices will be updates to reflect the changes: The n-th
entry in the indices array is the index of the n-th data block of the
file.

That is, if you call this function with C<indices = [4,3,1]>, with
C<data_packets = 3>, then this array will be returned: C<[0,2,1]>. This
means that input block C<0> corresponds file block C<0>, input block C<1>
to file block C<2> and input block C<2> to data block C<1>.

You can just iterate over this array and write out the corresponding data
block (although this is inefficient).

Only input blocks with indices >= C<data_packets> will be modified, blocks
that already contain the original data will just be reordered.

This method destroys the block array as set up by C<set_blocks>.

=item $fec->copy ($srcblock, $dstblock)

Utility function that simply copies one block (specified like in
C<set_blocks>) into another. This, btw., destroys the blocks set by
C<set_blocks>.

If you don't understand why this helps, feel free to ignore it :)

=item COMPATIBILITY

The way this module works is compatible with the way freenet
(L<http://freenet.sf.net>) encodes files. Comaptibility to other file
formats or networks is not know, please tell me if you find more examples.

=head1 SEE ALSO

L<Net::FCP>. And the author, who might be happy to receive mail from any
user, just to see that this rather rarely-used module is actually being
used (except for freenet ;)

=head1 BUGS

 * largely untested, please change this.
 * file descriptors are not supported, but should be.
 * utility functions for files should be provided.
 * 16 bit version not tested

=head1 AUTHOR

 Marc Lehmann <pcg@goof.com>
 http://home.schmorp.de

=cut

1;

