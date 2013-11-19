module Forcefield
  class Request < Rack::Auth::AbstractRequest

    def with_valid_request
      if provided?
        if @auth?
          [401, {}, ["Unauthorised. Pst! You forgot to include the Auth scheme"]]
        elsif params[:consumer_key].nil?
          [401, {}, ["Unauthorised. Pst! You forgot to include the consumer key"]]
        elsif params[:signature].nil?
          [401, {}, ["Unauthorised. Pst! You forgot to sign the request"]]
        elsif params[:signature_method].nil?
          [401, {}, ["Unauthorised. Pst! You forgot to include the OAuth signature method"]]
        else
          yield request.env
        end
      else
        [401, {}, ["Unauthorised. Pst! You forgot to include an Auth header"]]
      end
    end

    def verify_signature client
      return false unless client

      header = SimpleOAuth::Header.new request.request_method, request.url, included_request_params, auth_header) 
      header.valid? consumer_secret: client.consumer_secret
    end

    def consumer_key
      params[:consumer_key]
    end

    private
    def params
      @params ||= SimpleOAuth::Header.parse auth_header
    end

    def oauth?
      scheme == :oauth
    end

    def auth_header
      @env[authorization_key]
    end

    # only include request params if Content-Type is set to application/x-www/form-urlencoded
    # (see http://tools.ietf.org/html/rfc5849#section-3.4.1)

    def included_requestparams
      request.content_type == "application/x-www-form-urlencoded" ? request.params : nil
    end

  end
end