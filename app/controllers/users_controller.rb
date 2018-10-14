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
  # index page to display all tools that belongs to this user
  get '/users/:slug' do
    #binding.pry
    if logged_in?
      @user = User.find_by_slug(params[:slug])
      if @user
        if @user == current_user
          #find non-private tools that does not belong to current user, order by latest tools
          # @tools = Tool.find_by_user(@user.id)
          @folders = Folder.where(user_id: @user.id).order('id DESC')
        else
          #find non-private tools that belong to username, order by latest tools
          # @tools = Tool.find_by_user_privacy(@user.id, false)
          @folders = Folder.where(user_id: @user.id, privacy: false).order('id DESC')
        end
        # erb :'/tools/index'
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

  # GET /users/:slug/edit route - edit action
  # displays users setting base on username slug in the url
  get '/users/:slug/edit' do
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

  # PATCH /users/:slug route #update action
  # modifies an existing user account settings based on username slug in the url
  patch '/users/:slug' do
    #binding.pry
    #raise params.inspect
    @user = User.find_by_slug(params[:slug])

    if params[:user][:name].empty? || params[:user][:email].empty? || params[:user][:password].empty?
      flash.now[:message] = "Username, email and password can not be left blank."
      erb :'/users/#{params[:slug]}/edit'
    else
      if @user.name != params[:user][:name]
        if User.find_by(name: params[:user][:name])
          flash.now[:message] = "Username already taken, please use another name."
          erb :'/users/#{params[:slug]}/edit'
        end
        @user.name = params[:user][:name]
      end
      if @user.email != params[:user][:email]
        if User.find_by(email: params[:user][:email])
          flash.now[:message] = "An account already exists with this email, please use another email."
          erb :'/users/#{params[:slug]}/edit'
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

  # GET /users/:slug/:folder_slug route - index action
  # index page to display all tools base on username and folder slugs in the url
  get '/users/:slug/:folder_slug' do
    #binding.pry
    if logged_in?
      user = User.find_by_slug(params[:slug])
      if user
        if user == current_user
          #find folder_slug that belongs to user.id
          folder = Folder.find_by_slug_user(params[:folder_slug], @user.id)
          if folder
            @tools = Tool.where(folder_id: folder.id)
            if @tools
              erb :'/tools/index'
            end
          else
            flash[:message] = "Folder \'#{params[:folder_slug]}\' for username \'#{params[:slug]}\' not found."
            #redirect to requesting route
            redirect :"#{request.path_info}"
          end
        else
          #find folder_slug that belongs to user.id
          folder = Folder.find_by_slug_user(params[:folder_slug], user.id)
          if folder &&  !folder.privacy
            #display tools for public folder only
            @tools = Tool.where(folder_id: folder.id)
            if @tools
              erb :'/tools/index'
            end
          else
            flash[:message] = "Public folder \'#{params[:folder_slug]}\' for username \'#{params[:slug]}\' not found."
            #redirect to requesting route
            redirect :"#{request.path_info}"
          end
        end
      else
        flash[:message] = "Username \'#{params[:slug]}\' not found."
        redirect :"/"
      end
    else
      flash[:message] = "You must be logged in to view this users tools."
      redirect :"/login"
    end
  end
end
