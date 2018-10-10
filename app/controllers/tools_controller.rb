class ToolsController < ApplicationController

  # renders landing page form for login or signup
  get "/tools" do
    erb :index
  end

end
