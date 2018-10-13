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
      @categories = Category.all.sort_by do |category|
        category.name
      end
      erb :'/folders/new'
    else
      flash[:message] = "You must be logged in to create folders."
      redirect :"/login"
    end
  end

  # POST /folders route #create action
  # create new folder
  post '/folders' do
    #raise params.inspect
    binding.pry
    if logged_in?
      folder = Folder.find_by(name: params[:folder][:name])
      if folder && folder.user == current_user
        # Flash Message when the new folder name already exists for current_user
        flash[:message].name = "You already have a folder with this name, please use another name."
        erb :'/folders/new'
      else
        @folder = Folder.create(params[:folder])
        @folder.user = current_user
        @folder.save
        # Flash Message when a new folder is created
        flash[:message] = "Successfully created folder."
        redirect :"/folders/#{@folder.id}/#{@folder.slug}"
      end
    else
      flash[:message] = "You must be logged in to create a folders."
      redirect :"/login"
    end
  end

  # GET /folders/:id/:slug route #show action
  # displays one folder based on ID and slug in the url
  get '/folders/:id/:slug' do
    #binding.pry
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

  # DELETE /folders/:slug/delete route #delete action
  delete '/folders/:id/:slug/delete' do
    #binding.pry
    if logged_in?
      @folder = Folder.find_by_id(params[:id])
      if @folder && @folder.user == current_user
        @folder.delete
        flash[:message] = "You've successfully deleted your folder #{params[:slug]}!"
        redirect :"/folders"
      else
        flash[:message] = "You must be the folder owner to delete this record."
        redirect :"/folders/#{@folder.id}/#{@folder.slug}"
      end
    else
      flash[:message] = "You must be logged in to delete a folder."
      redirect :"/login"
    end
  end
end
