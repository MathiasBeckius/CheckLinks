use diagnostics;
use strict;
use warnings;

use Test::More 'no_plan';
use CheckLinks;

# Given:
#  * An empty line.
# Expected:
#  * Remaining line is empty.
#  * No URL.
{
  my ($line, $url) = extract_url('');
  is($line, '');
  is($url, '');
}

# Given:
#  * Line with plain text.
# Expected:
#  * Original line remains.
#  * No URL.
{
  my $text = 'Lorem ipsum dolor est...';
  my ($line, $url) = extract_url($text);
  is($line, $text);
  is($url, '');
}

# Given:
#  * Line with plain text, passed via $_
# Expected:
#  * Original line remains.
#  * No URL.
{
  my $text = $_ = 'Lorem ipsum dolor est...';
  my ($line, $url) = extract_url;
  is($line, $text);
  is($url, '');
}

# Given:
#  * Line with an invalid anchor tag.
# Expected:
#  * Original line remains.
#  * No URL.
{
  my $original_line = "<ahref=\"http://www.a.com\">a.com</a>";
  my ($line, $url) = extract_url($original_line);
  is($line, $original_line);
  is($url, '');
}

# Given:
#  * Line with an invalid image tag.
# Expected:
#  * Original line remains.
#  * No URL.
{
  my $original_line = "<imgsrc=\"http://www.a.com/image.jpg\">";
  my ($line, $url) = extract_url($original_line);
  is($line, $original_line);
  is($url, '');
}

# Given:
#  * Line with an anchor tag.
#  * The anchor tag does only contain a 'href' parameter.
# Expected:
#  * Remaining line is empty.
#  * An URL is extracted.
{
  my $exp_url = 'http://www.a.com';
  my $line = "<a href=\"${exp_url}\">a.com</a>";
  ($line, my $url) = extract_url($line);
  is($line, '');
  is($url, $exp_url);
}

# Given:
#  * Line with an image tag.
#  * The image tag does only contain a 'src' parameter.
# Expected:
#  * Remaining line is empty.
#  * An URL is extracted.
{
  my $exp_url = 'http://www.a.com/image.jpg';
  my $line = "<img src=\"${exp_url}\"/>";
  ($line, my $url) = extract_url($line);
  is($line, '');
  is($url, $exp_url);
}

# Given:
#  * Line with an anchor tag, followed by a newline character.
#  * The anchor tag does only contain a 'href' parameter.
# Expected:
#  * Remaining line contains only the newline character.
#  * An URL is extracted.
{
  my $exp_url = 'http://www.a.com';
  my $line = "<a href=\"${exp_url}\">a.com</a>\n";
  ($line, my $url) = extract_url($line);
  is($line, "\n");
  is($url, $exp_url);
}

# Given:
#  * Line with an image tag, followed by a newline character.
#  * The image tag does only contain a 'src' parameter.
# Expected:
#  * Remaining line contains only the newline character.
#  * An URL is extracted.
{
  my $exp_url = 'http://www.a.com/image.jpg';
  my $line = "<img src=\"${exp_url}\"/>\n";
  ($line, my $url) = extract_url($line);
  is($line, "\n");
  is($url, $exp_url);
}

# Given:
#  * Line with an anchor tag, typed with mixed-case letters.
#  * The anchor tag does only contain a 'href' parameter.
# Expected:
#  * Remaining line is empty.
#  * An URL is extracted.
{
  my $exp_url = 'http://www.a.com';
  my $line = "<A HreF=\"${exp_url}\">a.com</a>";
  ($line, my $url) = extract_url($line);
  is($line, '');
  is($url, $exp_url);
}

# Given:
#  * Line with an image tag, typed with mixed-case letters.
#  * The image tag does only contain a 'src' parameter.
# Expected:
#  * Remaining line is empty.
#  * An URL is extracted.
{
  my $exp_url = 'http://www.a.com/image.jpg';
  my $line = "<Img SRC=\"${exp_url}\"/>";
  ($line, my $url) = extract_url($line);
  is($line, '');
  is($url, $exp_url);
}

# Given:
#  * Line with an anchor tag.
#  * The anchor tag has a 'style' parameter before the 'href' parameter.
# Expected:
#  * Remaining line is empty.
#  * An URL is extracted.
{
  my $exp_url = 'http://www.a.com';
  my $line = "<a style=\"foobar\" href=\"${exp_url}\">a.com</a>";
  ($line, my $url) = extract_url($line);
  is($line, '');
  is($url, $exp_url);
}

# Given:
#  * Line with an image tag.
#  * The image tag has a 'alt' and a 'title' parameter before the 'src' parameter.
# Expected:
#  * Remaining line is empty.
#  * An URL is extracted.
{
  my $exp_url = 'http://www.a.com/image.jpg';
  my $line = "<img alt=\"An image\" title=\"An image\" src=\"${exp_url}\" />";
  ($line, my $url) = extract_url($line);
  is($line, '');
  is($url, $exp_url);
}

# Given:
#  * Line with an anchor tag.
#  * The anchor tag has a 'style' parameter after the 'href' parameter.
# Expected:
#  * Remaining line is empty.
#  * An URL is extracted.
{
  my $exp_url = 'http://www.a.com';
  my $line = "<a href=\"${exp_url}\" style=\"foobar\">a.com</a>";
  ($line, my $url) = extract_url($line);
  is($line, '');
  is($url, $exp_url);
}

# Given:
#  * Line with an image tag.
#  * The image tag has a 'alt' and a 'title' parameter after the 'src' parameter.
# Expected:
#  * Remaining line is empty.
#  * An URL is extracted.
{
  my $exp_url = 'http://www.a.com/image.jpg';
  my $line = "<img src=\"${exp_url}\" alt=\"An image\" title=\"An image\" />";
  ($line, my $url) = extract_url($line);
  is($line, '');
  is($url, $exp_url);
}

# Given:
#  * Line with two anchor tags.
#  * The anchor tags does only contain 'href' parameters.
# Expected:
#  * Remaining line is empty.
#  * Two URL's are extracted.
{
  my $url;
  my $exp_url1 = 'http://www.a.com';
  my $exp_url2 = 'http://www.b.com';
  my $a_tag1 = "<a href=\"${exp_url1}\">a.com</a>";
  my $a_tag2 = "<a href=\"${exp_url2}\">b.com</a>";
  my $line = $a_tag1.$a_tag2;
  ($line, $url) = extract_url($line);
  is($line, $a_tag2);
  is($url, $exp_url1);
  ($line, $url) = extract_url($line);
  is($line, '');
  is($url, $exp_url2);
}

# Given:
#  * Line with an anchor tag with some surrounding text.
#  * The anchor tag does only contain a 'href' parameter.
# Expected:
#  * Remaining line does only contain the original surrounding text.
#  * An URL is extracted.
{
  my $url;
  my $exp_url = 'http://www.a.com';
  my $text1 = 'Some text before the anchor tag ';
  my $a_tag = "<a href=\"${exp_url}\">a.com</a>";
  my $text2 = ' and some text after the anchor tag!';
  my $line = $text1.$a_tag.$text2;
  ($line, $url) = extract_url($line);
  is($line, $text1.$text2);
  is($url, $exp_url);
}
