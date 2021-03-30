require 'base64'

class DataEncryption
  attr_reader :cipher, :key, :iv

  def initialize(key:)
    @cipher = OpenSSL::Cipher.new('aes-256-ctr')
    @key = key
    @iv = @key[0..15]
  end

  def encrypt(data)
    cipher.encrypt
    cipher.key = key
    cipher.iv = iv
    result = cipher.update(data)
    result << cipher.final

    Base64.encode64(result)
  end

  def decrypt(data)
    cipher.decrypt
    cipher.key = key
    cipher.iv = iv
    raw_decrypted_data = cipher.update(
      Base64.decode64(data)
    )
    raw_decrypted_data << cipher.final

    raw_decrypted_data
  end
end
