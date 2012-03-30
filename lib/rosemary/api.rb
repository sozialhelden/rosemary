require 'httparty'
module Rosemary

  # The Api class handles all calls to the OpenStreetMap API.
  #
  # Usage:
  #   require 'rosemary'
  #   auth_client = Rosemary::BasicAuthClient.new(:user_name => 'user', :password => 'a_password')
  #   api = Rosemary::Api.new(auth_client)
  #   @node = api.find_node(1234)
  #   @node.tags << {:wheelchair => 'no'}
  #   api.save(@node)
  class Api
    include HTTParty
    include ChangesetCallbacks
    API_VERSION = "0.6".freeze

    # the default base URI for the API
    base_uri "http://www.openstreetmap.org"
    #base_uri "http://api06.dev.openstreetmap.org/api/#{API_VERSION}"

    default_timeout 5

    parser Parser

    attr_accessor :client

    attr_accessor :changeset

    def initialize(client=nil)
      @client = client
    end

    def changeset!
      @changeset ||= create_changeset
    end

    # Get a Node with specified ID from API.
    #
    # call-seq: find_node(id) -> Rosemary::Node
    #
    def find_node(id)
      find_element('node', id)
    end

    # Get a Way with specified ID from API.
    #
    # call-seq: find_way(id) -> Rosemary::Way
    #
    def find_way(id)
      find_element('way', id)
    end

    # Get a Relation with specified ID from API.
    #
    # call-seq: find_relation(id) -> Rosemary::Relation
    #
    def find_relation(id)
      find_element('relation', id)
    end

    # Get a Changeset with specified ID from API.
    #
    # call-seq: find_changeset(id) -> Rosemary::Changeset
    #
    def find_changeset(id)
      find_element('changeset', id)
    end

    # Get the user which represented by the Rosemary::Client
    #
    # call-seq: find_user -> Rosemary::User
    #
    def find_user
      raise CredentialsMissing if client.nil?
      resp = do_authenticated_request(:get, "/user/details")
      raise resp if resp.is_a? String
      resp
    end

    # Delete an element
    def destroy(element)
      raise ChangesetMissing unless changeset.open?
      element.changeset = changeset.id
      response = delete("/#{element.type.downcase}/#{element.id}", :body => element.to_xml) unless element.id.nil?
      response.to_i # New version number
    end

    # Saves an element to the API.
    # If it has no id yet, the element will be created, otherwise updated.
    def save(element)
      response = if element.id.nil?
        create(element)
      else
        update(element)
      end
    end

    def create(element)
      raise ChangesetMissing unless changeset.open?
      element.changeset = changeset.id
      put("/#{element.type.downcase}/create", :body => element.to_xml)
    end

    def update(element)
      raise ChangesetMissing unless changeset.open?
      element.changeset = changeset.id
      response = put("/#{element.type.downcase}/#{element.id}", :body => element.to_xml)
      response.to_i # New Version number
    end

    def create_changeset
      changeset = Changeset.new
      changeset_id = put("/changeset/create", :body => changeset.to_xml).to_i
      find_changeset(changeset_id) unless changeset_id == 0
    end

    def close_changeset
      put("/changeset/#{changeset.id}/close")
    end

    def find_changesets_for_user(options = {})
      user_id = find_user.id
      changesets = get("/changesets", :query => options.merge({:user => user_id}))
      changesets.nil? ? [] : changesets
    end

    # Get an object ('node', 'way', or 'relation') with specified ID from API.
    #
    # call-seq: find_element('node', id) -> Rosemary::Element
    #
    def find_element(type, id)
      raise ArgumentError.new("type needs to be one of 'node', 'way', and 'relation'") unless type =~ /^(node|way|relation|changeset)$/
      raise TypeError.new('id needs to be a positive integer') unless(id.kind_of?(Fixnum) && id > 0)
      response = get("/#{type}/#{id}")
      response.is_a?(Array ) ? response.first : response
    end

    private

    # most GET requests are valid without authentication, so this is the standard
    def get(url, options = {})
      do_request(:get, url, options)
    end

    # all PUT requests need authorization, so this is the stanard
    def put(url, options = {})
      do_authenticated_request(:put, url, options)
    end

    # all POST requests need authorization, so this is the stanard
    def post(url, options = {})
      do_authenticated_request(:post, url, options)
    end

    # all DELETE requests need authorization, so this is the stanard
    def delete(url, options = {})
      do_authenticated_request(:delete, url, options)
    end

    def api_url(url)
      "/api/#{API_VERSION}" + url
    end

    # Do a API request without authentication
    def do_request(method, url, options = {})
      begin
        response = self.class.send(method, api_url(url), options)
        check_response_codes(response)
        response.parsed_response
      rescue Timeout::Error
        raise Unavailable.new('Service Unavailable')
      end
    end

    # Do a API request with authentication, using the given client
    def do_authenticated_request(method, url, options = {})
      begin
        response = case client
                   when BasicAuthClient
                     self.class.send(method, api_url(url), options.merge(:basic_auth => client.credentials))
                   when OauthClient
                     # We have to wrap the result of the access_token request into an HTTParty::Response object
                     # to keep duck typing with HTTParty
                     result = client.send(method, api_url(url), options)
                     content_type = Parser.format_from_mimetype(result.content_type)
                     parsed_response = Parser.call(result.body, content_type)

                     HTTParty::Response.new(nil, result, parsed_response)
                   else
                     raise CredentialsMissing
                   end
        check_response_codes(response)
        response.parsed_response
      rescue Timeout::Error
        raise Unavailable.new('Service Unavailable')
      end
    end

    def find_open_changeset
      find_changesets_for_user(:open => true).first
    end

    def find_or_create_open_changeset(options = {})
      @changeset = (find_open_changeset || create_changeset)
    end

    def check_response_codes(response)
      body = response.body
      case response.code.to_i
      when 200 then return
      when 400 then raise BadRequest.new(body)
      when 401 then raise Unauthorized.new(body)
      when 403 then raise Forbidden.new(body)
      when 404 then raise NotFound.new(body)
      when 405 then raise MethodNotAllowed.new(body)
      when 409 then raise Conflict.new(body)
      when 410 then raise Gone.new(body)
      when 412 then raise Precondition.new(body)
#      when 414 then raise UriTooLarge.new(body)
      when 500 then raise ServerError
      when 503 then raise Unavailable.new('Service Unavailable')
      else raise Error("Unknown response code: #{response.code}")
      end
    end

  end
end