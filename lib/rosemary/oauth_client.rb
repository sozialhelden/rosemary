class Rosemary::OauthClient < Rosemary::Client

  # The access token to be used for all write access
  # @return [OAuth::AccessToken]
  attr_reader :access_token

  # @param [OAuth::AccessToken] access_token the access token to be used for write access.
  def initialize(access_token)
    @access_token = access_token
  end

  # Execute a signed OAuth GET request.
  # @param [String] url the url to be requested
  # @param [Hash] header optional header attributes
  def get(url, header={})
    access_token.get(url, {'Content-Type' => 'application/xml' })
  end

  # Execute a signed OAuth PUT request.
  # @param [String] url the url to be requested
  # @param [Hash] options optional option attributes
  # @param [Hash] header optional header attributes
  def put(url, options={}, header={})
    body = options[:body]
    access_token.put(url, body, {'Content-Type' => 'application/xml' })
  end

  # Execute a signed OAuth DELETE request.
  #
  # Unfortunately the OSM API requires to send an XML
  # representation of the Element to be delete in the body
  # of the request. The OAuth library does not support sending
  # any information in the request body.
  # If you know a workaround please fork and improve.
  def delete(url, options={}, header={})
    raise NotImplemented.new("Delete with Oauth and OSM is not supported")
    # body = options[:body]
    # access_token.delete(url, {'Content-Type' => 'application/xml' })
  end

  # Execute a signed OAuth POST request.
  # @param [String] url the url to be requested
  # @param [Hash] options optional option attributes
  # @param [Hash] header optional header attributes
  def post(url, options={}, header={})
    body = options[:body]
    access_token.post(url, body, {'Content-Type' => 'application/xml' })
  end

end