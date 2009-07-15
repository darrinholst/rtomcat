require 'rest_client'

class Tomcat::Manager
  def initialize(url, username, password)
    @url = url
    @username = username
    @password = password
  end
  
  def undeploy(appname)
    resp = resource('undeploy', appname).get
    match = resp.match(/(.*) - .*/)    
    raise(resp) unless match && match[1].eql?("OK")
  end
  
  def deploy(appname, file)
    resp = resource('deploy', appname).put file
    match = resp.match(/(.*) - .*/)    
    raise(resp) unless match && match[1].eql?("OK")
  end
  
  private
  
  def resource(function, appname)
    RestClient::Resource.new("#{@url}/#{function}?path=/#{appname}", :user => @username, :password => @password)
  end
end