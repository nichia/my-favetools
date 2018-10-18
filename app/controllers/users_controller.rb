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
      redirect :"/users/#{current_user.slug}/folders"
    else
      erb :'/users/new'
    end
  end #-- get /signup --

  # POST /signup route #create action
  # create a new instance of user class with a username, email and password. Fill in the session data
  post '/signup' do
    #raise params.inspect
    #binding.pry
    @user = User.new(params[:user])
    if @user.save
      # set session
      set_session
      flash[:message] = "Successfully logged in as #{current_user.name}"
      redirect :"/users/#{current_user.slug}/folders"
    else
      if @user.errors.any?
        flash.now[:message] = @user.errors.full_messages.to_sentence
        flash.now[:message] = "Unsuccessful user signup. See errors: #{@user.errors.full_messages.to_sentence}"
      else
        flash.now[:message] = "There's an error in signing up, please try again"
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
        flash[:message] = "You do not have permission to edit another user's account"
        redirect :"/users"
      end
    else
      flash[:message] = "Username \'#{params[:slug]}\' not found"
      redirect :"/users"
    end
  end #-- get /settings/:slug --

  # PATCH /settings/:slug route #update action
  # modifies an existing user account settings based on username slug in the url
  patch '/settings/:slug' do
    #raise params.inspect
    #binding.pry
    @user = User.find_by_slug(params[:slug])
    if @user and @user.authenticate(params[:current_password])
      #@user.assign_attributes( params[:user] )
      if params[:user][:password].empty?
        @user.update(name: params[:user][:name], email: params[:user][:email])
      else
        @user.update(params[:user])
      end
      if @user.valid?
          # reset current user
          reset_current_user
          flash[:message] = "Successfully updated user account settings"
          redirect :"/settings/#{current_user.slug}"
      else
        flash.now[:message] = "Unsuccessful update. See errors: #{@user.errors.full_messages.to_sentence}"
      end
      erb :'/users/edit'
    else
      flash.now[:message] = "Password incorrect, please try again"
      erb :'/users/edit'
    end
  end #-- patch /settings/:slug --
end
