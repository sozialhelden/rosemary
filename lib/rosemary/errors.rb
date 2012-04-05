module Rosemary
  # Unspecified OSM API error.
  class Error < StandardError
    attr_reader :data

    def initialize(data)
      @data = data
      super
    end
  end

  # This error occurs when Rosemary is instantiated without a client
  class CredentialsMissing < StandardError; end

  # An object was not found in the database.
  class NotFound < Error; end

  # The API returned HTTP 400 (Bad Request).
  class BadRequest < Error; end # 400

  # The API operation wasn't authorized. This happens if you didn't set the user and
  # password for a write operation.
  class Unauthorized < Error; end # 401

  class Forbidden < Error; end # 403

  # The object was not found (HTTP 404). Generally means that the object doesn't exist
  # and never has.
  class NotFound < Error; end # 404

  # If the request is not a HTTP PUT request
  class MethodNotAllowed < Error; end # 405

  # If the changeset in question has already been closed
  class Conflict < Error; end # 409

  # The object was not found (HTTP 410), but it used to exist. This generally means
  # that the object existed at some point, but was deleted.
  class Gone < Error; end # 410

  # When a node is still used by a way
  # When a node is still member of a relation
  # When a way is still member of a relation
  # When a relation is still member of another relation
  class Precondition < Error; end # 412

  # Unspecified API server error.
  class ServerError < Error; end # 500

  class Unavailable < Error; end # 503

  class NotImplemented < Error; end # This method is not implemented yet.

end