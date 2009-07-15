require 'test_helper'

class ManagerTest < Test::Unit::TestCase
  def setup
    @manager = Tomcat::Manager.new("http://localhost:8080", "user", "password")
  end
  
  def test_undeploy
    FakeWeb.register_uri(:get, undeploy_url, :body => "OK - Undeployed application at context path /appname")
    assert_nothing_raised { undeploy }
  end
  
  def test_undeploy_when_not_a_200_status
    FakeWeb.register_uri(:get, undeploy_url, :status => ["401", "Unauthorized"])
    assert_raises_with("Unauthorized") { undeploy }
  end
  
  def test_undeploy_when_non_ok_response
    FakeWeb.register_uri(:get, undeploy_url, :body => "FAIL - some error")
    assert_raises_with("FAIL - some error") { undeploy }
  end
  
  def test_deploy
    FakeWeb.register_uri(:put, deploy_url, :body => "OK - Undeployed application at context path /appname")
    assert_nothing_raised { deploy }
  end
  
  def test_deploy_when_not_a_200_status
    FakeWeb.register_uri(:put, deploy_url, :status => ["401", "Unauthorized"])
    assert_raises_with("Unauthorized") { deploy }
  end
  
  def test_deploy_when_non_ok_response
    FakeWeb.register_uri(:put, deploy_url, :body => "FAIL - some error")
    assert_raises_with("FAIL - some error") { deploy }
  end
  
  private 

  def undeploy_url
    "http://user:password@localhost:8080/undeploy?path=/appname"
  end
  
  def undeploy
    @manager.undeploy('appname')
  end
  
  def deploy_url
    "http://user:password@localhost:8080/deploy?path=/appname"
  end
  
  def deploy
    @manager.deploy('appname', "FakeWeb doesn't allow for put body interrogation right now, so this parameter doesn't matter")    
  end
  
  def assert_raises_with(message)
    begin
      yield
      fail("should have raised")
    rescue Exception => e
      assert_equal(message, e.message)
    end
  end
end