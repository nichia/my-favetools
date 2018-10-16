class UsersController < ApplicationController

  # GET /users route #index action
  # index page to display all users
  get '/users' do
    @users = User.all.sort_by do |user|
      user.name
    end
    erb :'/users/index'
  end #-- get /users --

  # GET /signup route #signup/new action
  # user registration to create a new user
  get '/signup' do
    if logged_in?
      redirect :"/folders/users/#{current_user.slug}"
    else
      erb :'/users/new'
    end
  end #-- get /signup --

  # POST /signup route #create action
  # create a new instance of user class with a username, email and password. Fill in the session data
  post '/signup' do
    #raise params.inspect
    @user = User.new(params[:user])
    if @user.valid?
      @user.save
      # set session
      set_session
      redirect :"/folders/users/#{current_user.slug}"
    else
      if @user.errors.any?
        flash.now[:user_message] = @user.errors.full_messages
      else
        flash.now[:user_message] = ["There's an error in signing up, please try again."]
      end
      erb :'/users/new'
    end
  end #-- post /signup --

  # GET /settings/:slug route - edit action
  # displays users setting base on username slug in the url
  get '/settings/:slug' do
    @user = User.find_by_slug(params[:slug])
    if @user
      if @user == current_user
        erb :'/users/edit'
      else
        flash[:message] = "You do not have permission to edit another user's account."
        redirect :"/users"
      end
    else
      flash[:message] = "Username \'#{params[:slug]}\' not found."
      redirect :"/users"
    end
  end #-- get /settings/:slug --

  # PATCH /settings/:slug route #update action
  # modifies an existing user account settings based on username slug in the url
  patch '/settings/:slug' do
    # binding.pry
    #raise params.inspect
    @user = User.find_by_slug(params[:slug])
    if @user and @user.authenticate(params[:password])
      @user.assign_attributes( params[:users] )
      if @user.valid? && @user.update(params[:users])
          # reset current user
          reset_current_user
          redirect :"/folders/users/#{current_user.slug}"
      end

      if @user.errors.any?
        flash.now[:user_message] = @user.errors.full_messages
      else
        flash.now[:user_message] = ["There's an error in updating user account settings, please try again."]
      end
      erb :'/users/edit'
    else
      flash.now[:user_message] = ["Password incorrect, please try again."]
      erb :'/users/edit'
    end
  end #-- patch /settings/:slug --
end
