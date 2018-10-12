class ToolsController < ApplicationController

  # GET /tools route #index action
  get "/tools" do
    erb :index
  end

  # GET /tools/:id/:slug route # Read action to list the tools based on :id and :slug in the url
  get '/tools/:id/:slug' do
    @tool = Tool.find_by(params[:id])
    if @tool
      erb :'/tools/show'
    else
      erb :'not_found'
    end
  end

end
