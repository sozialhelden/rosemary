module Rosemary
  class OauthClient

    attr_reader :access_token

    def initialize(access_token)
      @access_token = access_token
    end

    def get(url, header={})
      access_token.get(url, {'Content-Type' => 'application/xml' })
    end

    def put(url, options={}, header={})
      body = options[:body]
      access_token.put(url, body, {'Content-Type' => 'application/xml' })
    end

    def delete(url, options={}, header={})
      raise NotImplemented.new("Delete with Oauth and OSM is not supported")
      # body = options[:body]
      # access_token.delete(url, {'Content-Type' => 'application/xml' })
    end

    def post(url, options={}, header={})
      body = options[:body]
      access_token.post(url, body, {'Content-Type' => 'application/xml' })
    end

  end
end