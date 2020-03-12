class TokenAuthenticationService < ApplicationService
  ALGORITHM = 'HS256'

  def initialize(request)
    @request = request
  end

  def call
    verification
  end

  private

  def decoded_token
    JWT.decode(request_token, hmac_secret, true, { algorithm: ALGORITHM }).first
  rescue JWT::VerificationError
    {password: ''}
  end

  def request_token
    @request.headers['Authorization'].split(' ').last
  end

  def hmac_secret
    ENV['HMAC_SECRET']
  end

  def verification
    decoded_token["password"] === ENV['AUTHENTICATION_PASSWORD']
  end
end
