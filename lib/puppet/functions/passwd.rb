require 'unix_crypt'
# @summary
#   Used to encode password for vsftpd

Puppet::Functions.create_function(:passwd) do
  # @param scope
  #
  #
  # @param args
  #   String to encrypt
  #
  # @return [String]
  #   Encrypted password (String)
  dispatch :passwd do
    param 'String', :password
    param 'String', :salt
  end
  def passwd(password, salt)
    UnixCrypt::MD5.build(password, salt)
  end
end
