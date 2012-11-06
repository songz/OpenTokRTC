class ApplicationController < ActionController::Base
  protect_from_forgery

  def printa a
    p "=============="
    p "=============="
    p "=============="
    p "=============="
    p a
    p "=============="
    p "=============="
    p "=============="
    p "=============="
  end
end
