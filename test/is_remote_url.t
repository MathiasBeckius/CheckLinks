use diagnostics;
use strict;
use warnings;

use Test::More 'no_plan';
use CheckLinks;

# Given:
#  * An empty line.
# Expected:
#  * An empty line is definitely not a remote URL, therefore we expect 0.
{
  is(is_remote_url(''), 0);
}

# Given:
#  * An incomplete HTTP address.
# Expected:
#  * For an incomplete address, we expect 0.
{
  is(is_remote_url('http://'), 0);
}

# Given:
#  * An incomplete HTTPS address.
# Expected:
#  * For an incomplete address, we expect 0.
{
  is(is_remote_url('https://'), 0);
}

# Given:
#  * An invalid URL (invalid protocol).
# Expected:
#  * Since an invalid protocol is specified, we expect 0.
{
  is(is_remote_url('httpss://www.google.com'), 0);
}

# Given:
#  * An URL that looks like a HTTP address.
# Expected:
#  * This seems to be a valid URL, therefore we expect 1.
{
  is(is_remote_url('http://www.google.com'), 1);
}

# Given:
#  * An URL that looks like a HTTPS address.
# Expected:
#  * This seems to be a valid URL, therefore we expect 1.
{
  is(is_remote_url('https://www.google.com'), 1);
}
