package Bio::RelRangeI;

# $Id$
# A Bio::RangeI with additional methods to support shifting between
# relative and absolute views.

=head1 NAME

Bio::RelRangeI -- A Bio::RangeI with additional methods to support
shifting between relative and absolute views.

=head1 SYNOPSIS

=head1 DESCRIPTION

A L<Bio::RangeI> is a range over a sequence, and may be defined
relative to another range.  This interface, L<Bio::RelRangeI>,
provides additional methods for accessing the range in relative and
absolute coordinate spaces.

=head1 FEEDBACK

=head2 Mailing Lists

User feedback is an integral part of the evolution of this and other
Bioperl modules. Send your comments and suggestions preferably to
the Bioperl mailing list.  Your participation is much appreciated.

  bioperl-l@bioperl.org              - General discussion
  http://bioperl.org/MailList.shtml  - About the mailing lists

=head2 Reporting Bugs

Report bugs to the Bioperl bug tracking system to help us keep track
of the bugs and their resolution. Bug reports can be submitted via
email or the web:

  bioperl-bugs@bioperl.org
  http://bugzilla.bioperl.org/

=head1 AUTHOR

Paul Edlefsen E<lt>paul@systemsbiology.orgE<gt>.
Copyright (c) 2003 Institute for Systems Biology

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.  See DISCLAIMER.txt for
disclaimers of warranty.

=head1 CONTRIBUTORS

Lincoln Stein E<lt>lstein@cshl.orgE<gt>.

=head1 APPENDIX

The rest of the documentation details each of the object methods.
Internal methods are usually preceded with a _

=cut

# Let the code begin...
use strict;
use vars qw( @ISA %ABS_STRAND_OPTIONS );

use Class::Observable;
use Bio::RangeI;
@ISA = qw( Bio::RangeI Class::Observable );

use vars '$VERSION';
$VERSION = '1.00';

use overload 
  '""'     => 'toString',
  eq       => 'eq',
  fallback => 1;

BEGIN {
  # ABS_STRAND_OPTIONS contains the legal values for the strand options
  %ABS_STRAND_OPTIONS = map { $_, '_abs_'.$_ }
  (
   'strong', # ranges must have the same strand
   'weak',   # ranges must have the same strand or no strand
   'ignore', # ignore strand information
  );
}

=head1 Bio::RelRangeI methods

These methods are unique to Bio::RelRangeI (that is, they are not
inherited from above).

=cut

=head2 low

  Title   : low
  Usage   : my $low = $range->low( [$position_policy] );
  Function: Get the least-valued position of this range.
  Returns : The current lowest position of this range, relative to the
            seq_id.
  Args    : [optional] either 'stranded' or 'plus'

  This will return either start() or end(), depending on which
  is lower.

  The returned position will be given in minus-strand coordinates if
  this RelRangeI's position_policy is 'stranded', which is the default
  value.  If the argument to this method is a position policy (either
  'stranded' or 'plus') then this policy will be used instead of the
  object's overall policy.

  This method is implemented in the interface, and need not be
  overridden in concrete subclasses.

=cut

sub low {
  my $self = shift;
  my ( $position_policy ) = @_;
  my $a = $self->start( $position_policy );
  my $b = $self->end( $position_policy );
  return ( ( $a < $b ) ? $a : $b );
} # low()

=head2 high

  Title   : high
  Usage   : my $high = $range->high( [$position_policy] );
  Function: Get the greatest-valued position of this range.
  Returns : The current highest position of this range, relative to the
            seq_id.
  Args    : [optional] either 'stranded' or 'plus'

  This will return either start() or end(), depending on which
  is higher.

  The returned position will be given in minus-strand coordinates if
  this RelRangeI's position_policy is 'stranded', which is the default
  value.  If the argument to this method is a position policy (either
  'stranded' or 'plus') then this policy will be used instead of the
  object's overall policy.

  This method is implemented in the interface, and need not be
  overridden in concrete subclasses.

=cut

sub high {
  my $self = shift;
  my ( $position_policy ) = @_;
  my $a = $self->start( $position_policy );
  my $b = $self->end( $position_policy );
  return ( ( $a > $b ) ? $a : $b );
} # high()

=head2 absolute

  Title   : absolute
  Usage   : my $absolute_flag = $range->absolute( [$new_absolute_flag] );
  Function: Get/set the absolute flag.
  Returns : The current (or former, if used as a set method) value of the
            absolute flag.
  Args    : [optional] a new value for the absolute flag.

  If the absolute() flag is set then the start(), end(), and strand()
  methods will behave like the abs_start(), abs_end(), and abs_strand()
  methods, meaning that they will return values relative to abs_seq_id()
  rather than to seq_id().

=cut

sub absolute {
  shift->throw_not_implemented();
}

=head2 abs_range

  Title   : abs_range
  Usage   : my $abs_range = $range->abs_range();
  Function: Get the range of the abs_seq_id that this RangeI is defined over.
  Returns : The root range, or undef if there is none.
  Args    : none

  Ranges may have no defined abs_range, but this should be considered
  deprecated.  The concept of a 'range' requires that it is a range
  over some sequence; this method returns the range of that sequence.
  If the value of seq_id() is a string (the unique_id or primary_id of
  a L<Bio::PrimarySeqI>) then this method will return a range that is
  equal to this one (to $self).  If the value of seq_id() is another
  L<Bio::RangeI>, then this method will return it if its seq_id() if
  is a string, or keep searching up the tree until a range with a
  seq_id that is a string (or undef) is reached, and return that
  range.

=cut

sub abs_range {
  shift->throw_not_implemented();
}

=head2 abs_seq_id

  Title   : abs_seq_id
  Usage   : my $abs_seq_id = $range->abs_seq_id();
  Function: Get the unique_id or primary_id of the L<Bio::PrimarySeqI>
            that this RangeI is defined over.
  Returns : The root seq_id, or undef if there is none.
  Args    : none

  Ranges may have no defined abs_seq_id, but this should be considered
  deprecated.  The concept of a 'range' requires that it is a range
  over some sequence; this method returns that sequence.  If the value
  of seq_id() is a string (the unique_id or primary_id of a
  L<Bio::PrimarySeqI>) then this method will be identical to seq_id().
  If the value of seq_id() is another L<Bio::RangeI>, then this method
  will return its seq_id() if that is a string, or keep searching up the
  tree until a string (or undef) is reached.

=cut

sub abs_seq_id {
  shift->throw_not_implemented();
}

=head2 abs_start

  Title   : abs_start
  Usage   : my $abs_start = $range->abs_start( [$position_policy] );
  Function: Get the absolute start position of this range.
  Returns : The current start position of this range, relative to the
            abs_seq_id.
  Args    : [optional] either 'stranded' or 'plus'

  Note the interdependence of abs_start() and start().  Changing start() will
  change abs_start().

  Note the interdependence of abs_start() and length().  Changing length() will
  change abs_start().

  The returned position will be given in minus-strand coordinates if
  this RelRangeI's position_policy is 'stranded', which is the default
  value.  If the argument to this method is a position policy (either
  'stranded' or 'plus') then this policy will be used instead of the
  object's overall policy.

=cut

sub abs_start {
  shift->throw_not_implemented();
}

=head2 abs_end

  Title   : abs_end
  Usage   : my $abs_end = $range->abs_end( [$position_policy] );
  Function: Get the absolute end position of this range.
  Returns : The current absolute end position of this range, relative
            to the abs_seq_id.
  Args    : [optional] either 'stranded' or 'plus'

  Note the interdependence of abs_end() and end().  Changing end() will
  change abs_end().

  Note the interdependence of abs_end() and length().  Changing length() will
  change abs_end().

  The returned position will be given in minus-strand coordinates if
  this RelRangeI's position_policy is 'stranded', which is the default
  value.  If the argument to this method is a position policy (either
  'stranded' or 'plus') then this policy will be used instead of the
  object's overall policy.

=cut

sub abs_end {
  shift->throw_not_implemented();
}

=head2 abs_strand

  Title   : abs_strand
  Usage   : my $abs_strand = $range->abs_strand();
  Function: Get the absolute strandedness (-1, 0, or 1) of this range.
  Returns : The current absolute strand value of this range.
  Args    : none

=cut

sub abs_strand {
  shift->throw_not_implemented();
}

=head2 abs_low

  Title   : abs_low
  Usage   : my $abs_low = $range->abs_low( [$position_policy] );
  Function: Get the least-valued absolute position of this range.
  Returns : The current lowest position of this range, relative to the
            abs_seq_id.
  Args    : [optional] either 'stranded' or 'plus'

  This will return either abs_start() or abs_end(), depending on which
  is lower.

  The returned position will be given in minus-strand coordinates if
  this RelRangeI's position_policy is 'stranded', which is the default
  value.  If the argument to this method is a position policy (either
  'stranded' or 'plus') then this policy will be used instead of the
  object's overall policy.

  This method is implemented in the interface, and need not be
  overridden in concrete subclasses.

=cut

sub abs_low {
  my $self = shift;
  my ( $position_policy ) = @_;
  my $a = $self->abs_start( $position_policy );
  my $b = $self->abs_end( $position_policy );
  return ( ( $a < $b ) ? $a : $b );
} # abs_low()

=head2 abs_high

  Title   : abs_high
  Usage   : my $abs_high = $range->abs_high( [$position_policy] );
  Function: Get the greatest-valued absolute position of this range.
  Returns : The current highest position of this range, relative to the
            abs_seq_id.
  Args    : [optional] either 'stranded' or 'plus'

  This will return either abs_start() or abs_end(), depending on which
  is higher.

  The returned position will be given in minus-strand coordinates if
  this RelRangeI's position_policy is 'stranded', which is the default
  value.  If the argument to this method is a position policy (either
  'stranded' or 'plus') then this policy will be used instead of the
  object's overall policy.

  This method is implemented in the interface, and need not be
  overridden in concrete subclasses.

=cut

sub abs_high {
  my $self = shift;
  my ( $position_policy ) = @_;
  my $a = $self->abs_start( $position_policy );
  my $b = $self->abs_end( $position_policy );
  return ( ( $a > $b ) ? $a : $b );
} # abs_high()

=head2 rel2abs

  Title   : rel2abs
  Usage   : my @abs_coords = $range->rel2abs( @rel_coords );
  Function: Convert relative coordinates into absolute coordinates
  Returns : a list of absolute coordinates
  Args    : a list of relative coordinates

  This function takes a list of positions in relative coordinates
  (relative to seq_id()), and converts them into absolute coordinates.

  Note that if absolute() is true this method still interprets
  incoming coordinates as if they were relative to what seq_id() would
  be if absolute() were false.

  This method is implemented in the interface, and need not be
  overridden in concrete subclasses.  Note that this implementation
  uses abs_start() and abs_strand(), so these methods should not be
  defined in terms of rel2abs(), lest a vicious cycle occur.

=cut

sub rel2abs {
  my $self = shift;

  my @result;

  my $abs_start = $self->abs_low();
  @result = map { $_ + $abs_start - 1 } @_;

  # if called with a single argument, caller will expect a single scalar reply
  # not the size of the returned array!
  return $result[ 0 ] if ( ( @result == 1 ) and !wantarray );
  return @result;
} # rel2abs(..)

=head2 abs2rel

  Title   : abs2rel
  Usage   : my @rel_coords = $range->abs2rel( @abs_coords )
  Function: Convert absolute coordinates into relative coordinates
  Returns : a list of relative coordinates
  Args    : a list of absolute coordinates

  This function takes a list of positions in absolute coordinates
  and converts them into relative coordinates (relative to seq_id()).

  Note that if absolute() is true this method still produces
  coordinates relative to what seq_id() would be if absolute() were
  false.

  This method is implemented in the interface, and need not be
  overridden in concrete subclasses.  Note that this implementation
  uses abs_start() and abs_strand(), so these methods should not be
  defined in terms of abs2rel(), lest a vicious cycle occur.

=cut

sub abs2rel {
  my $self = shift;
  my @result;

  my $abs_start = $self->abs_low();
  @result = map { $_ + 1 - $abs_start } @_;

  # if called with a single argument, caller will expect a single scalar reply
  # not the size of the returned array!
  return $result[ 0 ] if ( ( @result == 1 ) and !wantarray );
  return @result;
} # abs2rel(..)

=head2 rel2abs_strand

  Title   : rel2abs_strand
  Usage   : my $abs_strand = $range->rel2abs_strand( $rel_strand );
  Function: Convert a strand that is relative to seq_id() into one that
            is relative to abs_seq_id().
  Returns : a strand value (-1, 0, or 1).
  Args    : a strand value (-1, 0, or 1).

  This function takes a strand value that is relative to seq_id()
  and converts it so that it is absolute (ie. relative to abs_seq_id()).

  Note that if absolute() is true this method still interprets
  the argument strand as it were relative to what seq_id() would
  be if absolute() were false.

=cut

sub rel2abs_strand {
  shift->throw_not_implemented();
} # rel2abs_strand(..)

=head2 abs2rel_strand

  Title   : abs2rel_strand
  Usage   : my $rel_strand = $range->abs2rel_strand( $abs_strand )
  Function: Convert a strand that is relative to abs_seq_id() into one that
            is relative to seq_id().
  Returns : a strand value (-1, 0, or 1).
  Args    : a strand value (-1, 0, or 1).

  This function takes a strand value that is absolute (ie. relative to
  abs_seq_id()) and converts it so that it is relative to seq_id().

  Note that if absolute() is true this method still returns the strand
  relative to what seq_id() would be if absolute() were false.

  This method turns out to be identical to rel2abs_strand, so it is
  implemented in the interface as an inheritable alias for
  rel2abs_strand.

=cut

sub abs2rel_strand {
  shift->rel2abs_strand( @_ );
}

=head2 orientation_policy

  Title   : orientation_policy
  Usage   : my $orientation_policy =
              $range->orientation_policy( [new_policy] );
  Function: Get/Set the oriention policy that this RelRangeI uses.
  Returns : The current (or former, if used as a set method) value of
            the orientation policy.
  Args    : [optional] A new (string) orientation_policy value.

  The BioPerl community has various opinions about how coordinates
  should be returned when the strand is negative.  Some folks like the
  start to be the lesser-valued position in all circumstances
  ('independent' of the strand value).  Others like the start to be
  the lesser-valued position when the strand is 0 or 1 and the
  greater-valued position when the strand is -1 ('dependent' on the
  strand value).  Others expect that the start and end values are
  whatever they were set to ('ignorant' of the strand value).

  Legal values of orientation_policy are:
      Value          Assertion
   ------------   -------------------
   'independent'  ( start() <= end() )
   'dependent'    (( strand() < 0 )?( end() <= start() ):( start() <= end() ))
   'ignorant'     # No assertion.

  See also ensure_orientation().  Note that changing the
  orientation_policy will not automatically ensure that the
  orientation policy assertion holds, so you should call
  ensure_orientation() also.

=cut

sub orientation_policy {
  shift->throw_not_implemented();
}

=head2 ensure_orientation

  Title   : ensure_orientation
  Usage   : $range->ensure_orientation();
  Function: After calling this method, the orientation_policy assertion
            will be true.
  Returns : nothing
  Args    : none

  The orientation_policy is an assertion about the relative values of
  the start() and end() positions.  This assertion might fail when the
  start and end positions change.  This method reorients the values in
  case the assertion fails.  After calling this method the assertion
  will be true.

=cut

sub ensure_orientation {
  shift->throw_not_implemented();
}

=head2 position_policy

  Title   : position_policy
  Usage   : my $position_policy =
              $range->position_policy( [new_policy] );
  Function: Get/Set the position policy that this RelRangeI uses.
  Returns : The current (or former, if used as a set method) value of
            the position policy.
  Args    : [optional] A new (string) position_policy value.

  The BioPerl community has various opinions about how 
  positions should be interpreted when the strand is
  negative.  Some folks like the values to be relative to the minus
  strand, so that the first on the minus strand is the complement of
  the last position on the plus strand (we call this the 'stranded'
  policy).  Others like positions to be always given on the
  plus strand, so that the first position on the minus strand is the
  complement of the first position on the plus strand (we call this
  the 'plus' policy).

  Legal values of abs_minus_policy are:
      Value          Meaning
   ------------   ---------------------

   'stranded'     positions are given on the + strand except when the
                  range is on the - strand; when the range is on the -
                  strand the positions are given on the - strand. (default)
   'plus'         positions are always given on the + strand

=cut

sub position_policy {
  shift->throw_not_implemented();
}

=head1 Bio::RangeI methods

These methods are inherited from L<Bio::RangeI>.  Changes between this
interface and that one are noted in the pod, but to be sure you might
want to check L<Bio::RangeI> in case they have gotten out of sync.

=cut

#                   --Coders beware!--
# Changes to the Bio::RangeI pod need to be copied to here.

=head2 seq_id

  Title   : seq_id
  Usage   : my $seq_id = $range->seq_id( [new_seq_id] );
  Function: Get/Set a unique_id or primary_id of a L<Bio::PrimarySeqI>
            or another L<Bio::RangeI> that this RangeI is defined
            over or relative to.  If absolute() is true, this will be
            identical to abs_seq_id().
  Returns : The current (or former, if used as a set method) value of
            the seq_id.
  Args    : [optional] A new (string or L<Bio::RangeI> seq_id value

  Ranges may have no defined seq_id, but this should be considered
  deprecated.  The concept of a 'range' requires that it is a range
  over some sequence; this method returns (and optionally sets) that
  sequence.  It is also possible to specify another range, to support
  relative ranges.  If the value of seq_id is another L<Bio::RangeI>,
  then this RelRangeI's positions are relative to that RangeI's
  positions (unless absolute() is true, in which case they are
  relative to the root seq_id).  If seq_id is the id of a sequence then
  it should provide enough information for a user of a RelRangeI to
  retrieve that sequence; ideally it should be a
  L<Bio::GloballyIdentifiableI> unique_id.

  You may not set the seq_id when absolute() is true.

  The behavior of this method differs from its behavior in
  L<Bio::RangeI> when absolute() is true.

=cut

sub seq_id {
  shift->throw_not_implemented();
}

=head2 start

  Title   : start
  Usage   : my $start = $range->start( [$position_policy|$new_start] );
  Function: Get/set the start of this range.
  Returns : The current (or former, if used as a set method) start position
            of this range.  If absolute() is true then this value will
            be relative to the abs_seq_id; otherwise it will be
            relative to the seq_id.
  Args    : [optional] a new start position OR either 'stranded' or 'plus'

  Note the interdependence of start() and abs_start().  Changing start() will
  change abs_start().

  You may not set start() when absolute() is true.

  Note the interdependence of start() and length().  Changing start() will
  change length().

  The returned position will be given in minus-strand coordinates if
  this RelRangeI's position_policy is 'stranded', which is the default
  value.  If the argument to this method is a position policy (either
  'stranded' or 'plus') then this policy will be used instead of the
  object's overall policy.

  The behavior of this method differs from its behavior in
  L<Bio::RangeI> when absolute() is true.  Also, the RangeI interface
  does not specify whether the return value should be the new value or
  the old value.  This interface specifies that it should be the old
  value.

=cut

sub start {
  shift->throw_not_implemented();
}

=head2 end

  Title   : end
  Usage   : my $end = $range->end( [$position_policy|$new_end] );
  Function: Get/set the end of this range.
  Returns : The current (or former, if used as a set method) end position
            of this range.  If absolute() is true then this value will
            be relative to the abs_seq_id; otherwise it will be
            relative to the seq_id.
  Args    : [optional] a new end position OR 'stranded' or 'plus'

  Note the interdependence of end() and abs_end().  Changing end() will
  change abs_end().

  You may not set end() when absolute() is true.

  Note the interdependence of end() and length().  Changing one will
  change the other.

  The returned position will be given in minus-strand coordinates if
  this RelRangeI's position_policy is 'stranded', which is the default
  value.  If the argument to this method is a position policy (either
  'stranded' or 'plus') then this policy will be used instead of the
  object's overall policy.

  The behavior of this method differs from its behavior in
  L<Bio::RangeI> when absolute() is true.  Also, the RangeI interface
  does not specify whether the return value should be the new value or
  the old value.  This interface specifies that it should be the old
  value.

=cut

sub end {
  shift->throw_not_implemented();
}

=head2 strand

  Title   : strand
  Usage   : my $strand = $range->strand( [$new_strand] );
  Function: Get/set the strandedness (-1, 0, or 1) of this range.
  Returns : The current (or former, if used as a set method) strand value
            of this range.  If absolute() is true then this value will
            be absolute.  Otherwise it will be relative to the
            strandedness (if any) of seq_id.
  Args    : [optional] a new strand value.

  You may not set strand() when absolute() is true.

  The behavior of this method differs from its behavior in
  L<Bio::RangeI> when absolute() is true.  Also, the RangeI interface
  does not specify whether the return value should be the new value or
  the old value.  This interface specifies that it should be the old
  value.

=cut

sub strand {
  shift->throw_not_implemented();
}

=head2 length

  Title   : length
  Usage   : my $length = $range->length( [$new_length] );
  Function: Get/set the length of this range.
  Returns : The current (or former, if used as a set method) length
            of this range.
  Args    : [optional] a new length

  length = ( ( abs_high - abs_low ) + 1 ).

  Note the interdependence of start()|end()|abs_start()|abs_end() and
  length().  Changing start() or end() will change the length.
  Changing the length will change the end() (and consequently abs_end()).

  You may not set the length when absolute() is true.

  This method differs from L<Bio::RangeI> in that it here accepts an
  argument to modify the length.  If the length is modified then the
  return value will be the former length.

=cut

sub length {
  shift->throw_not_implemented();
}

=head2 overlaps

  Title   : overlaps
  Usage   : if( $r1->overlaps( $r2 ) ) { do stuff }
  Function: tests if $r2 overlaps $r1
  Args    : arg #1 = a L<Bio::RangeI> to compare this one to (mandatory)
            arg #2 = strand option ('strong', 'weak', 'ignore') (optional)
  Returns : true if the ranges overlap, false otherwise

  The second argument's values may be:
   "strong"        ranges must have the same strand
   "weak"          ranges must have the same strand or no strand
   "ignore"        ignore strand information (default)

  The behavior of this method differs from its behavior in
  L<Bio::RangeI> when the other range is also a RelRangeI.  When both
  are RelRangeI objects, the abs_seq_ids must be the same and
  absolute coordinates are always used for the test.  If either range
  has no defined abs_seq_id then abs_seq_id will be ignored in the test.

  This method is implemented in the interface, and need not be
  overridden in concrete subclasses.

=cut

sub overlaps {
  my $self = shift;
  my ( $other, $strand_option ) = @_;
  if( defined( $other ) && $other->isa( 'Bio::RelRangeI' ) ) {
    return (
            $self->_absTestStrand( $other, $strand_option ) and
            ( ( defined( $self->abs_seq_id() ) &&
                defined( $other->abs_seq_id() ) ) ?
              ( $self->abs_seq_id() eq $other->abs_seq_id() ) : 1 ) and
            not (
                 ( $self->abs_low( 'plus' ) > $other->abs_high( 'plus' ) or
                   $self->abs_high( 'plus' ) < $other->abs_low( 'plus' ) ) )
           );
  } else {
    return $self->SUPER::overlaps(@_);
  }
} # overlaps(..)

=head2 contains

  Title   : contains
  Usage   : if( $r1->contains( $r2 ) ) { do stuff }
  Function: tests if $r2 is totally contained within $r1
  Args    : arg #1 = a L<Bio::RangeI> to compare this one to,
                     or an integer position (mandatory)
            arg #2 = strand option ('strong', 'weak', 'ignore') (optional)
  Returns : true iff this range wholly contains the given range

  The second argument's values may be:
   "strong"        ranges must have the same strand
   "weak"          ranges must have the same strand or no strand
   "ignore"        ignore strand information (default)

  The behavior of this method differs from its behavior in
  L<Bio::RangeI> when the other range is also a RelRangeI.  When both
  are RelRangeI objects, the abs_seq_ids must be the same and
  absolute coordinates are always used for the test.  If either range
  has no defined abs_seq_id then abs_seq_id will be ignored in the test.

  This method is implemented in the interface, and need not be
  overridden in concrete subclasses.

=cut

sub contains {
  my $self = shift;
  my ( $other, $strand_option ) = @_;
  if( defined( $other ) && $other->isa( 'Bio::RelRangeI' ) ) {
    return (
            $self->_absTestStrand( $other, $strand_option ) and
            ( ( defined( $self->abs_seq_id() ) &&
                defined( $other->abs_seq_id() ) ) ?
              ( $self->abs_seq_id() eq $other->abs_seq_id() ) : 1 ) and
            ( $self->abs_low( 'plus' ) <= $other->abs_low( 'plus' ) ) and
            ( $self->abs_high( 'plus' ) >= $other->abs_high( 'plus' ) )
           );
  } else {
    return $self->SUPER::contains(@_);
  }
} # contains(..)

=head2 equals

  Title   : equals
  Usage   : if( $r1->equals( $r2 ) ) { do something }
  Function: Test whether $r1 has the same abs_start, abs_end, length,
            and abs_seq_id as $r2.
  Args    : arg #1 = a L<Bio::RangeI> to compare this one to (mandatory)
            arg #2 = strand option ('strong', 'weak', 'ignore') (optional)
  Returns : true iff they are describing the same range

  If either range has no defined (abs) seq_id then (abs) seq_id will
  be ignored in the test.

  The behavior of this method differs from its behavior in
  L<Bio::RangeI> when the other range is a RelRangeI.  When both
  are RelRangeI objects, the abs_seq_ids must be the same (instead of
  the seq_ids) and absolute coordinates are always used for the test.

  This method is implemented in the interface, and need not be
  overridden in concrete subclasses.

=cut

sub equals {
  my $self = shift;
  my ( $other, $strand_option ) = @_;
  if( defined( $other ) && ref( $other ) && $other->isa( 'Bio::RelRangeI' ) ) {
    return (
            $self->_absTestStrand( $other, $strand_option ) and
            ( ( defined( $self->abs_seq_id() ) &&
                defined( $other->abs_seq_id() ) ) ?
              ( $self->abs_seq_id() eq $other->abs_seq_id() ) : 1 ) and
            ( $self->abs_low( 'plus' ) == $other->abs_low( 'plus' ) ) and
            ( $self->abs_high( 'plus' ) == $other->abs_high( 'plus' ) )
           );
  } else {
    return $self->SUPER::equals( @_ );
  }
} # equals(..)

# This is used for overriding 'eq'.
sub eq {
  my $self = shift;
  my ( $other, $reversed ) = @_;

  # Ignore the reversal.
  return $self->equals( $other );
} # eq(..)

## utility methods for testing absolute strand equality

# works out what test to use for the strictness and returns true/false
# e.g. $r1->_absTestStrand( $r2, 'strong' )
sub _absTestStrand {
  my ( $r1, $r2, $comp ) = @_;
  return 1 unless $comp;
  my $func = $ABS_STRAND_OPTIONS{ $comp };
  return $r1->$func( $r2 );
}

# returns true if abs_strands are equal and non-zero
sub _abs_strong {
  my ( $r1, $r2 ) = @_;
  my ( $s1, $s2 );
  unless( $r1 && ref( $r1 ) && $r1->isa( 'Bio::RangeI' ) ) {
    return 0;
  }
  unless( $r2 && ref( $r2 ) && $r2->isa( 'Bio::RangeI' ) ) {
    return 0;
  }

  ## TODO: Note that this code is duplicated in RelRange::absStrong.
  ## It used to be consolodated there but the circular includes were
  ## confusing the perl interpreter (occasionally), since RelRangeI
  ## uses RelRange's absStrand function, but RelRange uses RelRangeI
  ## (it ISA RelRangeI)...
  if( ref( $r1 ) && $r1->isa( 'Bio::RelRangeI' ) ) {
    $s1 = $r1->abs_strand();
  } else {
    ## Okay so it's a RangeI but not a RelRangeI.
    my $seq_id = $r1->seq_id();
    my $abs_strand = $r1->strand();
    while( defined( $seq_id ) &&
           ref( $seq_id ) &&
           $seq_id->isa( 'Bio::RangeI' ) ) {
      unless( $abs_strand ) {
        return $abs_strand;
      }
      $abs_strand *= $seq_id->strand();
      $seq_id = $seq_id->seq_id();
    }
    $s1 = $abs_strand;
  }
  if( $s1 == 0 ) {
    return 0;
  }
  if( ref( $r2 ) && $r2->isa( 'Bio::RelRangeI' ) ) {
    $s2 = $r2->abs_strand();
  } else {
    ## Okay so it's a RangeI but not a RelRangeI.
    my $seq_id = $r2->seq_id();
    my $abs_strand = $r2->strand();
    while( defined( $seq_id ) &&
           ref( $seq_id ) &&
           $seq_id->isa( 'Bio::RangeI' ) ) {
      unless( $abs_strand ) {
        return $abs_strand;
      }
      $abs_strand *= $seq_id->strand();
      $seq_id = $seq_id->seq_id();
    }
    $s2 = $abs_strand;
  }
    
  return ( $s1 == $s2 );
} # _abs_strong

# returns true if abs_strands are equal or either is zero
sub _abs_weak {
  my ( $r1, $r2 ) = @_;
  my ( $s1, $s2 );
  unless( $r1 && ref( $r1 ) && $r1->isa( 'Bio::RangeI' ) ) {
    return 0;
  }
  unless( $r2 && ref( $r2 ) && $r2->isa( 'Bio::RangeI' ) ) {
    return 0;
  }

  ## TODO: Note that this code is duplicated in RelRange::absStrong.
  ## It used to be consolodated there but the circular includes were
  ## confusing the perl interpreter (occasionally), since RelRangeI
  ## uses RelRange's absStrand function, but RelRange uses RelRangeI
  ## (it ISA RelRangeI)...
  if( ref( $r1 ) && $r1->isa( 'Bio::RelRangeI' ) ) {
    $s1 = $r1->abs_strand();
  } else {
    ## Okay so it's a RangeI but not a RelRangeI.
    my $seq_id = $r1->seq_id();
    my $abs_strand = $r1->strand();
    while( defined( $seq_id ) &&
           ref( $seq_id ) &&
           $seq_id->isa( 'Bio::RangeI' ) ) {
      unless( $abs_strand ) {
        return $abs_strand;
      }
      $abs_strand *= $seq_id->strand();
      $seq_id = $seq_id->seq_id();
    }
    $s1 = $abs_strand;
  }
  if( $s1 == 0 ) {
    return 1;
  }
  if( ref( $r2 ) && $r2->isa( 'Bio::RelRangeI' ) ) {
    $s2 = $r2->abs_strand();
  } else {
    ## Okay so it's a RangeI but not a RelRangeI.
    my $seq_id = $r2->seq_id();
    my $abs_strand = $r2->strand();
    while( defined( $seq_id ) &&
           ref( $seq_id ) &&
           $seq_id->isa( 'Bio::RangeI' ) ) {
      unless( $abs_strand ) {
        return $abs_strand;
      }
      $abs_strand *= $seq_id->strand();
      $seq_id = $seq_id->seq_id();
    }
    $s2 = $abs_strand;
  }
  if( $s2 == 0 ) {
    return 1;
  }
  return ( $s1 == $s2 );
} # _abs_weak

# returns true always
sub _abs_ignore {
  return 1;
} # _abs_ignore

=head2 intersection

  Title   : intersection
  Usage   : my $intersection_range = $r1->intersection( $r2 ) (scalar context)
            OR
            my ( $start, $end, $strand ) = $r1->intersection( $r2 )
             (list context)
  Function: gives the range that is contained by both ranges
  Args    : arg #1 = a range to compare this one to (mandatory)
            arg #2 = strand option ('strong', 'weak', 'ignore') (optional)
  Returns : undef if they do not overlap,
            or new range object containing the overlap
            or (in list context) the start, end, and strand of that range.

  The behavior of this method differs from its behavior in
  L<Bio::RangeI> when the other range is also a RelRangeI.  When both
  are RelRangeI objects abs_seq_ids must not be different and
  absolute coordinates are always used.  The returned object will have
  as its seq_id the abs_seq_id of this range (or, if that is undef, the
  abs_seq_id of the other range).

  This method is implemented in the interface, and need not be
  overridden in concrete subclasses.

=cut

sub intersection {
  my $self = shift;
  my ( $other, $strand_option ) = @_;

  if( $other->isa( 'Bio::RelRangeI' ) ) {
    unless( $self->_absTestStrand( $other, $strand_option ) &&
            ( ( defined( $self->abs_seq_id() ) &&
                defined( $other->abs_seq_id() ) ) ?
              ( $self->abs_seq_id() eq $other->abs_seq_id() ) : 1 ) ) {
      return undef;
    }

    my @low = sort { $a <=> $b } ( $self->abs_low( 'plus' ), $other->abs_low( 'plus' ) );
    my @high   = sort { $a <=> $b } ( $self->abs_high( 'plus' ), $other->abs_high( 'plus' ) );

    my $low = pop @low;
    my $high = shift @high;
    if( $low > $high ) {
      return undef;
    }

    if( wantarray ) {
      return ( $low, $high, ( ( $self->strand() == $other->strand() ) ?
                              $self->strand() : 0 ) );
    }
    return $self->new( '-seq_id' =>
                         ( defined( $self->abs_seq_id() ) ?
                           $self->abs_seq_id() :
                           $other->abs_seq_id() ),
                       '-start' => $low,
                       '-end' => $high,
                       '-strand' =>
                         ( ( $self->strand() == $other->strand() ) ?
                           $self->strand() :
                           0 )
                     );
  } else {
    return $self->SUPER::intersection( @_ );
  }
} # intersection(..)

=head2 union

  Title   : union
  Usage   : my $union_range = $r1->union( @other_ranges ); (scalar context)
            OR
            my ( $start, $end, $strand ) = $r1->union( @other_ranges );
              (list context)
            OR
            my $union_range = Bio::RelRangeI->union( @ranges );
              (scalar context)
            OR
            my ( $start, $end, $strand ) = Bio::RelRangeI->union( @ranges );
              (list context)
  Function: finds the minimal range that contains all of the ranges
  Args    : a range or list of ranges to find the union of
  Returns : a new range object that contains all of the given ranges, or
            (in list context) the start, end, and strand of that range object.

  The behavior of this method differs from its behavior in
  L<Bio::RangeI> when another range is also a RelRangeI.  When both
  are RelRangeI objects abs_seq_ids must not be different and
  absolute coordinates are always used.  RangeIs may be given, mixed
  with RelRangeIs, but they will be treated as if they were RelRangeIs
  with absolute() set to true.  The returned object will have
  as its seq_id the abs_seq_id of this range (or, if that is undef, the
  abs_seq_id of the first other range with one defined).

  This method is implemented in the interface, and need not be
  overridden in concrete subclasses.

=cut

sub union {
  my $self = shift;
  my @ranges = @_;
  if( ref( $self ) ) {
    unshift( @ranges, $self );
  }

  my ( $abs_seq_id, $union_strand, $low, $high );
  foreach my $range ( @ranges ) {
    next unless(
                defined( $range ) &&
                ref( $range ) &&
                $range->isa( 'Bio::RangeI' )
               );
    if( defined( $union_strand ) ) {
      if( $union_strand != $range->strand() ) {
        $union_strand = 0;
      }
    } else {
      $union_strand = $range->strand();
    }
    if( $range->isa( 'Bio::RelRangeI' ) ) {
      if( defined( $abs_seq_id ) &&
          defined( $range->abs_seq_id() ) &&
          ( $abs_seq_id ne $range->abs_seq_id() )
        ) {
        $self->throw( "At least one of the given RelRangeI objects has an incompatible abs_seq_id() value." );
      }
      unless( defined( $abs_seq_id ) ) {
        $abs_seq_id = $range->abs_seq_id();
      }
      if( !defined( $low ) or ( $low > $range->abs_low( 'plus' ) ) ) {
        $low = $range->abs_low( 'plus' );
      }
      if( !defined( $high ) or ( $high < $range->abs_high( 'plus' ) ) ) {
        $high = $range->abs_high( 'plus' );
      }
    } else { # It's not a RelRangeI; must be a RangeI.  Assume absoluteness.
      if( defined( $abs_seq_id ) &&
          defined( $range->seq_id() ) &&
          ( $abs_seq_id ne $range->seq_id() )
        ) {
        $self->throw( "At least one of the given RangeI objects has an incompatible seq_id() value.  It must be the same as the abs_seq_id() value of this RelRangeI object." );
      }
      unless( defined( $abs_seq_id ) ) {
        $abs_seq_id = $range->seq_id();
      }
      if( !defined( $low ) or ( $low > $range->start() ) ) {
        $low = $range->start();
      }
      if( !defined( $high ) or ( $high < $range->end() ) ) {
        $high = $range->end();
      }
    }
  }
  if( wantarray ) {
    return ( $low, $high, $union_strand );
  }
  return $self->new( -seq_id => $abs_seq_id,
	             -start  => $low,
	             -end    => $high,
                     -strand => $union_strand
                   );
} # union(..)

=head2 overlap_extent

 Title   : overlap_extent
 Usage   : my ( $a_unique, $common, $b_unique ) = $a->overlap_extent( $b );
 Function: Provides actual amount of overlap between two different ranges.
 Returns : 3-tuple consisting of:
           - the number of positions unique to a
           - the number of positions common to both
           - the number of positions unique to b
 Args    : a L<Bio::RangeI> object

  The behavior of this method differs from its behavior in
  L<Bio::RangeI> when the other range is also a RelRangeI.  When both
  are RelRangeI objects abs_seq_ids must not be different and
  absolute coordinates are always used.

  This method is implemented in the interface, and need not be
  overridden in concrete subclasses.

=cut

sub overlap_extent {
  my $self = shift;
  my ( $other ) = @_;

  if( $other->isa( 'Bio::RelRangeI' ) ) {
    unless( $self->overlaps( $other ) ) {
      return ( $self->length(), 0 , $other->length() );
    }

    my ( $self_unique, $other_unique );
    if( $self->abs_low( 'plus' ) < $other->abs_low( 'plus' ) ) {
      $self_unique = $other->abs_low( 'plus' ) - $self->abs_low( 'plus' );
    } else {
      $other_unique = $self->abs_low( 'plus' ) - $other->abs_low( 'plus' );
    }

    if( $self->abs_high( 'plus' ) > $other->abs_high( 'plus' ) ) {
      $self_unique += $self->abs_high( 'plus' ) - $other->abs_high( 'plus' );
    } else {
      $other_unique += $other->abs_high( 'plus' ) - $self->abs_high( 'plus' );
    }
    my $intersection = $self->intersection( $other );
    
    return (
            $self_unique,
            ( 1 + $intersection->end( 'plus' ) - $intersection->start( 'plus' ) ),
            $other_unique
           );
  } else {
    return $self->SUPER::overlap_extent( @_ );
  }
} # overlap_extent(..)

## Alias for toRelRangeString().
sub toString {
  shift->toRelRangeString( @_ );
} # toString(..)

=head2 toRelRangeString

 Title   : toRelRangeString
 Usage   : my $string = $range->toRelRangeString( [ $absolute [, $position_policy ] ] );
 Function: Returns a string representation of this RelRange object.
 Returns : a string
 Args    : [optional] a boolean absolute argument; when true this method
           will return the string representation of the absolute
           interpretation of this RelRange (as if the absolute() flag
           had been set to true before the call, even if it wasn't).
           If the absolute argument is the string 'both', the relative
           string value will be given, followed by the absolute
           interpretation in braces.
             AND
           [optional] a boolean position_policy argument (either
           'stranded' or 'plus').  This will override the object's
           position policy.

  Note that this method may be called on any Bio::RangeI implementing
  object by calling Bio::RelRangeI::toRelRangeString( $range [,
  $absolute] ).  If this is done on a range that is not a
  Bio::RelRangeI implementer, the string output will look the same as
  if a new RelRange object had been created to represent the given
  range.

  This method is implemented in the interface, and need not be
  overridden in concrete subclasses.

=cut
#'

## TODO: We don't use the position policy when the given range is not a RelRange.
sub toRelRangeString {
  my $self = shift;
  my ( $absolute, $position_policy ) = @_;
  unless( $position_policy && ( $position_policy =~ /^stranded|plus$/ ) ) {
    $position_policy = $self->position_policy();
  }

  ## Special case handling: maybe $self isn't a RelRangeI, but just a RangeI.
  unless( $self->isa( 'Bio::RelRangeI' ) ) {
    if( $self->isa( 'Bio::RangeI' ) ) {
      my $strand = $self->strand();
      my $strand_string;
      if( $strand > 0 ) {
        $strand_string = '+';
      } elsif( $strand < 0 ) {
        $strand_string = '-';
      } else {
        $strand_string = '.';
      }
      if( $absolute eq 'both' ) {
        ## This is kinda silly because the absolute interpretation is
        ## the same as the relative interpretation, but we promise to
        ## do the exact same thing when the range is just a mere
        ## RangeI as when it's a supersuave RelRangeI, so la de da.
        return $self->seq_id().'('.$strand_string.'):'.$self->start().'-'.$self->end().'{'.$self->seq_id().'('.$strand_string.'):'.$self->start().'-'.$self->end().'}';
      } else {
        return $self->seq_id().'('.$strand_string.'):'.$self->start().'-'.$self->end();
      }
    } else {
      Bio::Root::RootI->throw( "Bio::RelRangeI::toRelRangeString(..) called on an object that is not a Bio::RangeI object!  \$self is $self, not a Bio::RelRangeI but a ".ref( $self )."." );
    }
  }
  if( $absolute eq 'both' ) {
    ## This one shows the absolute interpretation alongside the relative one:
    return $self->seq_id().'('.$self->strand_string().'):'.$self->start( $position_policy ).'-'.$self->end( $position_policy ).'{'.$self->abs_seq_id().'('.$self->strand_string( $self->abs_strand() ).'):'.$self->abs_start( $position_policy ).'-'.$self->abs_end( $position_policy ).'}';
  } elsif( $absolute ) {
    ## This one shows the absolute interpretation only:
    return $self->abs_seq_id().'('.$self->strand_string( $self->abs_strand() ).'):'.$self->abs_start( $position_policy ).'-'.$self->abs_end( $position_policy );
  } else {
    ## This one shows the relative interpretation only:
    return $self->seq_id().'('.$self->strand_string().'):'.$self->start( $position_policy ).'-'.$self->end( $position_policy );
  }
} # toRelRangeString(..)

## For debugging, show the relative range in stranded coords and the absolute range in plus coords.
sub debugRelRangeString {
  my $self = shift;
  #return $self->toRelRangeString( 0, 'stranded' ).'{'.$self->toRelRangeString( 1, 'plus' ).'}';
  return $self->toRelRangeString( 0, 'stranded' ).'{'.$self->toRelRangeString( 1, 'stranded' ).'}';
}

## TODO: Document & dehackify
sub strand_string {
  my $self = shift;
  my $strand = shift || $self->strand();
  if( $strand > 0 ) {
    return '+';
  } elsif( $strand < 0 ) {
    return '-';
  } else {
    return '.';
  }
} # strand_string(..)

sub DESTROY {
  # Because we're a Class::Observable
  shift->delete_observers();
} # DESTROY()

1;

__END__
