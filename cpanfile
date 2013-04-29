requires 'perl', '5.008001';
requires 'Net::EmptyPort', '0';
requires 'LWP::UserAgent', '0';
requires 'Log::Minimal', '0';

on 'test' => sub {
    requires 'Test::More', '0.98';
};

