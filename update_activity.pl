#!/usr/bin/perl
use POSIX;

no warnings 'experimental';

my $tsp = strftime "%Y-%m-%d %H:%M", localtime time;

my $activeApp = get_name_of_active_window ();

if ($activeApp eq "Google Chrome")
{
    my $title = get_title_of_active_google_chrome_tab ();
    my $url   = get_url_of_active_google_chrome_tab ();
    my $domain = $url;
    if ($url =~ /https?:\/\/([^\/]+)/)
    {
        $domain = $1;
    }

    print "$tsp;$domain;$url;$title\n";
}
else
{
    $state="NONFREE";
    print "$tsp;$activeApp\n";
}


BEGIN
{
    sub toggle_mission_control
    {
        `osascript -e 'tell application "System Events" to key code 160'`;
    }

    sub maximise_active_window
    {
        `osascript -e 'tell application "Finder" to get bounds of window of desktop' -e 'tell application "System Events" to tell process (name of first application process whose frontmost is true) to tell window 1 to set {position, size} to {{0, 0}, {item 3 of result, item 4 of result}}' > /dev/null`;
    }

    sub get_name_of_active_window
    {
        my $reply = `osascript -e 'tell application "System Events" to name of application processes whose frontmost is true'`;
        chop $reply;
        return $reply;
    }

    sub get_url_of_active_google_chrome_tab
    {
        my $reply = `osascript -e 'tell application "Google Chrome" to get URL of active tab of front window'`;
        chop $reply;
        return $reply;
    }

    sub get_title_of_active_google_chrome_tab
    {
        my $reply = `osascript -e 'tell application "Google Chrome" to get title of active tab of front window'`;
        chop $reply;
        return $reply;
    }
}
