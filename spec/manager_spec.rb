require File.join(File.dirname(__FILE__), "spec_helper")

module Tomcat
  APP = "appname"
  OK = "OK - some message"
  UNAUTHROIZED = "401 - Unauthorized"
  NOT_FOUND = "404 - Not Found"

  describe Manager do
    before(:each) do
      @file = mock
      @resource = mock
      @manager = Tomcat::Manager.new("http://localhost:8080", "user", "password")
    end

    it "should undeploy" do
      expect_new_resource("undeploy").and_return(@resource)
      @resource.should_receive(:get).and_return(OK)
      @manager.undeploy(APP)
    end

    it "should raise if undeploy doesn't work" do
      UNAUTHROIZED.should_receive(:code).and_return(401)
      expect_new_resource("undeploy").and_return(@resource)
      @resource.should_receive(:get).and_return(UNAUTHROIZED)
      lambda{@manager.undeploy(APP)}.should raise_error("http status code: 401, message: 401 - Unauthorized")
    end

    it "should deploy" do
      expect_new_resource("deploy").and_return(@resource)
      @resource.should_receive(:put).with(@file).and_return(OK)
      @manager.deploy(APP, @file)
    end

    it "should raise if deploy doesn't work" do
      UNAUTHROIZED.should_receive(:code).and_return(401)
      expect_new_resource("deploy").and_return(@resource)
      @resource.should_receive(:put).with(@file).and_return(UNAUTHROIZED)
      lambda{@manager.deploy(APP, @file)}.should raise_error("http status code: 401, message: 401 - Unauthorized")
    end

    it "should redeploy" do
      undeploy_resource = mock
      deploy_resource = mock
      expect_new_resource("undeploy").and_return(undeploy_resource)
      undeploy_resource.should_receive(:get).and_return(OK)
      expect_new_resource("deploy").and_return(deploy_resource)
      deploy_resource.should_receive(:put).with(@file).and_return(OK)
      @manager.redeploy(APP, @file)
    end
    
    it "should ignore undeploy errors if redeploying" do
      undeploy_resource = mock
      deploy_resource = mock
      expect_new_resource("undeploy").and_return(undeploy_resource)
      undeploy_resource.should_receive(:get).and_return(NOT_FOUND)
      expect_new_resource("deploy").and_return(deploy_resource)
      deploy_resource.should_receive(:put).with(@file).and_return(OK)
      @manager.redeploy(APP, @file)
    end
    
    it "should allow timeout to be specified" do
      @manager = Tomcat::Manager.new("http://localhost:8080", "user", "password", 120)
      expect_new_resource("undeploy", :timeout => 120).and_return(@resource)
      @resource.should_receive(:get).and_return(OK)
      @manager.undeploy(APP)
    end

    def expect_new_resource(resource, extra_parmas = {})
      RestClient::Resource.should_receive(:new).with("http://localhost:8080/#{resource}?path=/#{APP}", {:user => "user", :password => "password"}.merge(extra_parmas))
    end
  end
end