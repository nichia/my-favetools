class ItemsController < ApplicationController

  # GET /items route #index action
  # index page to display all public items
  get '/items' do
    # find non-private items that does not belong to the current user
    # and find items for the current user
    @items = (Item.find_by_privacy_and_not_user(false, session[:user_id]) + Item.find_by_user(session[:user_id]))
    erb :'/items/index'
  end #-- get /items --

  # GET /items/user/:user_slug route #index action
  # index page to display all items that belongs to current_user or
  # all public items that belongs to a user
  get '/items/users/:user_slug' do
    if user = User.find_by_slug(params[:user_slug])
      if user == current_user
        #find items that belong to current user, order by latest items
        @items = Item.find_by_user(user.id)
      elsif
        #find non-private items that does not belong to current user, order by latest items
        @items = Item.find_by_user_privacy(user.id, false)
      end
      erb :'/items/index'
    else
      flash[:message] = "Username \'#{params[:user_slug]}\' not found"
      redirect :"/users"
    end
  end #-- get /items/user/ --

  # GET /items/users/:user_slug/:folder_slug route - index action
  # index page to display all items base on username and folder slugs in the url
  get '/items/users/:user_slug/:folder_slug' do
    if user = User.find_by_slug(params[:user_slug])
      #find folder_slug that belongs to user.id
      folder = Folder.find_by_slug_user(params[:folder_slug], user.id)
      if folder
        if user == current_user || !folder.privacy
          # if current_user or folders that are public
          @items = Item.where(folder_id: folder.id)
        else
          @items = []
        end
        erb :'/items/index'
      else
        flash[:message] = "Folder \'#{params[:folder_slug]}\' for username \'#{params[:user_slug]}\' not found"
        #redirect to user requesting route
        redirect :"/folders/users/#{params[:user_slug]}"
      end
    else
      flash[:message] = "Username \'#{params[:user_slug]}\' not found"
      redirect :"/users"
    end
  end #-- get /items/users/:user_slug/:folder_slug --

  # GET /items/new route #new action
  get '/items/new' do
    @folders = Folder.where(user: current_user).sort_by do |folder|
      folder.name
    end
    erb :'/items/new'
  end #-- get /items/new --

  # GET /items/new/:id route #new action
  # new action to copy an item - displays create item form base on existing item
  get '/items/new/:id' do
    if @item = Item.find_by_id(params[:id])
      @folders = Folder.where(user: current_user).sort_by do |folder|
        folder.name
      end
      erb :'/items/copy'
    else
      erb :'not_found'
    end
  end #-- get /items/new/:id --

  # POST /items route #create action
  # create new item
  post '/items' do
    #raise params.inspect
    #binding.pry
    if params[:item][:name].empty?
      flash[:message] = "Item name cannot be left blank"
      redirect :"/items/new"
    else
      # Flash Message if the new item name already exists for this folder
      if params[:folder][:name].empty? &&
         Item.find_by(name: params[:item][:name], folder_id: params[:item][:folder_id])
        flash[:message] = "You already have an item \'#{params[:item][:name]}\' with this folder, please choose another name"
        redirect :"/items/new"
      else
        # new folder
        if !params[:folder][:name].empty?
          if Folder.find_by(name: params[:folder][:name], user_id: current_user.id)
            flash[:message] = "Folder \'#{params[:folder][:name]}\' already exists, please select from dropdown menu"
            redirect :"/items/new"
          else
            folder = Folder.create(name: params[:folder][:name], user_id: current_user.id, category_id: 1)
            params[:item][:folder_id] = folder.id
          end
        end

        if @item = Item.create(params[:item])
          # Flash Message when a new item is created
          flash[:message] = "Successfully created an item"
          redirect :"/items/#{@item.id}/#{@item.slug}"
        else
          flash[:message] = "Errors creating item"
          redirect :"/items/new"
        end
      end
    end
  end #-- post /items --

  # GET /items/:id/:slug route # Show action
  # displays one item based on ID and slug in the url
  get '/items/:id/:slug' do
    @item = Item.find_by_id(params[:id])
    if @item && @item.slug == params[:slug]
      erb :'/items/show'
    else
      flash.now[:message] = "Item's id and name combination not found, please try again"
      redirect :"/items"
    end
  end #-- get /items/:id/:slug --

  # GET /items/:id/:slug/edit route #edit action
  # displays one item based on ID and slug in the url for editing
  get '/items/:id/:slug/edit' do
    @item = Item.find_by_id(params[:id])
    if @item && @item.slug == params[:slug]
      if @item.folder.user == current_user
        @folders = Folder.where(user: current_user).sort_by do |folder|
          folder.name
        end
        erb :'/items/edit'
      else
        flash[:message] = "You don't have permission to edit an item you didn't create"
        redirect :"/items/#{@item.id}/#{@item.slug}"
      end
    else
      flash.now[:message] = "Item's id and name combination not found, please try again"
      redirect :"/items"
    end
  end #-- get /items/:id/:slug/edit --

  # PATCH /items/:id/:slug route #update action
  # modifies an existing item based on ID and slug in the url
  patch '/items/:id/:slug' do
    #binding.pry
    if params[:item][:name].empty?
      flash[:message] = "Item name cannot be left blank."
      redirect :"/items/#{@item.id}/#{@item.slug}/edit"
    else
      @item = Item.find_by_id(params[:id])
      if @item && @item.folder.user == current_user
        if params[:folder][:name].empty?
          if (@item.name != params[:item][:name]) || (@item.folder_id != params[:item][:folder_id].to_i)
            # Flash Message if the new item name already exists for this folder
            if Item.find_by(name: params[:item][:name], folder_id: params[:item][:folder_id])
              flash[:message] = "You already have an item \'#{params[:item][:name]}\' with this folder, please choose another name"
              redirect :"/items/#{@item.id}/#{@item.slug}/edit"
            end
          end
          @item.update(params[:item])
        else
          # new folder
          if Folder.find_by(name: params[:folder][:name], user_id: current_user.id)
            flash[:message] = "Folder \'#{params[:folder][:name]}\' already exists, please select from dropdown menu"
            redirect :"/items/#{@item.id}/#{@item.slug}/edit"
          else
            @item.update(params[:item])
            @item.folder = Folder.create(name: params[:folder][:name], user_id: current_user.id, category_id: 1)
            @item.save
          end
        end
        if @item.valid?
          flash[:message] = "You've successfully updated the item \'#{@item.name}\'"
        end
        redirect :"/items/#{@item.id}/#{@item.slug}"
      else
        flash[:message] = "You don't have permission to update an item you didn't create"
        redirect :"/items/#{@item.id}/#{@item.slug}"
      end
    end
  end #-- patch /items/:id/:slug --

  # DELETE /items/:id/:slug route #delete action
  delete '/items/:id/:slug' do
    #binding.pry
    @item = Item.find_by_id(params[:id])
    if @item && @item.folder.user == current_user
      if @item.destroy
        flash[:message] = "You've successfully deleted your item #{params[:slug]}"
        redirect :"/folders/users/#{current_user.slug}"
      else
        flash[:message] = "Errors deleting item #{params[:slug]}"
        redirect :"/items/#{@item.id}/#{@item.slug}"
      end
    else
      flash[:message] = "You don't have permission to delete an item you didn't create"
      redirect :"/items/#{@item.id}/#{@item.slug}"
    end
  end #-- delete /items/:id/:slug --
end
