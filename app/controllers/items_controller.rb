class ItemsController < ApplicationController

  # GET /items route #index action
  # index page to display all public items
  get "/items" do
    if logged_in?
      #find non-private items that does not belong to current user, order by latest items
      @items = Item.find_by_privacy_not_user(false, session[:user_id])

      erb :'/items/index'
    else
      flash[:message] = "You must be logged in to view the items."
      redirect :"/login"
    end
  end

  # GET /items/new route #new action
  get "/items/new" do
    if logged_in?
      @folders = Folder.where(user: current_user).sort_by do |folder|
        folder.name
      end
      erb :'/items/new'
    else
      flash[:message] = "You must be logged in to create items."
      redirect :"/login"
    end
  end

  # GET /items/new/:id route #new action
  # new action to copy an item - displays create item form base on existing item
  get "/items/new/:id" do
    if logged_in?
      @item = Item.find_by_id(params[:id])
      if @item
        @folders = Folder.where(user: current_user).sort_by do |folder|
          folder.name
        end
        erb :'/items/copy'
      else
        erb :'not_found'
      end
    else
      flash[:message] = "You must be logged in to create items."
      redirect :"/login"
    end
  end

  # POST /items route #create action
  # create new item
  post '/items' do
    #raise params.inspect
    #binding.pry
    if logged_in?
      if params[:item][:name].empty?
        flash[:message] = "Item name cannot be left blank."
        redirect :"/items/new"
      else
        item = Item.find_by(name: params[:item][:name])
        if item && (item.folder_id == params[:item][:folder_id] && params[:folder][:name].empty?)
          # Flash Message when the new item name already exists for this folder
          flash[:message] = "You already have an item \'#{params[:item][:name]}\' with this folder, please use another name."
          redirect :"/items/new"
        else
          # new folder
          if !params[:folder][:name].empty?
            folder = Folder.find_by(name: params[:folder][:name])
            if folder && folder.user == current_user
              flash[:message] = "Folder \'#{params[:folder][:name]}\' already exists, please select from dropdown menu."
              redirect :"/items/new"
            else
              folder = Folder.create(name: params[:folder][:name], user_id: current_user.id)
              params[:item][:folder_id] = folder.id
            end
          end

          @item = Item.create(params[:item])
          # Flash Message when a new item is created
          flash[:message] = "Successfully created an item."
          redirect :"/items/#{@item.id}/#{@item.slug}"
        end
      end
    else
      flash[:message] = "You must be logged in to create items."
      redirect :"/login"
    end
  end

  # GET /items/:id/:slug route # Show action
  # displays one item based on ID and slug in the url
  get '/items/:id/:slug' do
    #binding.pry
    if logged_in?
      @item = Item.find_by_id(params[:id])
      if @item && @item.slug == params[:slug]
        erb :'/items/show'
      else
        flash.now[:message] = "Item's id and name combination not found, please try again."
        redirect :"/items"
      end
    else
      flash[:message] = "You must be logged in to view the items."
      redirect :"/login"
    end
  end

  # GET /items/:id/:slug/edit route #edit action
  # displays one item based on ID and slug in the url for editing
  get '/items/:id/:slug/edit' do
    if logged_in?
      @item = Item.find_by_id(params[:id])
      if @item && @item.slug == params[:slug]
        if @item.folder.user == current_user
          @folders = Folder.where(user: current_user).sort_by do |folder|
            folder.name
          end
          erb :'/items/edit'
        else
          flash[:message] = "You must be the item owner to edit this record."
          redirect :"/items/#{@item.id}/#{@item.slug}"
        end
      else
        flash.now[:message] = "Item's id and name combination not found, please try again."
        redirect :"/items"
      end
    else
      flash[:message] = "You must be logged in to edit items."
      redirect :"/login"
    end
  end

  # PATCH /items/:id/:slug route #update action
  # modifies an existing item based on ID and slug in the url
  patch '/items/:id/:slug' do
    #binding.pry
    if logged_in?
      if params[:item][:name].empty?
        flash[:message] = "Item name cannot be left blank."
        redirect :"/items/#{@item.id}/#{@item.slug}/edit"
      else
        @item = Item.find_by_id(params[:id])
        if @item && @item.folder.user == current_user
          @item.update(params[:item])
          # new folder
          if !params[:folder][:name].empty?
            folder = Folder.find_by(name: params[:folder][:name])
            if folder && folder.user == current_user
              flash[:message] = "Folder \'#{params[:folder][:name]}\' already exists, please select from dropdown menu."
              redirect :"/items/#{@item.id}/#{@item.slug}/edit"
            else
              @item.folder = Folder.create(name: params[:folder][:name], user_id: current_user.id)
              @item.save
            end
          end
          flash[:message] = "You've successfully updated the item \'#{params[:slug]}\'."
          redirect :"/items/#{@item.id}/#{@item.slug}"
        else
          flash[:message] = "You must be the item owner to update this record."
          redirect :"/items/#{@item.id}/#{@item.slug}"
        end
      end
    else
      flash[:message] = "You must be logged in to update an item."
      redirect :"/login"
    end
  end

  # DELETE /items/:id/:slug route #delete action
  delete '/items/:id/:slug' do
    #binding.pry
    if logged_in?
      @item = Item.find_by_id(params[:id])
      if @item && @item.folder.user == current_user
        @item.delete
        flash[:message] = "You've successfully deleted your item #{params[:slug]}."
        redirect :"/users/#{current_user.slug}"
      else
        flash[:message] = "You must be the item owner to delete this record."
        redirect :"/items/#{@item.id}/#{@item.slug}"
      end
    else
      flash[:message] = "You must be logged in to delete an item."
      redirect :"/login"
    end
  end
end
