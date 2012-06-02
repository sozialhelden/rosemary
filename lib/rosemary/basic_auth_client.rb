class Rosemary::BasicAuthClient < Rosemary::Client

  # The username to be used to authenticate the user against the OMS API
  attr_reader :username

  # The password to be used to authenticate the user against the OMS API
  attr_reader :password

  def initialize(username, password)
    @username = username
    @password = password
  end

  # The username and password credentials as a Hash
  # @return [Hash] the credential hash.
  def credentials
    {:username => username, :password => password}
  end

  # Override inspect message to keep the password from showing up
  # in any logfile.
  def inspect
    "#<#{self.class.name}:#{self.object_id} @username='#{username}'>"
  end
end
