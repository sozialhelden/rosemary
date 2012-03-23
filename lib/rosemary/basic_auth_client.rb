module Rosemary
  class BasicAuthClient

    attr_reader :username, :password

    def initialize(username, password)
      @username = username
      @password = password
    end

    def credentials
      {:username => username, :password => password}
    end
  end
end