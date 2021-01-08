use diagnostics;
use strict;
use warnings;

use File::Basename;
use IPC::Open3;
use Symbol 'gensym';

# Extract an URL from a <a> or <img> tag, return remaining line and the URL.
# No URL, empty URL.
# Returns ($line, $url)
sub extract_url {
  my ($line) = (@_) ? @_ : $_;
  my $a = qr/(.*?)\<a .*?href="(.*?)".*?\<\/a\>(.*\s*)$/i;
  my $img = qr/(.*?)\<img .*?src="(.*?)".*?\>(.*\s*)$/i;
  if (($line =~ /$a/) or ($line =~ /$img/)) {
    return ($1.$3, $2);
  }
  return ($line, '');
}

sub is_remote_url {
  my ($url) = @_;
  return ($url =~ /^http[s]{0,1}:\/\/\S+/) ? 1 : 0;
}

# Check if the http URL is accessible.
# Will return false if the URL is not accessible, but also if this is not
# a HTTP URL.
# Will return true for an URL that can be accessed at the moment.
sub url_exists {
  my ($url) = @_;
  return 0 unless is_remote_url($url);
  my $pid = open3(
    my $chld_in, my $chld_out, my $chld_err = gensym,
    "wget -q --method=HEAD $url");
  waitpid($pid, 0);
  return ($? >> 8) == 0;
}

# Check if link exists, relative to the HTML-file's path.
sub path_exists {
  my ($url, $file_path) = @_;
  return -e dirname($file_path).'/'.$url;
}

# Check for broken links in file ($file_path)
sub check_links {
  my ($file_path) = @_;
  my @links;
  open my $file, "<", $file_path or die "Can't open file $file_path";
  while (<$file>) {
    s/\s*(.*)\s*/$1/;
    while ($_ ne "") {
      ($_, my $url) = extract_url;
      last if ($url eq "");
      if (!url_exists($url) and !path_exists($url, $file_path)) {
        push @links, {'row' => $., 'url' => $url};
      }
    }
  }
  close $file;
  return @links;
}

1;
