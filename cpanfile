requires 'perl', '5.008001';
requires 'Data::Section::Simple';
requires 'File::pushd';
requires 'Minilla';
requires 'Moo';

on 'test' => sub {
    requires 'Test::More', '0.98';
};

