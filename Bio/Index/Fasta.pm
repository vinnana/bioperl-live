
#
# BioPerl module for Bio::Index::Abstract
#
# Cared for by James Gilbert <jgrg@sanger.ac.uk>
#
# You may distribute this module under the same terms as perl itself

# POD documentation - main docs before the code

=head1 NAME

Bio::Index::Fasta - Interface for indexing (multiple) fasta files

=head1 SYNOPSIS

Provides methods 

=head1 DESCRIPTION


=head1 FEE_DBACK

=head2 Mailing Lists

User feedback is an integral part of the evolution of this and other
Bioperl modules. Send your comments and suggestions preferably to one
of the Bioperl mailing lists.  Your participation is much appreciated.

  vsns-bcd-perl@lists.uni-bielefeld.de          - General discussion
  vsns-bcd-perl-guts@lists.uni-bielefeld.de     - Technically-oriented discussion
  http://bio.perl.org/MailList.html             - About the mailing lists

=head2 Reporting Bugs

Report bugs to the Bioperl bug tracking system to help us keep track
the bugs and their resolution.  Bug reports can be submitted via
email or the web:

  bioperl-bugs@bio.perl.org
  http://bio.perl.org/bioperl-bugs/

=head1 AUTHOR - James Gilbert

Email - jgrg@sanger.ac.uk

=head1 APPENDIX

The rest of the documentation details each of the object methods. Internal methods are usually preceded with a _

=cut


# Let the code begin...


package Bio::Index::Fasta;
use vars qw($VERSION @ISA @EXPORT_OK);
use strict;

# Object preamble - inheriets from Bio::Root::Object

use Bio::Index::Abstract;
use DB_File;
use Fcntl;

@ISA = qw(Bio::Index::Abstract Exporter);
@EXPORT_OK = qw();

sub _type_stamp {
    return '__FASTA__'; # Used to prefix private keys in database
}

BEGIN {
    sub _version {
        return 0.2;
    }
    $VERSION = _version();
}

# new() is inherited from Bio::Root::Object

# _initialize is where the heavy stuff will happen when new is called

sub _initialize {
    my($self, $index_file, $write_flag) = @_;
    
    $index_file           or $self->throw("Index file name not given");
    #$index_file !~ m|^/| and $self->throw("Index file name not fully qualified : $index_file");

    $self->{'_filename'}   = $index_file;
    $self->{'_filehandle'} = []; # Array in which to cache open filehandles
    $self->{'_DB'}         = {}; # Gets tied to the DBM file
    $self->{'_id_parser'}  = \&default_id_parser;
    
    # Only open for writing if second argument to new was TRUE
    if ($write_flag and $write_flag eq 'WRITE') {
        $self->_open_dbm_rw();
    } else {
        $self->_open_dbm_ro();
    }
    
    # Check or set this is the right kind and version of index
    $self->_type_and_version();
    
    # Check files haven't changed size since they were indexed
    $self->_check_file_sizes();
}

# Bind "_DB" hash to Berkley DB file
sub _open_dbm_rw {
    my $self = shift;
    my $index_file = $self->filename();

    my $db = $self->db();
    tie %$db, 'DB_File', $index_file, O_RDWR|O_CREAT, 0644, $DB_HASH
        or $self->throw("Can't open DB_File : $index_file");
}

# Bind "_DB" hash to Berkley DB file
sub _open_dbm_ro {
    my $self = shift;
    my $index_file = $self->filename();

    my $db = $self->db();
    tie %$db, 'DB_File', $index_file, O_RDONLY, 0644, $DB_HASH
        or $self->throw("Can't open DB_File : $index_file");
}


# Returns the name of the index file
sub filename {
    return $_[0]->{'_filename'};
}

# Returns ref to the tied anonymous DB
sub db {
    return $_[0]->{'_DB'};
}

# Returns an open filehandle for the index given
sub _file_handle {
    my( $self, $i ) = @_;
    
    if (my $fh = $self->{'_filehandle'}[$i]) {
        return $fh; # Return cached filehandle
    } else {
        my @rec = $self->unpack_record($self->db->{"__FILE_$i"})
            or $self->throw("Can't get filename for index : $i");
        my $file = $rec[0];
        open F, $file or $self->throw("Can't open file for read : $file");
        $self->{'_filehandle'}[$i] = \*F; # Cache filehandle
        return \*F;
    }
}

# Build an index from a list of fasta files
sub create_index {
    my($self, @files) = @_;

    # We're really fussy/lazy, expecting all file names to be fully qualified
    $self->throw("No files to index provided") unless @files;
    foreach my $file (@files) {
        $self->throw("File name not fully qualified : $file") unless $file =~ m|^/|;
        $self->throw("File does not exist: $file")            unless -e $file;
    }

    # Add each file to the index
    foreach my $file (@files) {
        $self->index_file( $file );
    }
    return 1;
}

# Index a fasta file
sub index_file {
    my( $self, $file ) = @_;
    
    my( $begin, # Offset from start of file of the start
                # of the last found record
        $end,   # Offset from start of file of the end
                # of the last found record
        $id,    # ID of last found record
        $i,     # Index-number of file being indexed
        );

    $begin = 0;
    $end   = 0;

    $self->throw("File name not fully qualified : $file") unless $file =~ m|^/|;
    open FASTA, $file or $self->throw("Can't open file for read : $file");

    # Get new index for this file and increment file count
    if ( defined(my $count = $self->_file_count) ) {
        $i = $count; $count++; $self->_file_count($count);
    } else {
        $i = 0;                $self->_file_count(1);
    }

    # Save file name and size for this index
    $self->add_record("__FILE_$i", $file, -s $file);

    my $debug = 0;

    # Main indexing loop
    while (<FASTA>) {
        if (/^>/) {
            my $new_begin = tell(FASTA) - length( $_ );
            $end = $new_begin - 1;

            $self->add_record($id, $i, $begin, $end) if $id;

            $begin = $new_begin;
            ($id) = $self->record_id( $_ );
            
            $debug++; last if $debug > 20;
        }
    }
    # Don't forget to add the last record
    seek(FASTA, 0, 2); # Go to end of file - already there?
    $end = tell(FASTA);
    $self->add_record($id, $i, $begin, $end) if $id;

    close FASTA;
    return 1;
}

sub default_id_parser {
    my $line = shift;
    $line =~ /^>([^\s|]+)/;
    return $1;
}

# Unlimited number of fields
sub unpack_big_record {
    my( $self, @args ) = @_;
    return split /\034/, $args[0];
}

# Return the full entry from the database for the given record
sub get {
    my( $self, $id ) = @_;
    
    my $db = $self->db();
    if (my $rec = $db->{ $id }) {
        my( @record );
        
        my ($file, $begin, $end) = $self->unpack_record( $rec );
        my $fh = $self->_file_handle( $file );

        # Accumulate lines in @record until beyond end
        seek($fh, $begin, 0);
        while (defined(my $line = <$fh>)) {
            push(@record, $line);
            last if tell($fh) > $end;
        }
        
        # May want record as array for efficiency
        if (wantarray) {
            return @record;
        } else {
            return join '', @record;
        }
        
    } else {
        return;
    }
}

=head2 record_start

 Title   : record_start
 Usage   : Abstract - should be overriden by the subclass
 Function: This function is called for every line in the 
           indexing function. It should return 1 when the
           start of a record occurs
 Example :
 Returns : 1 or 0
 Args    :


=cut

sub record_start {
    my ($self, $line) = @_;

    if ($line =~ /^>/) {
        $self->record_id($line);
    } else {
        return;
    }
}

=head2 record_end

 Title   : record_end
 Usage   : Internal - should be overriden in subclass
 Function: This function is called for every line in the indexing function
           It should return 1 at the end of a record and 0 otherwise
 Example :
 Returns : 
 Args    :


=cut

sub record_end {
   my ($self,@args) = @_;
   
   $self->throw("In Bio::Index::Abstract - defaulted for record_end. Sub class should provide this");
}

=head2 DESTROY

 Title   : DESTROY
 Usage   : Called automatically when index goes out of scope
 Function: Closes connection to database and handles to
           sequence files
 Returns : NEVER
 Args    : NONE


=cut

sub DESTROY {
    my $self = shift;
    
    foreach my $fh (@{$self->{'_filehandle'}}) {
        close $fh;
    }
    
    untie %{$self->db};
}



1;

=head2 

  Title   : 
  Usage   : $obj->
  Function: 
  Example : 
  Returns : 
  Args    : 

=cut

