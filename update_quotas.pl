#!/usr/bin/perl
use strict;
use warnings;
use JSON;
use FindBin;


my $maxTimeMins = 60*24*7;
my $maxIdleTime = 120;

my $minsPerHour = 60;
my $minsPerDay  = 24 * 60;
my %dict =
(
    "discord" => {"hist" => [], "maxQuota" =>  45, "refillTime" => 3 * $minsPerHour, "patterns" => ["discord"]},
    "gaming"  => {"hist" => [], "maxQuota" => 120, "refillTime" => 2 * $minsPerDay,  "patterns" => ["roblox","minecraft"]},
    "youtube" => {"hist" => [], "maxQuota" =>  60, "refillTime" => 6 * $minsPerHour, "patterns" => ["youtube"], "exclusions" => ["tutorial"]},
);

my $file      = $ARGV[0] // "$FindBin::Bin/activity_log.jsonl";
my $json_file = $ARGV[1] // "$FindBin::Bin/current_quotas.json";
my $txt_file  = $ARGV[2] // "$FindBin::Bin/current_quotas.txt";

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
    my $j = eval { from_json($_) } // next;
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
                my $excluded = 0;

                if ($obj->{exclusions}) {
                    my @exclusions = @{$obj->{exclusions}};
                    for my $exclusion (@exclusions) {
                        $excluded = 1 if ($str =~ /$exclusion/);
                    }
                }

                $obj->{hist}->[$elapsed] += 1 unless $excluded;
            }
        }
    }
}

my $output = {};
for my $account (sort keys %dict) {
    my $obj        = $dict{$account};
    my $hist       = $obj->{hist};
    my $maxQuota   = $obj->{maxQuota};
    my $refillTime = $obj->{refillTime};
    my $refillRate = $maxQuota / $refillTime;

    my $quota = $maxQuota;

    for my $elapsed (reverse 0..$maxTimeMins) {
        my $usage = $hist->[$elapsed];
        if ($usage) {
            $quota -= $usage;
            $quota = 0 if ($quota < 0);
            $quota = int (($quota * 10000) + 0.5) / 10000;
            #print "decrement account $account by $usage => state: $quota\n";
        }
        else {
            $quota += $refillRate;
            $quota = $maxQuota if ($quota) > $maxQuota;
            $quota = int (($quota * 10000) + 0.5) / 10000;
            #print "increment account $account by $obj->{refill} => state: $quota\n";
        }
    }


    $output->{$account} = {quota => $quota, refillTime => $refillTime, maxQuota => $maxQuota};
}

open my $json_fh, '>', $json_file or die $!;
print $json_fh to_json($output), "\n";
close $json_fh;

open my $txt_fh, '>', $txt_file or die $!;
for my $key (sort keys %$output) {
    print $txt_fh "$key ", $output->{$key}->{quota}, "\n";
}
close $txt_fh;
