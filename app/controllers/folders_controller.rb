class FoldersController < ApplicationController

  # GET /folders route #index action
  # index page to display all public folders
  get '/folders' do
    #find non-private folders
    @folders = Folder.where(privacy: false)
    erb :'/folders/index'
  end #-- get /folders --

  # GET /folders/users/:slug route #index action
  # index page to display all folders that belongs to this user
  get '/folders/users/:user_slug' do
    if @user = User.find_by_slug(params[:user_slug])
      if @user == current_user
        @folders = Folder.where(user_id: @user.id).order('id DESC')
      else
        @folders = Folder.where(user_id: @user.id, privacy: false).order('id DESC')
      end
      erb :'/folders/index'
    else
      flash[:message] = "Username \'#{params[:user_slug]}\' not found"
      redirect :"/users"
    end
  end #-- get /folders/users/:slug --

  # GET /folders/new route #new action
  get '/folders/new' do
    @categories = Category.all.sort_by do |category|
      category.name
    end
    erb :'/folders/new'
  end #-- get /folders/new --

  # POST /folders route #create action
  # create new folder
  post '/folders' do
    #raise params.inspect
    #binding.pry
    if Folder.find_by(name: params[:folder][:name], user_id: current_user.id)
      # Flash Message when the new folder name already exists for current_user
      flash[:message] = "You already have a folder with this name \'#{params[:folder][:name]}\', please choose another name"
      redirect :"/folders/new"
    else
      @folder = current_user.folders.build(params[:folder])
      # Flash Message when a new folder is created
      if @folder.save
        flash[:message] = "Successfully created a new folder"
        redirect :"/folders/#{@folder.id}/#{@folder.slug}"
      else
        flash[:message] = "Errors creating folder"
        redirect :"/folders/new"
      end
    end
  end #-- post /folders --

  # GET /folders/:id/:slug route #show action
  # displays one folder based on ID and slug in the url
  get '/folders/:id/:slug' do
    @folder = Folder.find_by_id(params[:id])
    if @folder && @folder.slug == params[:slug]
      erb :'/folders/show'
    else
      flash[:message] = "Folder's id and name combination not found, please try again"
      redirect :"/folders"
    end
  end #-- get /folders/:id/:slug --

  # GET /folders/:id/:slug/edit route #edit action
  # displays one folder based on ID and slug in the url for editing
  get '/folders/:id/:slug/edit' do
    @folder = Folder.find_by_id(params[:id])
    if @folder && @folder.slug == params[:slug]
      if @folder.user == current_user
        @categories = Category.all.sort_by do |category|
          category.name
        end
        erb :'/folders/edit'
      else
        flash[:message] = "You don't have permission to edit a folder you didn't create"
        redirect :"/folders/#{@folder.id}/#{@folder.slug}"
      end
    else
      flash[:message] = "Folder's id and name combination not found, please try again"
      redirect :"/folders"
    end
  end #-- get /folders/:id/:slug/edit --

  # PATCH /folders/:id/:slug route #update action
  # modifies an existing folder based on ID and slug in the url
  patch '/folders/:id/:slug' do
    #binding.pry
    if params[:folder][:name].empty?
      flash[:message] = "Folder name cannot be left blank"
      redirect :"/folders/#{@folder.id}/#{@folder.slug}/edit"
    else
      @folder = Folder.find_by_id(params[:id])
      if @folder && @folder.user == current_user
        if @folder.name != params[:folder][:name]
          # Flash Message if the new folder name already exists for this user
          if Folder.find_by(name: params[:folder][:name], user_id: @folder.user_id)
            flash[:message] = "You already have a folder with this name \'#{params[:folder][:name]}\', please choose another name."
            redirect :"/folders/#{@folder.id}/#{@folder.slug}/edit"
          end
        end
        if @folder.update(params[:folder])
          flash[:message] = "You've successfully updated the folder"
        else
          flash[:message] = "Errors updating folder"
        end
        redirect :"/folders/#{@folder.id}/#{@folder.slug}"
      else
        flash[:message] = "You don't have permission to update a folder you didn't create"
        redirect :"/folders/#{@folder.id}/#{@folder.slug}"
      end
    end
  end #-- patch /folders/:id/:slug --

  # DELETE /folders/:slug route #delete action
  delete '/folders/:id/:slug' do
    @folder = Folder.find_by_id(params[:id])
    if @folder && @folder.user == current_user
      if @folder.destroy
        flash[:message] = "You've successfully deleted your folder \'#{params[:slug]}\'"
        redirect :"/folders/users/#{@current_user.slug}"
      else
        flash[:message] = "Errors deleleting folder"
        redirect :"/folders/#{@folder.id}/#{@folder.slug}"
      end
    else
      flash[:message] = "You don't have permission to delete a folder you didn't create"
      redirect :"/folders/#{@folder.id}/#{@folder.slug}"
    end
  end #-- delete /folders/:id/:slug --
end
