class FoldersController < ApplicationController

  # GET /folders route #index action
  # index page to display all public folders
  get "/folders" do
    if logged_in?
      #find non-private folders
      @folders = Folder.where(privacy: false)
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

  # GET /folders/:id/:slug route # Show action
  # displays one folder based on ID and slug in the url
  get '/folders/:id/:slug' do
    binding.pry
    if logged_in?
      @folder = Folder.find_by_id(params[:id])
      if @folder && @folder.slug == params[:slug]
        erb :'/folders/show'
      else
        flash.now[:message] = "Folder's id and name combination not found, please try again."
        redirect :"/folders"
      end
    else
      flash[:message] = "You must be logged in to view the Folder information."
      redirect :"/login"
    end
  end

end
