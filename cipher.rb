=begin

ファイルの暗号化と復号

=end

require 'openssl'

class Cipher

  def initialize(i_key, i_iv = nil)
    #@key = cipher.random_key
    cipher = OpenSSL::Cipher.new('aes-256-cbc')
    @key = i_key
    unless i_iv then
      @iv = cipher.random_iv
    else
      @iv = i_iv
    end
  end

  def encrypt(i_file, i_dest)
    # encryption
    cipher = OpenSSL::Cipher.new('aes-256-cbc')
    cipher.encrypt
    cipher.key = @key
    cipher.iv = @iv
    buf = ""
    File.open(i_dest, "wb") do |outf|
      File.open(i_file, "rb") do |inf|
        while inf.read(4096, buf)
          outf << cipher.update(buf)
        end
        outf << cipher.final
      end
    end
    return @iv
  end

  def decrypt(i_file, i_dest)
    # decryption
    cipher = OpenSSL::Cipher.new('aes-256-cbc')
    cipher.decrypt
    cipher.key = @key
    cipher.iv = @iv # key and iv are the ones from above

    buf = ""
    File.open(i_dest, "wb") do |outf|
      File.open(i_file, "rb") do |inf|
        while inf.read(4096, buf)
          outf << cipher.update(buf)
        end
        outf << cipher.final
      end
    end
  end

end
