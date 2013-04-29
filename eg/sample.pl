#!/usr/bin/env perl
use strict;
use warnings;
use File::Spec;
use File::Basename 'dirname';
use lib (File::Spec->catdir(dirname(__FILE__), '..', 'lib'));

use Ament;

Ament->setup('openbsd-5.2-i386');
