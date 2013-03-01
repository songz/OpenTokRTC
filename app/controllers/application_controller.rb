class ApplicationController < ActionController::Base
  def redirect_https        
   # redirect_to :protocol => "https://" unless request.ssl?
    return true
  end
  before_filter :redirect_https
  protect_from_forgery
end
