require 'openssl'
require 'yaml'
require 'base64'

$conf = {
  :public_key_file => 'public.pem',
  :private_key_file => 'private.pem',
  :key_file => 'key.yml',
  :secret_stuff => 'secrets.dat'
}

module Nachos
  class EncryptorException < IOError; end

  class Encryptor
    # secret_key, secret_iv, data are encrypted and readable by the caller
    # clear_data is writeable/readable by the caller
    attr_reader :secret_key, :secret_iv
    attr_accessor :clear_data, :data

    # pass an optional encrypted secret key & iv
    # we'll decrypt it and store it for private use
    def initialize(password, secret_key = nil, secret_iv = nil)
      begin
        @public_key = OpenSSL::PKey::RSA.new(File.open($conf[:public_key_file]))
        @private_key =
          OpenSSL::PKey::RSA.new(File.open($conf[:private_key_file]), password)

        @cipher = OpenSSL::Cipher::Cipher.new('aes-256-cbc')

        # @clear_secret_key, @clear_secret_iv are decrypted
        if secret_key && secret_iv
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
        raise EncryptorException, "Public or private key missing! (maybe both!)"
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

  class KeyStore
    attr_accessor :key_e, :iv_e

    def initialize(password)
      @keypair_password = password
      get_secrets
    end

    def get_secrets
      unless @key_e && @iv_e
        begin
          y_data = YAML::load(File.open($conf[:key_file]))

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

      File.open($conf[:key_file], 'w', 0600) do |f|
        f.puts stuff.to_yaml
      end
    end
  end
end
