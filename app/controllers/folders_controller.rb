class FoldersController < ApplicationController

  # GET /folders route #index action
  get "/folders" do
    if logged_in?
      erb :'/folders/index'
    else
      flash[:message] = "You must be logged in to view folders."
      redirect :"/login"
    end
  end

  # GET /folders/new route #new action
  get "/folders/new" do
    if logged_in?
      erb :'/folders/new'
    else
      flash[:message] = "You must be logged in to create folders."
      redirect :"/login"
    end
  end
end
