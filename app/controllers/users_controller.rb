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

  # GET /signup route #signup/new action
  # renders a form to create a new user. The form includes fields for username, email and password
  # user registration
  get '/signup' do
    if logged_in?
      redirect :"/folders"
    else
      erb :'/users/new'
    end
  end

  # POST /signup route #create action
  # create a new instance of user class with a username, email and password. Fill in the session data
  post '/signup' do
    #raise params.inspect
    if params[:user][:name].empty? || params[:user][:email].empty? || params[:user][:password].empty?
      flash.now[:message] = "Username, email and password can not be left blank."
      erb :'/users/signup'
    elsif User.find_by(name: params[:user][:name])
      flash.now[:message] = "Username already taken, please use another name."
      erb :'/users/signup'
    elsif User.find_by(email: params[:user][:email])
      flash.now[:message] = "An account already exists with this email, please use another email."
      erb :'/users/signup'
    else
      @user = User.create(params[:user])

      # set session
      set_session
      redirect :"/folders"
    end
  end

  # GET /settings/:slug route - edit action
  # displays users setting base on username slug in the url
  get '/settings/:slug' do
    #binding.pry
    if logged_in?
      @user = User.find_by_slug(params[:slug])
      if @user
        if @user == current_user
          erb :'/users/edit'
        else
          flash[:message] = "You do not have permission to edit user setting."
          redirect :"/"
        end
      else
        flash[:message] = "Username \'#{params[:slug]}\' not found."
        redirect :"/"
      end
    else
      flash[:message] = "You must be logged in to edit user setting."
      redirect :"/login"
    end
  end

  # PATCH /settings/:slug route #update action
  # modifies an existing user account settings based on username slug in the url
  patch '/settings/:slug' do
    #binding.pry
    #raise params.inspect
    @user = User.find_by_slug(params[:slug])

    if params[:user][:name].empty? || params[:user][:email].empty? || params[:user][:password].empty?
      flash.now[:message] = "Username, email and password can not be left blank."
      erb :'/users/edit'
    else
      if @user.name != params[:user][:name]
        if User.find_by(name: params[:user][:name])
          flash.now[:message] = "Username already taken, please use another name."
          erb :'/users/edit'
        end
        @user.name = params[:user][:name]
      end
      if @user.email != params[:user][:email]
        if User.find_by(email: params[:user][:email])
          flash.now[:message] = "An account already exists with this email, please use another email."
          erb :'/users/edit'
        end
        @user.email = params[:user][:email]
      end
      @user.password = params[:user][:password]
      @user.save

      # reset current user
      reset_current_user
      redirect :"/"
    end
  end
end
