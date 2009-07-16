require 'rest_client'

class Tomcat::Manager
  def initialize(url, username, password)
    @url = url
    @username = username
    @password = password
  end
  
  def undeploy(appname)
    check_response(resource('undeploy', appname).get)
  end
  
  def deploy(appname, file)
    check_response(resource('deploy', appname).put(file))
  end
  
  private
  
  def check_response(response)
    match = response.match(/(.*) - .*/)    
    raise("http status code: #{response.code}, message: #{response}") unless match && match[1].eql?("OK")
    response
  end

  def resource(function, appname)
    RestClient::Resource.new("#{@url}/#{function}?path=/#{appname}", :user => @username, :password => @password)
  end
end