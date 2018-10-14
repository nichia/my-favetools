class UsersController < ApplicationController

  # GET /users route #index action
  # index page to display all users
  get '/users' do
    #binding.pry
    if logged_in?
      @users = User.all.sort_by do |user|
        user.name
      end
      erb :'/users/index'
    else
      flash[:message] = "You must be logged in to view user listing."
      redirect :"/login"
    end
  end

  # GET /users/:slug route #index action
  # index page to display all folders that belongs to this user
  get '/users/:slug' do
    #binding.pry
    if logged_in?
      @user = User.find_by_slug(params[:slug])
      if @user
        if @user == current_user
          @folders = Folder.where(user_id: @user.id).order('id DESC')
        else
          @folders = Folder.where(user_id: @user.id, privacy: false).order('id DESC')
        end
        # erb :'/items/index'
        erb :'/folders/index'
      else
        flash[:message] = "Username \'#{params[:slug]}\' not found."
        redirect :"/"
      end
    else
      flash[:message] = "You must be logged in to view user's info."
      redirect :"/login"
    end
  end
  
  # GET /users/:slug/:folder_slug route - index action
  # index page to display all items base on username and folder slugs in the url
  get '/users/:slug/:folder_slug' do
    #binding.pry
    if logged_in?
      user = User.find_by_slug(params[:slug])
      if user
        if user == current_user
          #find folder_slug that belongs to user.id
          folder = Folder.find_by_slug_user(params[:folder_slug], user.id)
          if folder
            @items = Item.where(folder_id: folder.id)
            if @items
              erb :'/items/index'
            end
          else
            flash[:message] = "Folder \'#{params[:folder_slug]}\' for username \'#{params[:slug]}\' not found."
            #redirect to user requesting route
            redirect :"/users/#{params[:slug]}"
          end
        else
          #find folder_slug that belongs to user.id
          folder = Folder.find_by_slug_user(params[:folder_slug], user.id)
          if folder &&  !folder.privacy
            #display items for public folder only
            @items = Item.where(folder_id: folder.id)
            if @items
              erb :'/items/index'
            end
          else
            flash[:message] = "Public folder \'#{params[:folder_slug]}\' for username \'#{params[:slug]}\' not found."
            #redirect to user requesting route
            redirect :"/users/#{params[:slug]}"
          end
        end
      else
        flash[:message] = "Username \'#{params[:slug]}\' not found."
        redirect :"/"
      end
    else
      flash[:message] = "You must be logged in to view this users items."
      redirect :"/login"
    end
  end
end
