class CatalogsController < ApplicationController
  active_scaffold :"catalog" do |conf|
    conf.action_links.add 'browse', :label => 'Browse',:page=>true, :type => :member
  end
  
  # GET /catalogs/1
  # GET /catalogs/1.json
  def browse
    @catalog = Catalog.find(params[:id])
    
    # since this is first request to organize the items in a catalog (show) use the first page and default size
    # other pages will be loaded via ajax calls
    @page = 1
    @size = 3
    
    # now grab the items for this catalog corresponding to the page and size
    @item_batch = @catalog.get_batch_of_items(@page, @size)
    
    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @catalog } # does not return the item_batch in the json, should use batch_of_items instead
    end
  end
  
  
  # API method to return an array of item objects bounded by the given page and size
  # related to this catalog
  #
  # GET /catalogs/1/batch_of_items
  # GET /catalogs/1/batch_of_items.json
  def batch_of_items
    @catalog=Catalog.find(params[:id])
    
    # set a reasonable default for the current page
    @page=params[:page]
    @page=1 if @page.nil?
    
    # set a reasonable default for the current size
    @size=params[:size]
    @size=12 if @size.nil?
    
    # grab the batch of items corresponding to the page and size
    @items = @catalog.get_batch_of_items(@page, @size)
    
    respond_to do |format|
      # wouldn't make sense to call this API method as html, but for debugging purposes
      # just return json anyway
      format.html { render json: {:items => @items, :page => @page, :size => @size }}
      format.json { render json: {:items => @items, :page => @page, :size => @size }}
    end
  end
  
  # API method to update the sort orders of each pair of id -> sort orders in the :sort_orders param.
  # There are two versions of the API method.  This one receives a hash with id->sort_order pairs and
  # updates each item with the new sort order.  It can be used for single item drag and drop, or 
  # could also be used for multiple item drag and drop if the sort order logic is handled on the client
  # side.
  #
  # NOTE : This does not need to be in the catalogs controller since we know the specific sort order,
  # however, since it deals with a batch of items that are ultimately related to a catalog, seems
  # appropriate to put it here
  #
  # GET /catalogs/1/update_order_of_items
  # GET /catalogs/1/update_order_of_items.json
  def update_order_of_items
    result = Catalog.do_update_order_of_items(params[:sort_orders])
    
    # return a success message, wouldn't make sense to call this API method as html, but for debugging
    # just return json anyway
    respond_to do |format|
      format.html { render json: result}
      format.json { render json: result}
    end
  end
  
  # API method to insert the moved items before the dropped on item, and then recalculate the sort order for 
  # the new list only updating items that have a new sort order.  do not update all items if the sort order 
  # has not changed
  #
  # There are two versions of the API method.  This one receives an array of moved item ids in selected order 
  # and the id of the item they were "dropped on".  It will handle the logic of updating sort orders server
  # side.
  # 
  # GET /catalogs/1/update_order_of_items
  # GET /catalogs/1/update_order_of_items.json
  def update_order_of_items_bulk
    @catalog = Catalog.find(params[:id])
    result = @catalog.do_update_order_of_items_bulk(params[:item_change][:moved_items], params[:item_change][:before_item]);
    
    # return a success message, wouldn't make sense to call this API method as html, but for debugging
    # just return json anyway
    respond_to do |format|
      format.html { render json: result}
      format.json { render json: result}
    end
  end
end
