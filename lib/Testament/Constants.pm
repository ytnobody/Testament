package Testament::Constants;
use strict;
use warnings;
use Exporter 'import';

our @EXPORT_OK = (qw(
    CHEF_INSTALLER_URL
    RBENV_REPO
    RUBYBUILDER_REPO
    SPAWN_TIMEOUT
));

use constant CHEF_INSTALLER_URL => 'https://raw.github.com/ytnobody/Testament/master/script/install-chef-solo.sh';
use constant RBENV_REPO         => 'https://github.com/sstephenson/rbenv.git';
use constant RUBYBUILDER_REPO   => 'https://github.com/sstephenson/ruby-build.git';
use constant SPAWN_TIMEOUT      => 20;

1;
