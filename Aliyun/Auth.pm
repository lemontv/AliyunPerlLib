package Aliyun::Auth;

use strict;
use warnings;
use LWP;
use DateTime;
use Data::UUID;
use Digest::SHA qw(hmac_sha1_base64);
use URI::Escape;
use Data::Dumper;
use utf8;
use Encode;
use JSON;

sub new {
    my ($class, $opts) = @_;
    my ($self) = {};
    &Extend($self, $opts);
    bless($self, $class);
    return $self;
}

sub Request {
    my ($self, $opts) = @_;
    die "Need options" unless($opts);
    &Extend($opts, $self);
    my $base = "https://ecs.aliyuncs.com";
	my $request = LWP::UserAgent->new();
	push @{$request->requests_redirectable}, 'POST';
    my $params = &Params($opts);
    my $response = $request->post($base, $params);
	return &TransUTF8(decode_json($response->content));
}

sub Params {
    my $opts = shift;
    my $Format = "JSON";
    my $Version = "2014-05-26";
    my $SignatureMethod = "HMAC-SHA1";
    my $Timestamp = sprintf("%s", DateTime->now());
    my $SignatureNonce = &UUID();
    my $AccessKeySecret = $opts->{"AccessKeySecret"} . "&";
    delete($opts->{"AccessKeySecret"});

    my $common = {
        "Version" => $Version,
        "Format" => $Format,
        "SignatureMethod" => $SignatureMethod,
        "Timestamp" => $Timestamp,
        "SignatureVersion" => "1.0",
        "SignatureNonce" => $SignatureNonce,
    };

    &Extend($opts, $common);

    my $Signature = &HMAC($opts, $AccessKeySecret);
    $opts->{"Signature"} = $Signature."=";

    return $opts;
}

sub HMAC {
    my ($opts, $AccessKeySecret) = @_;
    my @keys = sort keys(%{$opts});
    my $StringToSign = "";
    my @params;
    foreach my $key (@keys) {
        my $val = $key eq "Timestamp" ? uri_escape($opts->{$key}) : $opts->{$key};
        push(@params, "$key=$val");
    }
    $StringToSign = join("&", @params);
    $StringToSign = uri_escape($StringToSign);
    $StringToSign = "POST&%2F&" . $StringToSign;
    my $Signature = hmac_sha1_base64($StringToSign, $AccessKeySecret);
    return $Signature;
}

sub UUID {
    my $ug   = Data::UUID->new;
    my $uuid = $ug->to_string($ug->create());
    return $uuid;
}

sub Extend {
    my ($a, $b) = @_;
    foreach my $key (keys %{$b}) {
        $a->{$key} = $b->{$key};
    }
    return $a;
}

sub TransUTF8 {
    my ($data) = @_;
    return unless($data);
    return encode("utf8", $data) unless (ref($data));
    if (ref($data) eq "HASH") {
        foreach my $key (%{$data}) {
            my $val = &TransUTF8($data->{$key});
            $data->{$key} = $val if($val);
        }
    } else {
        foreach my $val (@{$data}) {
            &TransUTF8($val);
        }
    }
    return $data;
}

1;
