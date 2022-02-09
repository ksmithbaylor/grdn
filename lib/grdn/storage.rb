require 'fileutils'
require 'openssl'
require 'digest'

module Grdn
  class Storage
    DIR_NAME = '.grdn'
    DEFAULT_LOCATION = File.expand_path(File.join(ENV['HOME'], DIR_NAME))
    SALT = "\xB9R\xB5d\xBC#I?I7\x85<\xCD\xD6UW"
    VALUE_FILENAME = 'seed.enc'
    FINAL_MARKER = '____final____'
    KEY_TEXT = 'password is correct'

    def initialize(password, location = DEFAULT_LOCATION)
      @location = location
      @key = key_for(password)
      FileUtils.mkdir_p @location
      set_or_verify_password
    end

    def set(path, value)
      if exists? path
        raise Grdn::Error.new('Already exists, refusing to overwrite') 
      end

      FileUtils.mkdir_p dir_for(path)
      File.write value_file_for(path), encrypt(value)
    end

    def get(path)
      unless exists? path
        raise Grdn::Error.new('Does not exist') 
      end

      decrypt File.read(value_file_for(path))
    end

    def remove(path)
      FileUtils.rm_rf dir_for(path)
    end

    def list
      absolute_paths = Dir.glob(File.join(@location, '**', VALUE_FILENAME))
      paths = absolute_paths
        .map { |p| File.dirname p }
        .map { |p| p.gsub(@location + '/', '') }
        .map { |p| p.split('/') }

      tree = {}
      
      paths.each do |path|
        cursor = tree
        path.each do |part|
          cursor[part] ||= {}
          cursor = cursor[part]
        end
        cursor[FINAL_MARKER] = true
      end
      
      tree
    end

    private

    def exists?(path)
      File.exist? value_file_for(path)
    end

    def set_or_verify_password
      keyfile = File.join(@location, '.key')
      if File.exist? keyfile
        decrypt File.read(keyfile)
      else
        File.write(keyfile, encrypt(KEY_TEXT))
      end
    rescue OpenSSL::Cipher::CipherError
      raise Grdn::Error.new('Wrong password')
    end

    def dir_for(path)
      File.join(@location, *path)
    end

    def value_file_for(path)
      dir = dir_for(path)
      File.join(dir, VALUE_FILENAME)
    end

    def encrypt(string)
      cipher = aes.encrypt
      cipher.key = @key
      cipher.update(string) + cipher.final
    end

    def decrypt(string)
      cipher = aes.decrypt
      cipher.key = @key
      cipher.update(string) + cipher.final
    end

    def aes
      OpenSSL::Cipher::AES.new(128, :CBC)
    end

    def key_for(password)
      OpenSSL::KDF.pbkdf2_hmac(
        password,
        salt: SALT,
        iterations: 1,
        length: 16,
        hash: OpenSSL::Digest::SHA256.new
      )
    end
  end
end
