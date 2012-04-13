class Rosemary::BasicAuthClient
  attr_reader :username, :password

  def initialize(username, password)
    @username = username
    @password = password
  end

  def credentials
    {:username => username, :password => password}
  end

  def inspect
    "#<#{self.class.name}:#{self.object_id} @username='#{username}'>"
  end
end
