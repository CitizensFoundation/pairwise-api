class ApplicationController < ActionController::Base
  include Clearance::Controller
  include Clearance::Authentication
  skip_forgery_protection
  helper :all
  #protect_from_forgery

  @current_internal_user = nil

  def current_user
    @current_internal_user
  end

  def deny_access(flash_message = nil)
    respond_to do |format|
      format.any(:json, :xml, :csv) do
        authenticate_or_request_with_http_basic('Pairwise API') do |login, password|
          @current_internal_user = current_user = @_current_user = ::User.authenticate(login, password)
          puts @_current_user
          current_user
        end
      end
      format.any { redirect_request(flash_message) }
    end
  end
end
