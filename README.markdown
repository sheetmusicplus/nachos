NACHOS
------

Nachos keeps people from taking your stuff. It's mine, nachos!

I recently needed the ability to programatically encrypt and decrypt data on
the fly for operations support purposes (code releases, etc). I considered
writing a script, but it just didn't seem very clean. Plus, the main reason I
needed it was for software deployment, which I execute in Rake tasks.

It uses two levels of encryption:

   1. AES-256 CBC encryption of the data with a secret key and an IV
   2. PKI encryption (private key is 3DES encrypted, too!) of the secret key
and IV

While it's arguably unnecessary to encrypt the IV, I did want to be able to
store my secret key without worrying about it getting compromised. This allows
me to keep all of my keystores where ever I want, including a SCM. For stuff
like code releases, this is huge.

Another really cool facet of this is that I can keep revisioned copies of not
only my sensitive data, but also my keystores! Oh yeah.

You need to generate a public and private key to bootstrap it.

For more info, check here: http://ohlol.net/2009/07/announcing-nachos.html

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
