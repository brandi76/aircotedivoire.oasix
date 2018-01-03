#!/usr/bin/perl 
use DBI();
use MIME::Lite;
use utf8; 
use MIME::QuotedPrint qw(encode_qp);
use Encode qw(encode);
$to="sylvainbrandicourt\@gmail.com";
MIME::Lite->send('smtp', 'smtp.dutyfreeambassade.com');
my $mime = MIME::Lite->new(
            From       => 'info_dfc@dutyfreeconcept.com',
            To         => "$to",
            Subject    => "bug coffre",
            "X-Mailer" => 'moncourriel.pl v2.0',
            Type       => 'multipart/mixed'
            );
$mime->attach(
            Type       => 'TEXT',
            Encoding   => 'quoted-printable',
            Data       => "voir file debug cote d ivoire"
);
$mime->send();

