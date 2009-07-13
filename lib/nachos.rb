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
        :secret_data => config_dir + '/secret-stuff.enc'
      }
    else
      @@config = {
        :public_key => config[:public_key],
        :private_key => config[:private_key],
        :secret_key => config[:secret_key],
        :secret_data => config[:secret_data]
      }
    end
  end

  class EncryptorException < IOError; end
end

class Nachos::Encryptor
  include Nachos

  # secret_key, secret_iv, data are encrypted and readable by the caller
  # clear_data is writeable/readable by the caller
  attr_reader :secret_key, :secret_iv
  attr_accessor :clear_data, :data

  # pass an optional encrypted secret key & iv
  # we'll decrypt it and store it for private use
  def initialize(password, secret_key = nil, secret_iv = nil)
    begin
      @public_key = OpenSSL::PKey::RSA.new(File.open(self.config[:public_key]))
      @private_key =
        OpenSSL::PKey::RSA.new(File.open(self.config[:private_key]), password)
      @cipher = OpenSSL::Cipher::Cipher.new('aes-256-cbc')

      if secret_key && secret_iv
        # @clear_secret_key, @clear_secret_iv are decrypted
        @clear_secret_key = @private_key.private_decrypt(secret_key)
        @clear_secret_iv = @private_key.private_decrypt(secret_iv)
      else
        @cipher.encrypt
        @clear_secret_key = @cipher.random_key
        @clear_secret_iv = @cipher.random_iv
        @secret_key = @public_key.public_encrypt(@clear_secret_key)
        @secret_iv = @public_key.public_encrypt(@clear_secret_iv)
      end
    rescue Errno::ENOENT
      raise Nachos::EncryptorException,
        "Public or private key missing! (maybe both!)"
    end
  end

  def encrypt
    @cipher.encrypt
    @data = @public_key.public_encrypt(@clear_data)
  end

  def decrypt
    @cipher.decrypt
    @cipher.key = @clear_secret_key
    @cipher.iv = @clear_secret_iv
    @clear_data = @private_key.private_decrypt(@data)
  end
end

class Nachos::KeyStore
  include Nachos

  attr_accessor :key_e, :iv_e

  def initialize(password, config = {})
    @keypair_password = password
    self.config = config
    get_secrets
  end

  def get_secrets
    unless @key_e && @iv_e
      begin
        y_data = YAML::load(File.open(self.config[:secret_key]))

        @key_e = Base64.decode64(y_data[:key])
        @iv_e = Base64.decode64(y_data[:iv])
      rescue Errno::ENOENT
        gen_secrets
        save_secrets
      end
    end
  end

  private

  def gen_secrets
    encryptor = Nachos::Encryptor.new(@keypair_password)
    @key_e = encryptor.secret_key
    @iv_e = encryptor.secret_iv
  end

  def save_secrets
    stuff = {
      :key => Base64.encode64(@key_e),
      :iv => Base64.encode64(@iv_e)
    }

    File.open(self.config[:secret_key], 'w') do |f|
      f.puts stuff.to_yaml
    end
  end
end
