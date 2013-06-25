requires 'perl',                  '5.008001';
requires 'Net::EmptyPort',        0;
requires 'Log::Minimal',          0;
requires 'File::Which',           0;
requires 'JSON',                  0;
requires 'Digest::SHA2',          0;
requires 'List::Util',            0;
requires 'Class::Load',           0;
requires 'Furl',                  '2.10';
requires 'Expect',                0;
requires 'IO::Stty',              0;
requires 'Time::HiRes',           0;
requires 'URI',                   0;
requires 'Proc::Simple',          0;
requires 'Scope::Guard',          '0.20';
requires 'Data::Dumper::Concise', 0;
requires 'File::Path',            0;
requires 'File::Copy',            0;
requires 'Module::Pluggable::Object';

on 'build' => sub {
    requires 'Test::More',    '0.98';
    requires 'Capture::Tiny', 0;
    requires 'File::pushd',   '1.005';
    requires 'Archive::Tar',  '1.90';
};

on develop => sub {
    requires 'Test::Perl::Critic';
    requires 'Test::Vars';
    requires 'Test::LocalFunctions', '0.20';
};
