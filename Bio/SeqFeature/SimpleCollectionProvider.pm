package Bio::SeqFeature::SimpleCollectionProvider;

# $Id $

=head1 NAME

Bio::SeqFeature::SimpleCollectionProvider - An in-memory
implementation of the CollectionProviderI interface.

=head1 SYNOPSIS

  my $provider = new Bio::SeqFeature::SimpleCollectionProvider();
  my $fg_color = $provider->get( 'fgcolor' );

=head1 DESCRIPTION

A SimpleCollectionProvider is an in-memory store of SeqFeatureIs that
implements the CollectionProviderI interface.  It supports updating,
adding, and removing SeqFeatures in its store, although explicit
updating is unnecessary as the SeqFeatureIs returned by the
get_collection method are the same as those stored herein (ie. there
is no external backing store).

Features can be filtered by the following attributes:

  1) their location, perhaps relative to a range (with a choice
     between overlapping, contained within, or completely containing a
     range)

  2) their type

  3) other attributes using tag/value semantics

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

=head1 APPENDIX

The rest of the documentation details each of the object methods.
Internal methods are usually preceded with a _

=cut

# Let the code begin...

use strict;
use vars qw( $VERSION @ISA );
use overload 
  '""' => 'toString',
  cmp   => '_cmp';

$VERSION = '0.01';
@ISA = qw( Bio::Root::Root Bio::SeqFeature::CollectionProviderI );

=head2 new

 Title   : new
 Usage   : my $obj =
             new Bio::SeqFeature::SimpleCollectionProvider( @features );
 Function: Builds a new Bio::SeqFeature::SimpleCollectionProvider object 
 Returns : Bio::SeqFeature::SimpleCollectionProvider
 Args    : SeqFeatureI objects to store herein

=cut

sub new {
  my( $class, @args ) = @_;

  my $self = $class->SUPER::new( @args );
  $self->{ '_identifiable_features' } = {};
  $self->{ '_anonymous_features' } = {};

  if( scalar( @args ) ) {
    foreach my $feature ( @args ) {
      unless( $self->_insert_feature( $feature ) ) {
        $self->throw( "duplicate feature: $feature" );
      }
    }
  }
  return $self;
} # new(..)

=head2 get_collection

 Title   : get_collection
 Usage   : my $collection = $collectionprovider->get_collection( @args );
 Returns : A L<Bio::SeqFeature::CollectionI> object
 Args    : see below
 Status  : Public

This routine will retrieve a L<Bio::SeqFeature::CollectionI> object
based on feature type, location or attributes.  The SeqFeatureI
objects in the returned CollectionI may or may not be newly
instantiated by this request.  If you make a modification to a feature
you must call update_collection with a collection that contains that
feature to ensure that the data provider is in sync with your change.
You may not, however, assume that modifications to the feature do not
auto-sync (they might!).  This simple implementation will auto-sync,
although subclasses may not.

If a range is specified using the -range argument then this range will
 be used to narrow the results, according to the specified -rangetype
 and -strandtype arguments.

-rangetype is one of:
   "overlaps"      return all features that overlap the range (default)
   "contains"      return features completely contained within the range
   "contained_in"  return features that completely contain the range

Note that if the implementing class implements RangeI then the
baselocation will default to that range.  If a baselocation is given
or defaulted and a range is specified as an argument, then the
coordinates of the given range will be interpreted relative to the
implementing class\'s range.  If the implementing class does not
implement RangeI and no range is given, then -rangetype may be
ignored.

-strandmatch is one of:
   "strong"        ranges must have the same strand
                   (default ONLY when -strand is specified and non-zero)
   "weak"          ranges must have the same strand or no strand
   "ignore"        ignore strand information
                   (default unless -strand is specified and non-zero)

Two types of argument lists are accepted.  In the positional argument
form, the arguments are treated as a list of feature types.  In the
named parameter form, the arguments are a series of -name=E<gt>value
pairs.

  Argument       Description
  --------       ------------

  -type          A type name or an object of type Bio::SeqFeature::TypeI
  -types         An array reference to multiple type names or TypeI objects

  -attributes    A hashref containing a set of attributes to match.  See
                 below.

  -location      A Bio::LocationI object defining the range to search and
                 the rangetype.  Use -range (and -baselocation,
                 perhaps; see below) as an alternative to -location.
                 See also -strandmatch.  There may be a default value
                 for -location.

  -baselocation  A Bio::LocationI object defining the location to which
                 the -range argument is relative.  There may be a
                 default -baselocation.  If this CollectionI is also a
                 Bio::RangeI, then the default -baselocation should be
                 its range.

  -range         A Bio::RangeI object defining the range to search.  See also
                 -strandmatch and -rangetype.  Use instead of
                 -location, when -baselocation is specified or
                 provided by default (see above).

  -rangetype     One of "overlaps", "contains", or "contained_in".

  -strandmatch   One of "strong", "weak", or "ignore".

The -attributes argument is a hashref containing one or more
attributes to match against:

  -attributes => { Gene => 'abc-1',
                   Note => 'confirmed' }

Attribute matching is simple string matching, and multiple attributes
are ANDed together.

=cut

sub get_collection {
  ## TODO: ERE I AM
} # get_collection(..)

=head2 insert_or_update_collection

 Title   : insert_or_update_collection
 Usage   : $collectionprovider->insert_or_update( $collection );
 Function: Attempts to update all the features of a collection.  If
           a feature doesn\'t exist it inserts it automatically.
 Returns : None
 Args    : L<Bio::SeqFeature::CollectionI> object

=cut

sub insert_or_update_collection {
  my $self = shift;
  my $collection = shift;

  return unless defined( $collection );

  my $iterator = $collection->get_feature_stream();
  my $feature;
  while( $iterator->has_more_features() ) {
    $feature = $iterator->next_feature();
    $self->_insert_or_update_feature( $feature );
  }
} # insert_or_update_collection(..)

=head2 insert_collection

 Title   : insert_collection
 Usage   : $collectionprovider->insert_collection($collection);
 Function: Insert all the features of a collection.  If any features
           already exist throw an exception. 
 Returns : None
 Args    : L<Bio::SeqFeature::CollectionI> object

=cut

sub insert_collection {
  my $self = shift;
  my $collection = shift;

  return unless defined( $collection );

  my $iterator = $collection->get_feature_stream();
  my $feature;
  while( $iterator->has_more_features() ) {
    $feature = $iterator->next_feature();
    unless( $self->_insert_feature( $feature ) ) {
      $self->throw( "duplicate feature: $feature" );
    }
  }
} # insert_collection(..)

=head2 update_collection

 Title   : update_collection
 Usage   : $collectionprovider->update_collection($collection);
 Function: Updates all the features of a collection.  If any do not
           already exist throw an exception.
 Returns : Return the updated collection upon success or undef
           upon failure.
 Args    : L<Bio::SeqFeature::CollectionI> object

  If you make a modification to a feature you must call
  update_collection with a collection that contains that feature to
  ensure that the data provider is in sync with your change.  You may
  not, however, assume that modifications to the feature do not
  auto-sync (they might!).

=cut

sub update_collection {
  my $self = shift;
  my $collection = shift;

  return unless defined( $collection );

  my $iterator = $collection->get_feature_stream();
  my $feature;
  while( $iterator->has_more_features() ) {
    $feature = $iterator->next_feature();
    unless( $self->_update_feature( $feature ) ) {
      $self->throw( "nonexistent feature: $feature" );
    }
  }
} # update_collection(..)

=head2 remove_collection

 Title   : remove_collection
 Usage   : $provider->remove_collection($collection);
 Function: Removes all the features in a collection.  If any features 
           do not exists throw an exception.
 Returns : None
 Args    : L<Bio::SeqFeature::CollectionI> object

=cut

sub remove_collection {
  my $self = shift;
  my $collection = shift;

  return unless defined( $collection );

  my $iterator = $collection->get_feature_stream();
  my $feature;
  while( $iterator->has_more_features() ) {
    $feature = $iterator->next_feature();
    unless( $self->_remove_feature( $feature ) ) {
      $self->throw( "nonexistent feature: $feature" );
    }
  }
} # remove_collection(..)

=head2 _insert_feature

 Title   : _insert_feature
  Usage   : $provider->_insert_feature( $feature );
 Function: Inserts the given feature into the store.
 Args    : L<Bio::SeqFeatureI> object
 Returns : False iff the feature already existed.
 Status  : Protected

=cut

sub _insert_feature {
  my $self = shift;
  my $feature = shift;

  if( defined( $feature->unique_id() ) ) {
    if( $self->{ '_identifiable_features' }{ $feature->unique_id() } ) {
      return 0;
    } else {
      $self->{ '_identifiable_features' }{ $feature->unique_id() } =
        $feature;
      return 1;
    }
  } else { # it does not have a unique id.  Store it by start location.
    my $features_that_start_where_this_one_does =
      $self->{ '_anonymous_features' }{ $feature->start() };
    if( $features_that_start_where_this_one_does &&
        scalar( @$features_that_start_where_this_one_does ) ) {
      foreach my $other_feature ( @$features_that_start_where_this_one_does ) {
        if( ( $other_feature == $feature )
            ||
            $other_feature->equals( $feature )
          ) {
          return 0;
        }
      }
      push( @$features_that_start_where_this_one_does, $feature );
      return 1;
    } else {
      $self->{ '_anonymous_features' }{ $feature->start() } = [ $feature ];
      return 1;
    }
  }
} # _insert_feature(..)

=head2 _update_feature

 Title   : _update_feature
 Usage   : $provider->_update_feature( $feature );
 Function: Updates the given feature in the store.
 Args    : L<Bio::SeqFeatureI> object
 Returns : False iff the feature is not in the store (it won\'t be added!)
 Status  : Protected

=cut

sub _update_feature {
  my $self = shift;
  my $feature = shift;

  if( defined( $feature->unique_id() ) ) {
    if( $self->{ '_identifiable_features' }{ $feature->unique_id() } ) {
      $self->{ '_identifiable_features' }{ $feature->unique_id() } =
        $feature;
      return 1;
    } else {
      return 0;
    }
  } else { # it does not have a unique id.  It is stored by start location.
    my $features_that_start_where_this_one_does =
      $self->{ '_anonymous_features' }{ $feature->start() };
    if( $features_that_start_where_this_one_does &&
        scalar( @$features_that_start_where_this_one_does ) ) {
      my $other_feature;
      for( my $i = 0;
           $i < scalar( @$features_that_start_where_this_one_does );
           $i++
         ) {
        if(
           ( $features_that_start_where_this_one_does[ $i ] == $feature )
           ||
           $features_that_start_where_this_one_does[ $i ]->equals( $feature )
          ) {
          $features_that_start_where_this_one_does = $feature;
          return 1;
        }
      }
      return 0;
    } else {
      return 0;
    }
  }
} # _update_feature(..)

=head2 _insert_or_update_feature

 Title   : _insert_or_update_feature
 Usage   : $provider->_insert_or_update_feature( $feature );
 Function: Inserts or updates the given feature in the store.
 Args    : L<Bio::SeqFeatureI> object
 Returns : True
 Status  : Protected

=cut

sub _insert_or_update_feature {
  my $self = shift;
  my $feature = shift;

  if( defined( $feature->unique_id() ) ) {
    $self->{ '_identifiable_features' }{ $feature->unique_id() } =
      $feature;
    return 1;
  } else { # it does not have a unique id.  It is stored by start location.
    my $features_that_start_where_this_one_does =
      $self->{ '_anonymous_features' }{ $feature->start() };
    if( $features_that_start_where_this_one_does &&
        scalar( @$features_that_start_where_this_one_does ) ) {
      my $other_feature;
      for( my $i = 0;
           $i < scalar( @$features_that_start_where_this_one_does );
           $i++
         ) {
        if(
           ( $features_that_start_where_this_one_does[ $i ] == $feature )
           ||
           $features_that_start_where_this_one_does[ $i ]->equals( $feature )
          ) {
          $features_that_start_where_this_one_does = $feature;
          return 1;
        }
      }
      push( @$features_that_start_where_this_one_does, $feature );
      return 1;
    } else {
      $self->{ '_anonymous_features' }{ $feature->start() } = [ $feature ];
      return 1;
    }
  }
} # _insert_or_update_feature(..)

=head2 _remove_feature

 Title   : _remove_feature
  Usage   : $provider->_remove_feature( $feature );
 Function: Removes the given feature from the store.
 Args    : L<Bio::SeqFeatureI> object
 Returns : False iff the feature was not previously in the store.
 Status  : Protected

=cut

sub _remove_feature {
  my $self = shift;
  my $feature = shift;

  if( defined( $feature->unique_id() ) ) {
    if( $self->{ '_identifiable_features' }{ $feature->unique_id() } ) {
      $self->{ '_identifiable_features' }{ $feature->unique_id() } = undef;
      return 1;
    } else {
      return 0;
    }
  } else { # it does not have a unique id.  It is stored by start location.
    my $features_that_start_where_this_one_does =
      $self->{ '_anonymous_features' }{ $feature->start() };
    if( $features_that_start_where_this_one_does &&
        scalar( @$features_that_start_where_this_one_does ) ) {
      my $other_feature;
      for( my $i = 0;
           $i < scalar( @$features_that_start_where_this_one_does );
           $i++
         ) {
        if(
           ( $features_that_start_where_this_one_does[ $i ] == $feature )
           ||
           $features_that_start_where_this_one_does[ $i ]->equals( $feature )
          ) {
          slice( @$features_that_start_where_this_one_does, $i, 1 );
          return 1;
        }
      }
      return 0;
    } else {
      return 0;
    }
  }
} # _remove_feature(..)

1;

__END__
