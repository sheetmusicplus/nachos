NACHOS
------

Nachos keeps people from taking your stuff. It's mine, nachos!

You need to generate a public and private key to bootstrap it.

For more info, check here: (http://ohlol.net/2009/07/announcing-nachos.html).

INSTALL
-------

    % sudo gem sources -a http://gems.github.com
    % sudo gem install ohlol-nachos

SETUP/BOOTSTRAP
---------------

    % openssl genrsa -des3 -out config/private.pem 2048
      <enter passphrase>
      <repeat passphrase>
    % openssl rsa -in config/private.pem -pubout -out config/public.pem

EXAMPLE USAGE
-------------

to store:

    require 'nachos'
    

    config = {
      :public_key => 'config/public.pem',
      :private_key => 'config/private.pem',
      :secret_key => 'config/secret-key.yml',
      :data_store => 'config/secret-data.enc'
    }

    e = Nachos::Encryptor('password')
    e.clear_data = 'foo bar baz'
    e.save_data

to load:

    e.load_data
    puts e.clear_data
