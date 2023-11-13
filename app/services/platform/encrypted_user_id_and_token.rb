module Platform
  module EncryptedUserIdAndToken
    def encrypted_user_id_and_token
      return '' if service_secret.blank?

      DataEncryption.new(
        key: service_secret
      ).encrypt("#{session[:user_id]}#{session[:user_token]}")
    end
  end
end
