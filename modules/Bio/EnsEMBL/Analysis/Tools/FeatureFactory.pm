package Bio::EnsEMBL::Analysis::Tools::FeatureFactory;


use strict;
use warnings;

use Bio::EnsEMBL::Root;
use Bio::EnsEMBL::FeaturePair;
use Bio::EnsEMBL::Feature;
use Bio::EnsEMBL::RepeatFeature;
use Bio::EnsEMBL::RepeatConsensus;
use Bio::EnsEMBL::DnaDnaAlignFeature;
use Bio::EnsEMBL::DnaPepAlignFeature;
use Bio::EnsEMBL::PredictionTranscript;
use Bio::EnsEMBL::PredictionExon;
use Bio::EnsEMBL::SimpleFeature;
use Bio::EnsEMBL::Utils::Exception qw(verbose throw warning);
use Bio::EnsEMBL::Utils::Argument qw( rearrange );
use Bio::EnsEMBL::Analysis::Programs;


use vars qw (@ISA);

@ISA = qw(Bio::EnsEMBL::Root);

#feature creation methods#



=head2 create_simple_feature

  Arg [1]   : Bio::EnsEMBL::Analysis::Tools::FeatureFactory
  Arg [2]   : int, start
  Arg [3]   : int, end,
  Arg [4]   : int, stand (must be 0, 1 or -1)
  Arg [5]   : int score,
  Arg [6]   : string, display label,
  Arg [7]   : string, sequence name
  Arg [8]   : Bio::EnsEMBL::Slice
  Arg [9]   : Bio::EnsEMBL::Analysis
  Function  : creata a Bio::EnsEMBL::SimpleFeature
  Returntype: Bio::EnsEMBL::SimpleFeature
  Exceptions: 
  Example   : 

=cut



sub create_simple_feature{
  my ($self, $start, $end, $strand, $score, $display_label,
      $seqname, $slice, $analysis) = @_;
  my $simple_feature = Bio::EnsEMBL::SimpleFeature->new
    (
     -start => $start,
     -end => $end,
     -strand => $strand,
     -score => $score,
     -display_label => $display_label,
     -seqname => $seqname,
     -slice => $slice,
     -analysis => $analysis,
    );
  return $simple_feature;
}


=head2 create_simple_feature

  Arg [1]   : Bio::EnsEMBL::Analysis::Tools::FeatureFactory
  Arg [2]   : string, name
  Arg [3]   : string, class
  Arg [4]   : string, type
  Arg [5]   : string, consensus sequence
  Arg [6]   : int length
  Function  : creata a Bio::EnsEMBL::RepeatConsensus
  Returntype: Bio::EnsEMBL::RepeatConsensus
  Exceptions: 
  Example   : 

=cut

sub create_repeat_consensus{
  my ($self, $name, $class, $type, $consensus_seq, $length) = @_;
  my $repeat_consensus = Bio::EnsEMBL::RepeatConsensus->new
    (
     -name => $name,
     -length => $length,
     -repeat_class => $class,
     -repeat_consensus => $consensus_seq,
     -repeat_type => $type,
    );
  return $repeat_consensus;
}

=head2 create_simple_feature

  Arg [1]   : Bio::EnsEMBL::Analysis::Tools::FeatureFactory
  Arg [2]   : int, start
  Arg [3]   : int, end,
  Arg [4]   : int, stand (must be 0, 1 or -1)
  Arg [5]   : int score,
  Arg [6]   : int, repeat_start
  Arg [7]   : int, repeat_end
  Arg [8]   : Bio::EnsEMBL::RepeatConsensus
  Arg [9]   : Bio::EnsEMBL::Slice
  Arg [10]   : Bio::EnsEMBL::Analysis
  Function  : creata a Bio::EnsEMBL::RepeatFeature
  Returntype: Bio::EnsEMBL::RepeatFeature
  Exceptions: 
  Example   : 

=cut

sub create_repeat_feature{
  my ($self, $start, $end, $strand, $score, $repeat_start, $repeat_end,
      $repeat_consensus, $seqname, $slice, $analysis) = @_;

  my $repeat_feature = Bio::EnsEMBL::RepeatFeature->new
    (
     -start            => $start,
     -end              => $end,
     -strand           => $strand,
     -slice            => $slice,
     -analysis         => $analysis,
     -repeat_consensus => $repeat_consensus,
     -hstart           => $repeat_start,
     -hend             => $repeat_end,
     -score            => $score,
     -seqname          => $seqname, 
    );
  return $repeat_feature;
}


=head2 create_FeaturePair

  Arg [1]   : Bio::EnsEMBL::Analysis::Runnable
  Arg [2]   : int, start
  Arg [3]   : int, end
  Arg [4]   : int, strand must be 0, 1 or -1
  Arg [5]   : int, score
  Arg [6]   : int, hstart
  Arg [7]   : int, hend
  Arg [8]   : int, hstrand
  Arg [9]   : string, hseqname
  Arg [10]  : int, percent id
  Arg [11]  : int, p value
  Arg [12]  : string, seqname
  Arg [13]  : Bio::EnsEMBL::Analysis
  Function  : creates a Bio::EnsEMBL::FeaturePair
  Returntype: Bio::EnsEMBL::FeaturePair
  Exceptions: 
  Example   : 

=cut


sub create_FeaturePair {
    my ($self, $start, $end, $strand, $score, $hstart, $hend, 
        $hstrand, $hseqname, $percent_id, $p_value, $seqname,
        $analysis, $slice) = @_;
    
    my $fp = Bio::EnsEMBL::FeaturePair->new(
                                            -start    => $start,
                                            -end      => $end,
                                            -strand   => $strand,
                                            -hstart   => $hstart,
                                            -hend     => $hend,
                                            -hstrand  => $hstrand,
                                            -percent_id => $percent_id,
                                            -score    => $score,
                                            -p_value  => $p_value,
                                            -hseqname => $hseqname,
                                            -analysis => $analysis,
                                           );

    $fp->seqname($seqname);
    
    return $fp;
}


#validation methods#

=head2 validate

  Arg [1]   : Bio::EnsEMBL::Analysis::Tools::FeatureFactory
  Arg [2]   : Bio::EnsEMBL::Feature
  Function  : validates feature
  Returntype: Bio::EnsEMBL::Feature
  Exceptions: throws if no slice or analysis is defined
  if the start, end or strand arent defined, if start or end are
  less than one or if start is greater than end
  Example   : 

=cut


sub validate{
  my ($self, $feature) = @_;
  my @error_messages;
  if(!$feature){
    throw("Can't validate a feature without a feature ".
          "FeatureFactory::validate");
  }
  if(!($feature->isa('Bio::EnsEMBL::Feature'))){
    throw("Wrong type ".$feature." must be a Bio::EnsEMBL::Feature ".
          "object FeatureFactory::validate");
  }
  if(!$feature->slice){
    my $string = "No slice defined";
    push(@error_messages, $string);
  }
  if(!$feature->analysis){
    my $string = "No analysis defined";
    push(@error_messages, $string);
  }
  if(!$feature->start){
    my $string = "No start defined";
    push(@error_messages, $string); 
  }
  if(!$feature->end){
    my $string = "No end defined";
    push(@error_messages, $string); 
  }
  if(!defined $feature->strand){
    my $string = "No strand defined";
    push(@error_messages, $string); 
  }
  if($feature->start > $feature->end){
    my $string = "Start is greater than end ".$feature->start." ".
      $feature->end;
    push(@error_messages, $string); 
  }
  if($feature->start < 1 || $feature->end < 1){
    my $string = "Feature has start or end coordinates less than 1 ".
      $feature->start." ".$feature->end;
    push(@error_messages, $string); 
  }
  if(@error_messages > 0){
    print STDERR join("\n", @error_messages);
    throw("Invalid feature FeatureFactory:validate");
  }
}
