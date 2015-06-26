package Aliyun::Action;

use strict;
use warnings;
use Aliyun::Auth;
use Data::Dumper;

### Init start
sub new {
    my ($class, $opts) = @_;
    my ($self) = {};
    bless($self, $class);
    $self->init($opts);
    return $self;
}

sub init {
    my ($self, $opts) = @_;
    $self->{"aliyun"} = new Aliyun::Auth({"AccessKeyId" => $opts->{"AccessKeyId"}, "AccessKeySecret" => $opts->{"AccessKeySecret"}});
    $self->{"RegionId"} = $opts->{"RegionId"} || "cn-hangzhou";

    my $rep = $self->DescribeSecurityGroups();
    my $SecurityGroupId = $rep->{"SecurityGroups"}->{"SecurityGroup"}->[0]->{"SecurityGroupId"};
    $self->{"SecurityGroupId"} = $opts->{"SecrurityGroupId"} || $SecurityGroupId;
}
### Init End

### Instance Start
sub CreateInstance {
    my ($self, $opts) = @_;
    my $aliyun = $self->{"aliyun"};
    my $default = {
        "ImageId" => "m-237wlhgwa",
        "InstanceType" => "ecs.t1.small",
        "SecurityGroupId" => $self->{"SecurityGroupId"},
        "InternetChargeType" => "PayByTraffic",
        "InternetMaxBandwidthOut" => "50"
    };
    &Extend($default, $opts);

    return $aliyun->Request($self->Action("CreateInstance", $default));
}

sub StartInstance {
    my ($self, $opts) = @_;
    my $aliyun = $self->{"aliyun"};

    return $aliyun->Request($self->Action("StartInstance", $opts));
}

sub StopInstance {
    my ($self, $opts) = @_;
    my $aliyun = $self->{"aliyun"};
    $opts->{"ForceStop"} = "true";

    return $aliyun->Request($self->Action("StopInstance", $opts));
}


sub DescribeInstanceStatus {
    my ($self, $opts) = @_;
    my $aliyun = $self->{"aliyun"};

    return $aliyun->Request($self->Action("DescribeInstanceStatus", $opts));
}

sub DescribeInstanceAttribute {
    my ($self, $opts) = @_;
    my $aliyun = $self->{"aliyun"};

    return $aliyun->Request($self->Action("DescribeInstanceAttribute", $opts));
}

sub DescribeInstances {
    my ($self, $opts) = @_;
    my $aliyun = $self->{"aliyun"};

    return $aliyun->Request($self->Action("DescribeInstances", $opts));
}

sub DeleteInstance {
    my ($self, $opts) = @_;
    my $aliyun = $self->{"aliyun"};

    return $aliyun->Request($self->Action("DeleteInstance", $opts));
}
### Instance End

### Security Group Start
sub DescribeSecurityGroups {
    my ($self, $opts) = @_;
    my $aliyun = $self->{"aliyun"};

    return $aliyun->Request($self->Action("DescribeSecurityGroups", $opts));
}
### Security Group End

### Common Function Start
sub Action {
    my ($self, $action, $opts) = @_;
    my $Action = {
        "Action" => $action,
        "RegionId" => $self->{"RegionId"}
    };
    &Extend($Action, $opts);
    return $Action;
}

sub Extend {
    my ($a, $b) = @_;
    foreach my $key (keys %{$b}) {
        $a->{$key} = $b->{$key};
    }
    return $a;
}
### Common Function End

1;
