package Testament::Constants;
use strict;
use warnings;
use Exporter 'import';

our @EXPORT_OK = (qw(
    CHEF_INSTALLER_URL
    RBENV_REPO
    RUBYBUILDER_REPO
));

use constant CHEF_INSTALLER_URL => 'https://raw.github.com/ytnobody/Testament/master/script/install-chef-solo.sh';
use constant RBENV_REPO         => 'git://github.com/sstephenson/rbenv.git';
use constant RUBYBUILDER_REPO   => 'git://github.com/sstephenson/ruby-build.git';

1;
