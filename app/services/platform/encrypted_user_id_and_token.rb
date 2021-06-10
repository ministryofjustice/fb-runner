module Platform
  module EncryptedUserIdAndToken
    def encrypted_user_id_and_token
      return '' if service_secret.blank?

      DataEncryption.new(
        key: service_secret
      ).encrypt("#{user_id}#{session[:user_token]}")
    end

    def user_id
      session[:session_id]
    end
  end
end
