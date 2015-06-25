# AliyunPerlLib

Usage:

my $aliyun = new Aliyun({"AccessKeyId" => "YourAccessKeyId", "AccessKeySecret" => "YourAccessKeySecret"});
$aliyun->Request({"Action" => "DescribeZones", "RegionId" => "cn-qingdao"});
