requires 'perl', '5.008001';
requires 'Net::EmptyPort', '0';
requires 'LWP::UserAgent', '0';
requires 'Log::Minimal', '0';
requires 'IP::Country', '0';
requires 'JSON', '0';
requires 'Digest::SHA2', '0';

on 'build' => sub {
    requires 'Test::More', '0.98';
    requires 'Scope::Guard', '0.20';
};
