#!/usr/bin/env perl
use strict;
use warnings;
use File::Spec;
use File::Basename 'dirname';
use lib (File::Spec->catdir(dirname(__FILE__), '..', 'lib'));

use Testament;

Testament->setup('openbsd-5.2-i386');
