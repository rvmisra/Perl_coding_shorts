#!/user/bin/env perl 

use SOAP::Lite;
use Getopt::Long qw(:config no_ignore_case bundling);

die "You need to install SOAP::Lite 0.60 for using this services" unless ($SOAP::Lite::VERSION eq '0.60');

my %params=();
GetOptions("database|d=s"  => \$params{database},
           "program|p=s"   => \$params{program},
	   "matrix|m=s"    => \$params{matrix},
	   "gap|=i" 	   => \$params{gap},
	   "pam|a=i" 	   => \$params{pam},
	   "gapopen|o=i"   => \$params{gapopen},
	   "gapextend|x=i" => \$params{gapextend},
	   "sort|r=s"      => \$params{sort},		  
	   "annotation|n"  => \$annotation,
	   "help|h",	   => \$help,
	   "polljob"       => \$polljob,
	   "status"        => \$status,
	   "jobid|j=s"     => \$jobid,
	   "async|a"       => \$params{async},
	   "email|E=s"     => \$params{email},
	   "trace"         => \$trace,
	   "sequence=s",   => \$sequence,
	   "ebifile=s"     => \$ebifile,
	   "dbfetch=s"     => \$dbfetch,
       "outfile|O=s"   => \$params{outfile}
);

if ($trace){
 print "Tracing active\n";
 SOAP::Lite->import(+trace => debug);
} 
 
my $WSDL ='http://www.ebi.ac.uk/Tools/webservices/wsdl/WSMPsrch.wsdl'; 

my $soap = new SOAP::Lite->service($WSDL);
#$soap->proxy('http://158.119.60.205:8080/');
$soap{HTTP_proxy} = 'http://158.119.60.205:8080/';

if ( $help || ( !($polljob || $status) && !( (-f $ARGV[0]) || ((defined($sequence) || defined($ebifile) || defined($dbfetch)))) )) {
    &usage;
    general_options;
    exit;
}

elsif ( $polljob && defined($jobid)) {
    getResults($jobid);
   
}
 
elsif ( $status && defined($jobid)) {
    print "Getting status for job $jobid\n";

    my $result = $soap->checkStatus($jobid);
    die $soap->call->faultstring if $soap->call->fault;
    print STDOUT $result;
    print STDERR "To get results when done:  $0 --polljob --jobid $jobid\n";
       
}  
else {

     $soap->proxy('http://localhost/', timeout=>6000);
     
     #$soap->proxy('http', 'http://158.119.60.205:8080/');

     if (-f $ARGV[0]) {	
      $content={type=> "sequence",content=>read_file($ARGV[0])};	
     }

     if ($sequence) {	
      if (-f $sequence) {
		$content={type=> "sequence",content=>read_file($sequence)};	
      } else {
		$content={type=> "sequence",content=>$sequence};
      } 
     }


     push @content, $content;


	
     my $jobid = $soap->runMPsrch(SOAP::Data->name('params')->type(map=>\%params),
                                  SOAP::Data->name(content=>\@content));

     die $soap->call->faultstring if $soap->call->fault;
	
      if (defined($params{async})) {
        print STDOUT $jobid;
        print STDERR "Job launched: $jobid\n";
        print STDERR "To check status use:  $0 --status --jobid $jobid\n";
	
     } else {
	getResults($jobid);
     } 
} 

sub getResults {

    $jobid = shift;

    my $results = $soap->getResults($jobid);
    die $soap->call->faultstring if $soap->call->fault;

    unless (defined($outfile)){
     $outfile=$jobid;
    }
 
    for $result (@$results){
     $res=$soap->poll($jobid,$result->{type});
     write_file($outfile.".".$result->{ext},$res); 
    }
}

sub read_file {

 my $filename = shift;
  
 open(FILE, $filename);

  my $content;
  my $buffer;
  while (sysread(FILE, $buffer, 1024)){
   $content.= $buffer;
  }
  close(FILE);  

 return $content;

}


sub write_file {
    my ($tmp,$entity) = @_;
	
    print STDERR "Creating result file :".$tmp."\n";

    unless(open (FILE, ">$tmp")){
     return 0;
    }
    syswrite(FILE, $entity);
    close (FILE);
    
    return 1;
}

sub general_options {
    print STDERR << "EOF";
    
    Use this to do either a synchronous job or an asynchronous job

    Synchronous job:
        The results/errors are returned as soon as the job is finished.
        Usage: $0 -p string  -D string [options] file
	Returns : results as an attachment

    Asynchronous job:
	Use this if you want to retrieve the results at a later time. The results are stored for up to 12 hours. 	
        Usage :  $0 -p string -D string  -async  [options] file
	Returns : jobid

	Use the jobid to query for the status of the job. If the job is finished, it also returns the results/errors.
        Usage:   $0 --polljob --jobid string [--outfile string]
        Returns : string indicating the status of the job and if applicable, results as an attachment.
 
    General options:	

    -h, --help                  :               prints this help text
    -O, --outfile               : string      : name of the file results should be written to (default is jobid)
    -a, --async                 :               forces to make an asynchronous query
    -S, --email		        : string      : user email address 
	--trace		        :             : show SOAP messages being interchanged 

    Asynchronous job specific options:
    --polljob                   :               Poll for the status of a job
    -j, --jobid                 : string      : jobid that was returned when an asynchronous job was submitted.

   
              assuming that the jobid returned was MPsrch-20050726-11101103, poll for the results

              $0 --polljob --jobid MPsrch-20050726-11101103 


EOF
}
# Print program usage
sub usage {
    print STDERR << "EOF";
    MPsrch : a biological sequence comparison tool that implements the true Smith and Waterman algorithm. 

    
    MPsrch specific commands:
 
    -d, --database		: string      : Database for searching
    -p, --program		: string      : mpsrch_pp or mpsrch_ppa 
    -m, --matrix		: string      : specify substitution matrix (BLOSUM50,BLOSUM62,BLOSUM70,BLOSUM100)	
    -g, --gap			: integer     : penalty for gap opening  (for mpsrch_pp) default 14
    -o, --gapopen 		: integer     : (for mpsrch_ppa) default 28
    -P, --pam                   : integer     : Point Accepted Mutation Matrix (DEFAULT 100)
    -m, --annotation		: string      : yes / no
    -R, --sort			: string      : score / rank
        
    file			: file        : sequence data file in an accepted format
                                                see http://www.ebi.ac.uk/MPsrch/MPsrch_help.html#sequence for details

      
     example: $0 --database uniprot --program mpsrch_pp --email alabarga@ebi.ac.uk test.seq

     example: run previous example as an asynchronous job 

              $0 --database uniprot --program mpsrch_pp --email alabarga@ebi.ac.uk test.seq --async 

              assuming that the jobid returned was mpsrch-20050726-11101103, poll for the results

              $0 --polljob --jobid mpsrch-20050726-11101103 

     Output files:
	.output 	
        
EOF
}


1;
