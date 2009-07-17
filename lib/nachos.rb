module Nachos
  require 'openssl'
  require 'yaml'
  require 'base64'

  def config
    @@config
  end

  def config=(config = {})
    if config.empty?
      config_dir = File.join(File.dirname(__FILE__), '../conf')

      @@config = {
        :public_key => config_dir + '/public.pem',
        :private_key => config_dir + '/private.pem',
        :secret_key => config_dir + '/secret-key.yml',
        :data_store => config_dir + '/secret-data.enc'
      }
    else
      @@config = {
        :public_key => config[:public_key],
        :private_key => config[:private_key],
        :secret_key => config[:secret_key],
        :data_store => config[:data_store]
      }
    end
  end

  class EncryptorException < IOError; end
  class KeyStoreException < IOError; end
end

class Nachos::Encryptor
  include Nachos

  # secret_key, secret_iv, data are encrypted and readable by the caller
  # clear_data is writeable/readable by the caller
  attr_reader :secret_key, :secret_iv
  attr_accessor :clear_data, :encrypted_data
  attr_reader :keystore

  # pass an optional encrypted secret key & iv
  # we'll decrypt it and store it for private use
  def initialize(password, config = {})
    self.config = config
    @secret_key = @secret_iv = @clear_data = @encrypted_data = ''

    begin
      @public_key = OpenSSL::PKey::RSA.new(File.open(self.config[:public_key]))
      @private_key =
        OpenSSL::PKey::RSA.new(File.open(self.config[:private_key]), password)
      @keystore = Nachos::KeyStore.new

      keypair
    rescue Errno::ENOENT
      raise Nachos::EncryptorException, "Public or private key missing! " +
        "(maybe both!)"
    rescue Nachos::KeyStoreException => e
      raise
    rescue => e
      raise Nachos::EncryptorException, "There was a problem loading or " +
        "decrypting the keypair and/or keystore! (#{e})" 
    end
  end

  def keypair
    if @keystore.secret_key.empty? || @keystore.secret_iv.empty?
      begin
        cipher = OpenSSL::Cipher::Cipher.new('aes-256-cbc')

        @clear_secret_key = cipher.random_key
        @clear_secret_iv = cipher.random_iv

        @secret_key = @keystore.secret_key =
          @public_key.public_encrypt(@clear_secret_key)
        @secret_iv = @keystore.secret_iv =
          @public_key.public_encrypt(@clear_secret_iv)
        @keystore.save_secrets
      rescue => e
        raise Nachos::EncryptorException, "There was a problem generating " +
          "random secret key and/or IV!"
      end
    else
      @secret_key = @keystore.secret_key
      @secret_iv = @keystore.secret_iv
    end

    @clear_secret_key = @private_key.private_decrypt(@secret_key)
    @clear_secret_iv = @private_key.private_decrypt(@secret_iv)
  end

  def encrypt(str)
    if str.empty?
      raise Nachos::EncryptorException, "What do you want to encrypt?"
    else
      begin
        cipher = OpenSSL::Cipher::Cipher.new('aes-256-cbc')

        cipher.encrypt
        cipher.key = @clear_secret_key
        cipher.iv = @clear_secret_iv

        str_e = cipher.update(str)
        str_e << cipher.final
      rescue => e
        raise Nachos::EncryptorException, "Couldn't encrypt the data! (#{e})"
      end
    end
  end

  def decrypt(str)
    if str.empty?
      raise Nachos::EncryptorException, "What do you want to decrypt?"
    else
      begin
        cipher = OpenSSL::Cipher::Cipher.new('aes-256-cbc')

        cipher.decrypt
        cipher.key = @clear_secret_key
        cipher.iv = @clear_secret_iv

        str_d = cipher.update(str)
        str_d << cipher.final
      rescue => e
        raise Nachos::EncryptorException, "Couldn't decrypt the data! (#{e})"
      end
    end
  end

  def load_data
    begin
      @encrypted_data = ''

      File.open(self.config[:data_store], 'r') do |f|
        @encrypted_data = @encrypted_data + f.gets
      end

      @encrypted_data.chomp!
      @clear_data = decrypt(Base64.decode64(@encrypted_data))
    rescue Errno::ENOENT
    rescue => e
      raise Nachos::EncryptorException, "There was a problem reading the " +
        "data store! (#{e})"
    end
  end

  def save_data
    if @encrypted_data.empty?
      @encrypted_data = encrypt(@clear_data)
    end

    begin
      File.open(self.config[:data_store], 'w') do |f|
        f.puts Base64.encode64(@encrypted_data)
      end
    rescue
      raise Nachos::EncryptorException, "There was a problem saving the data " +
        "store!"
    end
  end
end

class Nachos::KeyStore
  include Nachos

  attr_accessor :secret_key, :secret_iv

  def initialize
    @secret_key = @secret_iv = ''
    get_secrets
  end

  def get_secrets
    begin
      y_data = YAML::load(File.open(self.config[:secret_key]))

      if y_data
        @secret_key = Base64.decode64(y_data[:key])
        @secret_iv = Base64.decode64(y_data[:iv])
      end
      # file was empty for some reason, we'll have to generate a new set.
      # hope we didn't need to decrypt anything!
    rescue Errno::ENOENT
      # fail silently; we'll just generate a new set
    rescue => e
      raise Nachos::KeyStoreException, "There was a problem loading the " +
        "keystore! (#{e})"
    end
  end

  def save_secrets
    stuff = {
      :key => Base64.encode64(@secret_key),
      :iv => Base64.encode64(@secret_iv)
    }

    begin
      File.open(self.config[:secret_key], 'w') do |f|
        f.puts stuff.to_yaml
      end
    rescue => e
      raise Nachos::KeyStoreException, "There was a problem saving the " +
        "keystore! (#{e})"
    end
  end
end
