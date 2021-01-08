#!/usr/bin/perl

###############################################################################
# Check links in HTML-files
#
# One or several HTML-files are scanned for broken URL's,
# both relative path and http-links (assumes a working internet connection).
###############################################################################

use diagnostics;
use strict;
use warnings;

use Cwd 'abs_path';
use File::Basename 'dirname';
use File::Spec;
use lib File::Spec->catdir(dirname(abs_path($0)), '.', 'lib');

use File::Find;

use CheckLinks;

sub print_usage {
  print "Usage: check_links.pl [path]\n\n";
  print "  [path] Path to a directory containing HTML-files or\n";
  print "         or path to a HTML-file (*.html).\n\n";
  print "Please note that non-readable files or directories are invalid!\n";
  print "Non-readable files in a directory will be ignored!";
}

sub terminate {
  my ($msg) = @_;
  print $msg, "\n\n";
  print_usage();
  exit(1);
}

# Incoming parameter is file path.
sub is_html_file {
  my ($path) = (@_) ? @_ : $_;
  return (-r $path and -T $path and $path =~ /\.html$/);
}

# Incoming parameter is directory path.
# Recursive search in this directory.
sub scan_dir {
  my ($path) = @_;
  my @files;
  find(sub { push @files, $File::Find::name; }, ($path));
  return @files;
}

sub validate_path {
  my ($path) = @_;
  terminate("Path does not exist: $path") unless -e $path;
  terminate("$path is not readable!") unless -r $path;
  if (-d $path) {
    my @files = grep { is_html_file } scan_dir($path);
    terminate("Found no HTML-files in $path") unless (scalar(@files) > 0);
    return @files;
  }
  terminate("$path is not an HTML-file") unless is_html_file($path);
  return ($path);
}

sub check_files {
  my @files = @_;
  my $nr_of_files = @files;
  my $nr_of_files_w_errors = 0;
  my $nr_of_broken_links = 0;
  print "Checking $nr_of_files file(s)...\n";
  for my $file_path (@files) {
    my @broken_links = check_links($file_path);
    next if scalar(@broken_links) == 0;
    $nr_of_broken_links += scalar(@broken_links);
    print "\n[$file_path]\n";
    for my $item (@broken_links) {
      my %link = %$item;
      printf("%-6d %s\n", $link{'row'}, $link{'url'});
    }
    $nr_of_files_w_errors++;
  }
  print "\nFound $nr_of_broken_links broken link(s) in ",
        "$nr_of_files_w_errors of $nr_of_files file(s)\n";
}

my $nr_of_args = $#ARGV + 1;
terminate("Invalid number of arguments") if ($nr_of_args != 1);
my $path = $ARGV[0];

my @files = validate_path($path);
check_files(@files);
