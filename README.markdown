NACHOS
------

Nachos keeps people from taking your stuff. It's mine, nachos!

You need to generate a public and private key to bootstrap it.

EXAMPLE USAGE
-------------

...to store:

    require 'ohlol-nachos'
    
    e = Nachos::Encryptor('password')
    e.clear_data = 'foo bar baz'
    e.save_data

...to load:

    require 'ohlol-nachos'
    
    e = Nachos::Encryptor('password)'
    e.load_data
    puts e.clear_data
