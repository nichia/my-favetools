class ToolsController < ApplicationController

  # GET /tools route #index action
  # index page to display all public tools
  get "/tools" do
    if logged_in?
      #find non-private tools that does not belong to current user, order by latest tools
      @tools = Tool.find_by_privacy_not_user(false, session[:user_id])

      erb :'/tools/index'
    else
      flash[:message] = "You must be logged in to view the tools."
      redirect :"/login"
    end
  end

  # GET /tools/new route #new action
  get "/tools/new" do
    if logged_in?
      @folders = Folder.where(user: current_user).sort_by do |folder|
        folder.name
      end
      erb :'/tools/new'
    else
      flash[:message] = "You must be logged in to create tools."
      redirect :"/login"
    end
  end

  # POST /tools route #create action
  # create new tool
  post '/tools' do
    #raise params.inspect
    #binding.pry
    if logged_in?
      if params[:tool][:name].empty?
        flash[:message] = "Tool name cannot be left blank."
        redirect :"/tools/new"
      else
        tool = Tool.find_by(name: params[:tool][:name])
        if tool && (tool.folder_id == params[:tool][:folder_id] && params[:folder][:name].empty?)
          # Flash Message when the new tool name already exists for this folder
          flash[:message] = "You already have a tool \'#{params[:tool][:name]}\' with this folder, please use another name."
          redirect :"/tools/new"
        else
          # new folder
          if !params[:folder][:name].empty?
            folder = Folder.find_by(name: params[:folder][:name])
            if folder && folder.user == current_user
              flash[:message] = "Folder \'#{params[:folder][:name]}\' already exists, please select from dropdown menu."
              redirect :"/tools/new"
            else
              folder = Folder.create(name: params[:folder][:name], user_id: current_user.id)
              params[:tool][:folder_id] = folder.id
            end
          end

          @tool = Tool.create(params[:tool])
          # Flash Message when a new tool is created
          flash[:message] = "Successfully created a tool."
          redirect :"/tools/#{@tool.id}/#{@tool.slug}"
        end
      end
    else
      flash[:message] = "You must be logged in to create tools."
      redirect :"/login"
    end
  end

  # GET /tools/:id/:slug route # Show action
  # displays one tool based on ID and slug in the url
  get '/tools/:id/:slug' do
    #binding.pry
    if logged_in?
      @tool = Tool.find_by_id(params[:id])
      if @tool && @tool.slug == params[:slug]
        erb :'/tools/show'
      else
        flash.now[:message] = "Tool's id and name combination not found, please try again."
        redirect :"/tools"
      end
    else
      flash[:message] = "You must be logged in to view the tools."
      redirect :"/login"
    end
  end

  # GET /tools/:id/:slug/edit route #edit action
  # displays one tool based on ID and slug in the url for editing
  get '/tools/:id/:slug/edit' do
    if logged_in?
      @tool = Tool.find_by_id(params[:id])
      if @tool && @tool.slug == params[:slug]
        if @tool.folder.user == current_user
          @folders = Folder.where(user: current_user).sort_by do |folder|
            folder.name
          end
          erb :'/tools/edit'
        else
          flash[:message] = "You must be the tool owner to edit this record."
          redirect :"/tools/#{@tool.id}/#{@tool.slug}"
        end
      else
        flash.now[:message] = "Tool's id and name combination not found, please try again."
        redirect :"/tools"
      end
    else
      flash[:message] = "You must be logged in to edit tools."
      redirect :"/login"
    end
  end

  # PATCH /tools/:id/:slug route #update action
  # modifies an existing tool based on ID and slug in the url
  patch '/tools/:id/:slug' do
    #binding.pry
    if logged_in?
      if params[:tool][:name].empty?
        flash[:message] = "Tool name cannot be left blank."
        redirect :"/tools/#{@tool.id}/#{@tool.slug}/edit"
      else
        @tool = Tool.find_by_id(params[:id])
        if @tool && @tool.folder.user == current_user
          @tool.update(params[:tool])
          # new folder
          if !params[:folder][:name].empty?
            folder = Folder.find_by(name: params[:folder][:name])
            if folder && folder.user == current_user
              flash[:message] = "Folder \'#{params[:folder][:name]}\' already exists, please select from dropdown menu."
              redirect :"/tools/#{@tool.id}/#{@tool.slug}/edit"
            else
              @tool.folder = Folder.create(name: params[:folder][:name], user_id: current_user.id)
              @tool.save
            end
          end
          flash[:message] = "You've successfully updated the tool \'#{params[:slug]}\'."
          redirect :"/tools/#{@tool.id}/#{@tool.slug}"
        else
          flash[:message] = "You must be the tool owner to update this record."
          redirect :"/tools/#{@tool.id}/#{@tool.slug}"
        end
      end
    else
      flash[:message] = "You must be logged in to update a tool."
      redirect :"/login"
    end
  end

  # DELETE /tools/:id/:slug route #delete action
  delete '/tools/:id/:slug' do
    #binding.pry
    if logged_in?
      @tool = Tool.find_by_id(params[:id])
      if @tool && @tool.folder.user == current_user
        @tool.delete
        flash[:message] = "You've successfully deleted your tool #{params[:slug]}."
        redirect :"/users/#{current_user.slug}"
      else
        flash[:message] = "You must be the tool owner to delete this record."
        redirect :"/tools/#{@tool.id}/#{@tool.slug}"
      end
    else
      flash[:message] = "You must be logged in to delete a tool."
      redirect :"/login"
    end
  end
end
