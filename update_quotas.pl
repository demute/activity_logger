#!/usr/bin/perl
use strict;
use warnings;
use JSON;
use FindBin;


my $maxTimeMins = 60*24*7;
my $maxIdleTime = 120;

my %dict =
(
    "discord" => {"hist" => [], "maxQuota" =>  45, "refill" => 45/(3*60),     "patterns" => ["discord"]},
    "gaming"  => {"hist" => [], "maxQuota" => 120, "refill" => 120/(2*24*60), "patterns" => ["roblox","minecraft"]},
    "youtube" => {"hist" => [], "maxQuota" =>  60, "refill" => 60/(6*60),     "patterns" => ["youtube"]},
);

my $file  = "$FindBin::Bin/activity_log.jsonl";

open my $fh, '<', $file or die $!;

my $maxLines = $maxTimeMins;
my @logEntries;
while (<$fh>) {
    chomp;
    push @logEntries, $_;
    shift @logEntries if @logEntries > $maxLines;
}
close $fh;

for(@logEntries)
{
    my $j = from_json ($_) || next;
    next if ($j->{idleTime} > $maxIdleTime);

    my $elapsed = int((time - $j->{timestamp})/60);
    next if ($elapsed > $maxTimeMins);

    my $str = $j->{title};
    if ($j->{url}) {
        $str .= " $j->{pageTitle} / $j->{url}";
    }

    $str =~ tr/[A-Z]/[a-z]/;

    for my $account (keys %dict)
    {
        my $obj = $dict{$account};
        my @patterns = @{$obj->{patterns}};
        for my $pattern (@patterns) {
            if ($str =~ /$pattern/) {
                $obj->{hist}->[$elapsed] += 1;
            }
        }
    }
}

for my $account (sort keys %dict) {
    my $obj      = $dict{$account};
    my $hist     = $obj->{hist};
    my $refill   = $obj->{refill};
    my $maxQuota = $obj->{maxQuota};

    my $quota    = $maxQuota;

    for my $elapsed (reverse 0..$maxTimeMins) {
        my $usage = $hist->[$elapsed];
        if ($usage) {
            $quota -= $usage;
            $quota = 0 if ($quota < 0);
            $quota = int (($quota * 10000) + 0.5) / 10000;
            #print "decrement account $account by $usage => state: $quota\n";
        }
        else {
            $quota += $refill;
            $quota = $maxQuota if ($quota) > $maxQuota;
            $quota = int (($quota * 10000) + 0.5) / 10000;
            #print "increment account $account by $obj->{refill} => state: $quota\n";
        }
    }

    $obj->{quota} = $quota;
}

my $output = {};
for my $account (sort keys %dict) {
    my $quota = $dict{$account}->{quota};
    $output->{$account} = $quota;
}
print to_json ($output), "\n";
