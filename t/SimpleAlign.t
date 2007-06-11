# -*-Perl-*-
## Bioperl Test Harness Script for Modules
## $Id$
use strict;
use constant NUMTESTS => 113;
use vars qw($DEBUG);
$DEBUG = $ENV{'BIOPERLDEBUG'} || 0;

BEGIN {
	eval { require Test::More; };
	if( $@ ) {
		use lib 't/lib';
	}
	use Test::More;

	plan tests => NUMTESTS;
}

use_ok('Bio::SimpleAlign');
use_ok('Bio::AlignIO');
use_ok('Bio::Root::IO');
use_ok('Bio::SeqFeature::Generic');
use_ok('Bio::Location::Simple');
use_ok('Bio::Location::Split');

my ($str, $aln, @seqs, $seq);

$str = Bio::AlignIO->new(-file=> Bio::Root::IO->catfile(
                        "t","data","testaln.pfam"));
isa_ok($str,'Bio::AlignIO');
$aln = $str->next_aln();
is $aln->get_seq_by_pos(1)->get_nse, '1433_LYCES/9-246', 
            "pfam input test";

my $aln1 = $aln->remove_columns(['mismatch']);
is($aln1->match_line, '::*::::*:**:*:*:***:**.***::*.*::**::**:***..**:'.
   '*:*.::::*:.:*.*.**:***.**:*.:.**::**.*:***********:::*:.:*:**.*::*:'.
   '.*.:*:**:****************::', 'match_line');

my $aln2 = $aln->select(1,3);
isa_ok($aln2, 'Bio::Align::AlignI');
is($aln2->no_sequences, 3, 'no_sequences');

# test select non continuous-sorted by default
$aln2 = $aln->select_noncont(6,7,8,9,10,1,2,3,4,5);
is($aln2->no_sequences, 10, 'no_sequences');
is($aln2->get_seq_by_pos(2)->id, $aln->get_seq_by_pos(2)->id, 'select_noncont');
is($aln2->get_seq_by_pos(8)->id, $aln->get_seq_by_pos(8)->id, 'select_noncont');

# test select non continuous-nosort option
$aln2 = $aln->select_noncont('nosort',6,7,8,9,10,1,2,3,4,5);
is($aln2->no_sequences, 10, 'no_sequences');
is($aln2->get_seq_by_pos(2)->id, $aln->get_seq_by_pos(7)->id, 'select_noncont');
is($aln2->get_seq_by_pos(8)->id, $aln->get_seq_by_pos(3)->id, 'select_noncont');

@seqs = $aln->each_seq();
is scalar @seqs, 16, 'each_seq';
is $seqs[0]->get_nse, '1433_LYCES/9-246', 'get_nse';
is $seqs[0]->id, '1433_LYCES', 'id';
is $seqs[0]->no_gaps, 3, 'no_gaps';
@seqs = $aln->each_alphabetically();
is scalar @seqs, 16, 'each_alphabetically';

is $aln->column_from_residue_number('1433_LYCES', 10), 2, 'column_from_residue_number';
is $aln->displayname('1433_LYCES/9-246', 'my_seq'), 'my_seq', 'display_name get/set';
is $aln->displayname('1433_LYCES/9-246'), 'my_seq', 'display_name get';
is substr ($aln->consensus_string(50), 0, 60),
    "RE??VY?AKLAEQAERYEEMV??MK?VAE??????ELSVEERNLLSVAYKNVIGARRASW", 'consensus_string';
is substr ($aln->consensus_string(100), 0, 60),
    "?????????L????E????M???M????????????L??E?RNL?SV?YKN??G??R??W", 'consensus_string';
is substr ($aln->consensus_string(0), 0, 60), 
    "REDLVYLAKLAEQAERYEEMVEFMKKVAELGAPAEELSVEERNLLSVAYKNVIGARRASW", 'consensus_string';

ok(@seqs = $aln->each_seq_with_id('143T_HUMAN'));
is scalar @seqs, 1, 'each_seq_with_id';

is $aln->is_flush, 1,'is_flush';
ok($aln->id('x') && $aln->id eq 'x','id get/set');

is $aln->length, 242, 'length';
is $aln->no_residues, 3769, 'no_residues';
is $aln->no_sequences, 16, 'no_sequences';
is (sprintf("%.2f",$aln->overall_percentage_identity()), 33.06, 'overall_percentage_identity');
is (sprintf("%.2f",$aln->overall_percentage_identity('align')), 33.06, 'overall_percentage_identity');
is (sprintf("%.2f",$aln->overall_percentage_identity('short')), 35.24, 'overall_percentage_identity');
is (sprintf("%.2f",$aln->overall_percentage_identity('long')), 33.47, 'overall_percentage_identity');
is (sprintf("%.2f",$aln->average_percentage_identity()), 66.91, 'average_percentage_identity');

ok $aln->set_displayname_count;
is $aln->displayname('1433_LYCES/9-246'), '1433_LYCES_1', 'set_displayname_count';
ok $aln->set_displayname_flat;
is $aln->displayname('1433_LYCES/9-246'), '1433_LYCES', 'set_displayname_flat';
ok $aln->set_displayname_normal;
is $aln->displayname('1433_LYCES/9-246'), '1433_LYCES/9-246', 'set_displayname_normal';
ok $aln->uppercase;
ok $aln->map_chars('\.','-');
@seqs = $aln->each_seq_with_id('143T_HUMAN');
is substr($seqs[0]->seq, 0, 60),
    'KTELIQKAKLAEQAERYDDMATCMKAVTEQGA---ELSNEERNLLSVAYKNVVGGRRSAW', 'uppercase, map_chars';

is($aln->match_line, '       ::*::::*  : *   *:           *: *:***:**.***::*.'.
   ' *::**::**:***      .  .      **  :* :*   .  :: ::   *:  .     :* .*. **:'.
   '***.** :*.            :  .*  *   :   : **.*:***********:::* : .: *  :** .'.
   '*::*: .*. : *: **:****************::     ', 'match_line');
ok $aln->remove_seq($seqs[0]),'remove_seqs';
is $aln->no_sequences, 15, 'remove_seqs';
ok $aln->add_seq($seqs[0]), 'add_seq';
is $aln->no_sequences, 16, 'add_seq';
ok $seq = $aln->get_seq_by_pos(1), 'get_seq_by_pos';
is( $seq->id, '1433_LYCES', 'get_seq_by_pos');
ok (($aln->missing_char(), 'P') and  ($aln->missing_char('X'), 'X')) ;
ok (($aln->match_char(), '.') and  ($aln->match_char('-'), '-')) ;
ok (($aln->gap_char(), '-') and  ($aln->gap_char('.'), '.')) ;

is $aln->purge(0.7), 12, 'purge';
is $aln->no_sequences, 4, 'purge';

SKIP:{
	eval { require IO::String };
	skip("IO::String not installed. Skipping tests.\n", 24) if $@;

	my $string;
	my $out = IO::String->new($string);
	
	my $s1 = new Bio::LocatableSeq (-id => 'AAA',
					-seq => 'aawtat-tn-',
					-start => 1,
					-end => 8,
					-alphabet => 'dna'
					);
	my $s2 = new Bio::LocatableSeq (-id => 'BBB',
					-seq => '-aaaat-tt-',
					-start => 1,
					-end => 7,
					-alphabet => 'dna'
					);
	$a = new Bio::SimpleAlign;
	$a->add_seq($s1);           
	$a->add_seq($s2);
	
	is ($a->consensus_iupac, "aAWWAT-TN-", 'IO::String consensus_iupac');
	$s1->seq('aaaaattttt');
	$s1->alphabet('dna');
	$s1->end(10);
	$s2->seq('-aaaatttt-');
	$s2->end(8);
	$a = new Bio::SimpleAlign;
	$a->add_seq($s1);
	$a->add_seq($s2);
	
	my $strout = Bio::AlignIO->new(-fh => $out, -format => 'pfam');
	$strout->write_aln($a);
	is ($string,
		"AAA/1-10    aaaaattttt\n".
		"BBB/1-8     -aaaatttt-\n",
		'IO::String write_aln normal');
	
	$out->setpos(0); 
	$string ='';
	my $b = $a->slice(2,9);
	$strout->write_aln($b);
	is $string,
	"AAA/2-9    aaaatttt\n".
	"BBB/1-8    aaaatttt\n",
	'IO::String write_aln slice';
	
	$out->setpos(0); 
	$string ='';
	$b = $a->slice(9,10);
	$strout->write_aln($b);
	is $string,
	"AAA/9-10    tt\n".
	"BBB/8-8     t-\n",
	'IO::String write_aln slice';
	
	$a->verbose(-1);
	$out->setpos(0); 
	$string ='';
	$b = $a->slice(1,2);
	$strout->write_aln($b);
	is $string,
	"AAA/1-2    aa\n".
	"BBB/1-1    -a\n",
	'IO::String write_aln slice';
	
	# not sure what coordinates this should return...
	$a->verbose(-1);
	$out->setpos(0); 
	$string ='';
	$b = $a->slice(1,1,1);
	$strout->write_aln($b);
	is $string,
	"AAA/1-1    a\n".
	"BBB/1-0    -\n",
	'IO::String write_aln slice';
	
	$a->verbose(-1);
	$out->setpos(0); 
	$string ='';
	$b = $a->slice(2,2);
	$strout->write_aln($b);
	is $string,
	"AAA/2-2    a\n".
	"BBB/1-1    a\n",
	'IO::String write_aln slice';
	
	eval {
		$b = $a->slice(11,13);
	};
	
	like($@, qr/EX/ );
	
	# remove_columns by position
	$out->setpos(0); 
	$string ='';
	$str = Bio::AlignIO->new(-file=> Bio::Root::IO->catfile(
												"t","data","mini-align.aln"));
	$aln1 = $str->next_aln;
	$aln2 = $aln1->remove_columns([0,0]);
	$strout->write_aln($aln2);
	is $string,
	"P84139/1-33              NEGEHQIKLDELFEKLLRARLIFKNKDVLRRC\n".
	"P814153/1-33             NEGMHQIKLDVLFEKLLRARLIFKNKDVLRRC\n".
	"BAB68554/1-14            ------------------AMLIFKDKQLLQQC\n".
	"gb|443893|124775/1-32    MRFRFQIKVPPAVEGARPALLIFKSRPELGGC\n",
	'remove_columns by position';
	
	# and when arguments are entered in "wrong order"?
	$out->setpos(0); 
	$string ='';
	my $aln3 = $aln1->remove_columns([1,1],[30,30],[5,6]);
	$strout->write_aln($aln3);
	is $string,
	"P84139/1-33              MEGEIKLDELFEKLLRARLIFKNKDVLRC\n".
	"P814153/1-33             MEGMIKLDVLFEKLLRARLIFKNKDVLRC\n".
	"BAB68554/1-14            ----------------AMLIFKDKQLLQC\n".
	"gb|443893|124775/1-32    -RFRIKVPPAVEGARPALLIFKSRPELGC\n",
	'remove_columns by position (wrong order)';
	
	my %cigars = $aln1->cigar_line;
	is $cigars{'gb|443893|124775/1-32'},'19,19:21,24:29,29:32,32','cigar_line';
	is $cigars{'P814153/1-33'},'20,20:22,25:30,30:33,33','cigar_line';
	is $cigars{'BAB68554/1-14'},'1,1:3,6:11,11:14,14','cigar_line';
	is $cigars{'P84139/1-33'},'20,20:22,25:30,30:33,33','cigar_line';
	
	
	# sort_alphabetically
	my $s3 = new Bio::LocatableSeq (-id => 'ABB',
											  -seq => '-attat-tt-',
											  -start => 1,
											  -end => 7,
											  -alphabet => 'dna'
											 );
	$a->add_seq($s3);
	
	is $a->get_seq_by_pos(2)->id,"BBB", 'sort_alphabetically - before';
	ok $a->sort_alphabetically;
	is $a->get_seq_by_pos(2)->id,"ABB", 'sort_alphabetically - after';
	
	$b = $a->remove_gaps();
	is $b->consensus_string, "aaaattt", 'remove_gaps';
	
	$s1->seq('aaaaattt--');
	
	$b = $a->remove_gaps(undef, 'all_gaps_only');
	is $b->consensus_string, "aaaaatttt",'remove_gaps all_gaps_only';
	
	# test set_new_reference:
	$str = Bio::AlignIO->new(-file=> Bio::Root::IO->catfile(
							"t","data","testaln.aln"));
	$aln=$str->next_aln();
	my $new_aln=$aln->set_new_reference(3);
	$a=$new_aln->get_seq_by_pos(1)->display_id;
	$new_aln=$aln->set_new_reference('P851414');
	$b=$new_aln->get_seq_by_pos(1)->display_id;
	is $a, 'P851414','set_new_reference';
	is $b, 'P851414','set_new_reference';
	
	# test uniq_seq:
	$str = Bio::AlignIO->new(-verbose => $DEBUG,
							 -file=> Bio::Root::IO->catfile(
							"t","data","testaln2.fasta"));
	$aln=$str->next_aln();
	$new_aln=$aln->uniq_seq();
	$a=$new_aln->no_sequences;
	is $a, 11,'uniq_seq';
		
	# check if slice works well with a LocateableSeq in its negative strand
	my $seq1 = Bio::LocatableSeq->new(
	  -SEQ    => "ATGCTG-ATG",
	  -START  => 1,
	  -END    => 9,
	  -ID     => "test1",
	  -STRAND => -1
	);
	
	my $seq2 = Bio::LocatableSeq->new(
	  -SEQ    => "A-GCTGCATG",
	  -START  => 1,
	  -END    => 9,
	  -ID     => "test2",
	  -STRAND => 1
	);
	
	$string ='';
	my $aln_negative = Bio::SimpleAlign->new();
	$aln_negative->add_seq($seq1);
	$aln_negative->add_seq($seq2);
	my $start_column =
	   $aln_negative->column_from_residue_number($aln_negative->get_seq_by_pos(1)->display_id,2);
	my $end_column =
	   $aln_negative->column_from_residue_number($aln_negative->get_seq_by_pos(1)->display_id,5);
	$aln_negative = $aln_negative->slice($end_column,$start_column);
	my $seq_negative = $aln_negative->get_seq_by_pos(1);
	is($seq_negative->start,2,"bug 2099");
	is($seq_negative->end,5,"bug 2099");
}

# test for Bio::SimpleAlign annotation method and 
# Bio::FeatureHolder stuff

$aln = Bio::SimpleAlign->new;
for my $seqset ( [qw(one AGAGGAT)], [qw(two AGACGAT) ], [qw(three AGAGGTT)]) {
    $aln->add_seq(Bio::LocatableSeq->new(-id => $seqset->[0],
					 -seq => $seqset->[1]));
}

is $aln->no_sequences, 3, 'added 3 seqs';

$aln->add_SeqFeature(Bio::SeqFeature::Generic->new(-start => 1,
						   -end   => 1,
						   -primary_tag => 'charLabel',
						   ));
$aln->add_SeqFeature(Bio::SeqFeature::Generic->new(-start => 3,
						   -end   => 3,
						   -primary_tag => 'charLabel',

						   ));
is($aln->feature_count, 2, 'first 2 features added');

my $splitloc =Bio::Location::Split->new;
$splitloc->add_sub_Location(Bio::Location::Simple->new(-start => 2,
						       -end   => 3));

$splitloc->add_sub_Location(Bio::Location::Simple->new(-start => 5,
						       -end   => 6));
						     
$aln->add_SeqFeature(Bio::SeqFeature::Generic->new(-location =>$splitloc,
						   -primary_tag => 'charLabel',
						   ));

is($aln->feature_count, 3, '3rd feature added');

#get a slice as defined by the feature
my $i = 0;
my @slice_lens = qw(1 1 2 2);
for my $feature ( $aln->get_SeqFeatures ) {
    for my $loc ( $feature->location->each_Location ) {
	my $fslice = $aln->slice($loc->start, $loc->end);
	is($fslice->length, $slice_lens[$i++], "slice $i len");
    }
}

# test set_displayname_safe & restore_displayname:
$str = Bio::AlignIO->new(-file=> Bio::Root::IO->catfile(
                        "t","data","pep-266.aln"));
$aln=$str->next_aln();
is $aln->get_seq_by_pos(3)->display_id, 'Smik_Contig1103.1', 'initial display id ok';
my ($new_aln, $ref)=$aln->set_displayname_safe();
is $new_aln->get_seq_by_pos(3)->display_id, 'S000000003', 'safe display id ok';
my $restored_aln=$new_aln->restore_displayname($ref);
is $restored_aln->get_seq_by_pos(3)->display_id, 'Smik_Contig1103.1', 'restored display id ok';

# test sort_by_list:
$str = Bio::AlignIO->new(-file=> Bio::Root::IO->catfile(
                        "t","data","testaln.aln"));
my $list_file=Bio::Root::IO->catfile("t", "data", "testaln.list");
$aln=$str->next_aln();
$new_aln=$aln->sort_by_list($list_file);
$a=$new_aln->get_seq_by_pos(1)->display_id;
is $a, 'BAB68554', 'sort by list ok';

# test for Binary/Morphological/Mixed data


# sort_by_start

# test sort_by_list:

my $s1 = new Bio::LocatableSeq (-id => 'AAA',
                -seq => 'aawtat-tn-',
                -start => 12,
                -end => 19,
                -alphabet => 'dna'
                );
my $s2 = new Bio::LocatableSeq (-id => 'BBB',
                -seq => '-aaaat-tt-',
                -start => 1,
                -end => 7,
                -alphabet => 'dna'
                );
my $s3 = new Bio::LocatableSeq (-id => 'BBB',
                -seq => '-aaaat-tt-',
                -start => 31,
                -end => 37,
                -alphabet => 'dna'
                );
$a = new Bio::SimpleAlign;
$a->add_seq($s1);           
$a->add_seq($s2);
$a->add_seq($s3);

@seqs = $a->each_seq;
is($seqs[0]->start, 12);
is($seqs[1]->start, 1);
is($seqs[2]->start, 31);

$a->sort_by_start;
@seqs = $a->each_seq;

is($seqs[0]->start, 1);
is($seqs[1]->start, 12);
is($seqs[2]->start, 31);

my %testdata = (
	'allele1' => 'GGATCCATT[C/C]CTACT',
	'allele2' => 'GGAT[C/-][C/-]ATT[C/C]CT[A/C]CT',
	'allele3' => 'G[G/C]ATCCATT[C/G]CTACT',
	'allele4' => 'GGATCCATT[C/G]CTACT',
	'allele5' => 'GGATCCATT[C/G]CTAC[T/A]',
	'allele6' => 'GGATCCATT[C/G]CTA[C/G][T/A]',
	'testseq' => 'GGATCCATT[C/G]CTACT'
	);

my $alnin = Bio::AlignIO->new(-format => 'fasta',
							 -file   => Bio::Root::IO->catfile(
                        "t","data","alleles.fas"));

$aln = $alnin->next_aln;

my $ct = 0;
# compare all to test seq

for my $ls (sort keys %testdata) {
    $ct++;
    my $str = $aln->bracket_string(-refseq     => 'testseq',
                           -allele1    => 'allele1',
                           -allele2    => $ls,
                           );
    is($str, $testdata{$ls}, "BIC:$str");
}

%testdata = (
	'allele1' => 'GGATCCATT{C.C}CTACT',
	'allele2' => 'GGAT{C.-}{C.-}ATT{C.C}CT{A.C}CT',
	'allele3' => 'G{G.C}ATCCATT{C.G}CTACT',
	'allele4' => 'GGATCCATT{C.G}CTACT',
	'allele5' => 'GGATCCATT{C.G}CTAC{T.A}',
	'allele6' => 'GGATCCATT{C.G}CTA{C.G}{T.A}',
	'testseq' => 'GGATCCATT{C.G}CTACT'
	);

for my $ls (sort keys %testdata) {
    $ct++;
    my $str = $aln->bracket_string(-refseq     => 'testseq',
                           -allele1    => 'allele1',
                           -allele2    => $ls,
                           -delimiters => '{}',
                           -separator => '.'
                           );
    is($str, $testdata{$ls},"BIC:$str");
}

1;
