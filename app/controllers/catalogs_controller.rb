class CatalogsController < ApplicationController
  active_scaffold :"catalog" do |conf|
    conf.action_links.add 'browse', :label => 'Browse',:page=>true, :type => :member
  end
  
  # GET /movies/1
  # GET /movies/1.json
  def browse
    @catalog = Catalog.find(params[:id])
    
    # since this is first request to organize the scenes in a movie (show) use the first page and default size
    # other pages will be loaded via ajax calls
    @page = 1
    @size = 10
    
    # now grab the scenes for this movie corresponding to the page and size
    #@scene_batch = get_batch_of_scenes(params[:id], @page, @size)
    
    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @catalog } # does not return the scene_batch in the json, should use batch_of_scenes instead
    end
  end
end
