#!/usr/bin/perl
use DBI();
use MIME::Lite;
use utf8; 
use MIME::QuotedPrint qw(encode_qp);
use Encode qw(encode);
use Net::SMTP_auth;

$mail=$ARGV[0];
$copie=$ARGV[1];
$appro=$ARGV[2];

$sujet="Caisse manquante";
$message="Caisse manquante sur le bon d appro $appro";
# $message = encode_qp(encode("UTF-8", "$message"));
#$copie="philippe.perraud5\@orange.fr";
&mail_joint_pdf("$message","$sujet","$mail","$copie");

sub mail_joint_pdf(){
my ($message)=$_[0];
my ($sujet)=$_[1];
my ($to)=$_[2];
my ($cc)=$_[3];
my $smtp = Net::SMTP_auth->new('smtp.dutyfreeconcept.com');
$smtp->auth( 'LOGIN', '6192_sb', 'passe123' );

# MIME::Lite->send('smtp', 'smtp.dutyfreeambassade.com');
my $mime = MIME::Lite->new(
            From       => 'supply_dfc@dutyfreeconcept.com',
            To         => "$to",
             Cc         => "$cc",
            Subject    => "$sujet",
            "X-Mailer" => 'moncourriel.pl v2.0',
            Type       => 'multipart/mixed'
            );
$mime->attach(
            Type       => 'TEXT',
            Encoding   => 'quoted-printable',
            Data       => $message
);
$mime->attr("content-type.charset" => "utf-8");

$mime->send();
}
