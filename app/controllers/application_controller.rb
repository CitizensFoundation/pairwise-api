class ApplicationController < ActionController::Base
  include Clearance::Controller
  include Clearance::Authentication

  helper :all
  protect_from_forgery
end
