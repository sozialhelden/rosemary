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
  #   @changeset = api.create_changeset('Set the wheelchair tag')
  #   api.save(@node, @changeset)
  class Api
    # Provide basic HTTP client behaviour.
    include HTTParty

    # The OSM API version supported by this gem.
    API_VERSION = "0.6".freeze

    # the default base URI for the API
    base_uri "http://www.openstreetmap.org"
    #base_uri "http://api06.dev.openstreetmap.org/api/#{API_VERSION}"

    # Make sure the request don't run forever
    default_timeout 5

    # Use a custom parser to handle the OSM XML format.
    parser Parser


    # @return [Rosemary::Client] the client to be used to authenticate the user towards the OSM API.
    attr_accessor :client

    # @return [Rosemary::Changeset] the current changeset to be used for all writing acces.
    attr_accessor :changeset

    # Creates an Rosemary::Api object with an optional client
    # @param [Rosemary::Client] client the client to authenticate the user for write access.
    def initialize(client=nil)
      @client = client
    end

    # Get a Node with specified ID from API.
    #
    # @param [Fixnum] id the id of the node to find.
    # @return [Rosemary::Node] the node with the given id.
    # @raise [Rosemary::Gone] in case the node has been deleted.
    def find_node(id)
      find_element('node', id)
    end

    # Get a Way with specified ID from API.
    #
    # @param [Fixnum] id the id of the node to find.
    # @return [Rosemary::Way] the way with the given id.
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

    # Get a Changeset with specified ID from API
    # if that changeset is missing, id is nil, or the changeset is closed
    # create a new one
    #
    # call-seq: find_or_create_open_changeset(id, comment) -> Rosemary::Changeset
    #
    def find_or_create_open_changeset(id, comment = nil, tags = {})
      find_open_changeset(id) || create_changeset(comment, tags)
    end

    def find_open_changeset(id)
      cs = find_changeset(id)
      (cs && cs.open?) ? cs : nil
    end

    # Get the user which represented by the Rosemary::Client
    #
    # @return: [Rosemary::User] user the user authenticated using the current client
    #
    def find_user
      raise CredentialsMissing if client.nil?
      resp = do_authenticated_request(:get, "/user/details")
      raise resp if resp.is_a? String
      resp
    end

    # Get the bounding box which is represented by the Rosemary::BoundingBox
    #
    # @param [Numeric] left is the longitude of the left (westernmost) side of the bounding box.
    # @param [Numeric] bottom is the latitude of the bottom (southernmost) side of the bounding box.
    # @param [Numeric] right is the longitude of the right (easternmost) side of the bounding box.
    # @param [Numeric] top is the latitude of the top (northernmost) side of the bounding box.
    # @return [Rosemary::BoundingBox] the bounding box containing all ways, nodes and relations inside the given coordinates
    #
    def find_bounding_box(left,bottom,right,top)
      do_request(:get, "/map?bbox=#{left},#{bottom},#{right},#{top}", {} )
    end


    def permissions
      if client.nil?
        get("/permissions")
      else
        do_authenticated_request(:get, "/permissions")
      end
    end

    # Deletes the given element using API write access.
    #
    # @param [Rosemary::Element] element the element to be created
    # @param [Rosemary::Changeset] changeset the changeset to be used to wrap the write access.
    # @return [Fixnum] the new version of the deleted element.
    def destroy(element, changeset)
      element.changeset = changeset.id
      response = delete("/#{element.type.downcase}/#{element.id}", :body => element.to_xml) unless element.id.nil?
      response.to_i # New version number
    end

    # Creates or updates an element depending on the current state of persistance.
    #
    # @param [Rosemary::Element] element the element to be created
    # @param [Rosemary::Changeset] changeset the changeset to be used to wrap the write access.
    def save(element, changeset)
      response = if element.id.nil?
        create(element, changeset)
      else
        update(element, changeset)
      end
    end

    # Create a new element using API write access.
    #
    # @param [Rosemary::Element] element the element to be created
    # @param [Rosemary::Changeset] changeset the changeset to be used to wrap the write access.
    # @return [Fixnum] the id of the newly created element.
    def create(element, changeset)
      element.changeset = changeset.id
      put("/#{element.type.downcase}/create", :body => element.to_xml)
    end

    # Update an existing element using API write access.
    #
    # @param [Rosemary::Element] element the element to be created
    # @param [Rosemary::Changeset] changeset the changeset to be used to wrap the write access.
    # @return [Fixnum] the versiom of the updated element.
    def update(element, changeset)
      element.changeset = changeset.id
      response = put("/#{element.type.downcase}/#{element.id}", :body => element.to_xml)
      response.to_i # New Version number
    end

    # Create a new changeset with an optional comment
    #
    # @param [String] comment a meaningful comment for this changeset
    # @return [Rosemary::Changeset] the changeset which was newly created
    # @raise [Rosemary::NotFound] in case the changeset could not be found
    def create_changeset(comment = nil, tags = {})
      tags.merge!(:comment => comment) { |key, v1, v2| v1 }
      changeset = Changeset.new(:tags => tags)
      changeset_id = put("/changeset/create", :body => changeset.to_xml).to_i
      find_changeset(changeset_id) unless changeset_id == 0
    end

    # Get a Changeset with specified ID from API.
    #
    # @param [Integer] id the ID for the changeset you look for
    # @return [Rosemary::Changeset] the changeset which was found with the id
    def find_changeset(id)
      find_element('changeset', id)
    end

    # Closes the given changeset.
    #
    # @param [Rosemary::Changeset] changeset the changeset to be closed
    def close_changeset(changeset)
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
      return nil if id.nil?
      begin
        response = get("/#{type}/#{id}")
        response.is_a?(Array ) ? response.first : response
      rescue NotFound
        nil
      end
    end

    # Create a note
    #
    # call-seq: create_note(lat: 51.00, lon: 0.1, text: 'Test note') -> Rosemary::Note
    #
    def create_note(note)
      post("/notes", :query => note)
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

                     HTTParty::Response.new(nil, result, lambda { parsed_response })
                   else
                     raise CredentialsMissing
                   end
        check_response_codes(response)
        response.parsed_response
      rescue Timeout::Error
        raise Unavailable.new('Service Unavailable')
      end
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
      when 500 then raise ServerError, 'Internal Server Error'
      when 503 then raise Unavailable, 'Service Unavailable'
      else raise "Unknown response code: #{response.code}"
      end
    end

  end
end
