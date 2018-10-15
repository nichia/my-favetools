class UsersController < ApplicationController

  # GET /users route #index action
  # index page to display all users
  get '/users' do
    #binding.pry
    @users = User.all.sort_by do |user|
      user.name
    end
    erb :'/users/index'
  end #-- get /users --

  # GET /signup route #signup/new action
  # renders a form to create a new user. The form includes fields for username, email and password
  # user registration
  get '/signup' do
    if logged_in?
      redirect :"/folders"
    else
      erb :'/users/new'
    end
  end #-- get /signup --

  # POST /signup route #create action
  # create a new instance of user class with a username, email and password. Fill in the session data
  post '/signup' do
    #raise params.inspect
    if params[:user][:name].empty? || params[:user][:email].empty? || params[:user][:password].empty?
      flash.now[:message] = "Username, email and password can not be left blank."
      erb :'/users/signup'
    elsif User.find_by(name: params[:user][:name])
      flash.now[:message] = "Username already taken, please choose another name."
      erb :'/users/signup'
    elsif User.find_by(email: params[:user][:email])
      flash.now[:message] = "An account already exists with this email, please choose another email."
      erb :'/users/signup'
    else
      @user = User.create(params[:user])

      # set session
      set_session
      redirect :"/tools"
    end
  end #-- post /signup --

  # GET /settings/:slug route - edit action
  # displays users setting base on username slug in the url
  get '/settings/:slug' do
    #binding.pry
    @user = User.find_by_slug(params[:slug])
    if @user
      if @user == current_user
        erb :'/users/edit'
      else
        flash[:message] = "You do not have permission to edit a user account you didn't create."
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
    #binding.pry
    #raise params.inspect

    if params[:user][:name].empty? || params[:user][:email].empty? || params[:user][:password].empty?
      flash.now[:message] = "Username, email and password can not be left blank."
      erb :'/users/edit'
    else
      @user = User.find_by_slug(params[:slug])
      if @user.name != params[:user][:name]
        if User.find_by(name: params[:user][:name])
          flash.now[:message] = "Username already taken, please choose another name."
          erb :'/users/edit'
        end
        @user.name = params[:user][:name]
      end
      if @user.email != params[:user][:email]
        if User.find_by(email: params[:user][:email])
          flash.now[:message] = "An account already exists with this email, please choose another email."
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
  end #-- patch /settings/:slug --
end
