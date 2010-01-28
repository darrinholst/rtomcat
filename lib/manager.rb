require 'rest_client'

class Tomcat::Manager
  def initialize(url, username, password, timeout = nil)
    @url = url
    @username = username
    @password = password
    @timeout = timeout
  end

  def undeploy(appname)
    check_response(resource('undeploy', appname).get)
  end

  def deploy(appname, file)
    check_response(resource('deploy', appname).put(file))
  end

  def redeploy(appname, file)
    begin
      undeploy(appname)
    rescue
    end

    deploy(appname, file)
  end

  private

  def check_response(response)
    match = response.match(/(.*) - .*/)
    raise("http status code: #{response.code}, message: #{response}") unless match && match[1].eql?("OK")
    response
  end

  def resource(function, appname)
    options = {:user => @username, :password => @password}
    options[:timeout] = @timeout if @timeout
    RestClient::Resource.new("#{@url}/#{function}?path=/#{appname}", options)
  end
end