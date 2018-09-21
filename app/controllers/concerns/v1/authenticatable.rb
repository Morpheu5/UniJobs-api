# frozen_string_literal: true

module V1
  module Authenticatable
    include ActiveSupport::Concern

    UnauthorizedException = Class.new(StandardError)

    def verify_token(candidate_token)
      # Decode the JWT token to get the payload and user_id
      begin
        payload, _header = JWT.decode(candidate_token, nil, false)
      rescue JWT::DecodeError
        raise UnauthorizedException, 'Malformed token.'
      end
      # Use the user_id to retrieve all the possible verification keys
      db_tokens = AuthenticationToken.where(user_id: payload['sub'])
      # If no tokens can be found for this user, then we cannot proceed further
      raise UnauthorizedException, 'Who are you? Go away..' if db_tokens.empty?

      # Try to verify the token with all the keys, return [user, db_token] if one matches
      db_tokens.each do |db_token|
        JWT.decode(candidate_token, db_token.token, true, algorithm: 'HS512')
        return db_token
      rescue JWT::VerificationError
        next
      end

      # If no key in our possession verifies the token, assume the token is invalid and the user cannot be authenticated
      raise UnauthorizedException, 'Who are you? Go away.'
    end

    # For Pundit
    def current_user
      authenticate_with_http_token do |token, _options|
        db_token = verify_token(token)
        db_token&.user
      end
    end
  end
end
