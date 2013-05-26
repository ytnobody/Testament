requires 'perl', '5.008001';
requires 'Net::EmptyPort', 0;
requires 'Log::Minimal', 0;
requires 'File::Which', 0;
requires 'JSON', 0;
requires 'Digest::SHA2', 0;
requires 'List::Util', 0;
requires 'Class::Load', 0;
requires 'Furl', '2.10';
requires 'Expect', 0;
requires 'IO::Stty', 0;
requires 'Time::HiRes', 0;

on 'build' => sub {
    requires 'Test::More', '0.98';
    requires 'Scope::Guard', '0.20';
    requires 'Capture::Tiny', 0;
};
