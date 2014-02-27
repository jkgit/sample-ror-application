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
    @item_batch = get_batch_of_items(params[:id], @page, @size)
    
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
    # set a reasonable default for the current page
    @page=params[:page]
    @page=1 if @page.nil?
    
    # set a reasonable default for the current size
    @size=params[:size]
    @size=12 if @size.nil?
    
    # grab the batch of items corresponding to the page and size
    @items = get_batch_of_items(params[:id], @page, @size)
    
    respond_to do |format|
      # wouldn't make sense to call this API method as html, but for debugging purposes
      # just return json anyway
      format.html { render json: {:items => @items, :page => @page, :size => @size }}
      format.json { render json: {:items => @items, :page => @page, :size => @size }}
    end
  end
  
  # return an array of item objects corresponding to a batch of items related to this catalog
  def get_batch_of_items (id, page = nil, size=nil)
    # set reasonable defaults for page and convert to an int
    page=page.nil? ? 1 : page.to_i
    
    # set reasonable defaults for size and convert to an int
    size=size.nil? ? 12 : size.to_i
    
    # calculate the start item based on the page and the size of the batch
    start_item = (page - 1) * size + 1
    
    # grab the next set of items based on start item and size for this catalog.  this is not ideal
    # because it grabs all items first and then processes them.  would be better to only select a 
    # page at a time when executing the query
    all_items_for_catalog = Item.where("catalog_id = ?", id).order(:sort_order);
    item_groups = all_items_for_catalog.in_groups_of(size, false)
    if (item_groups.length>=page)
      return item_groups[page-1]
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
    result = do_update_order_of_items(params[:sort_orders])
    
    # return a success message, wouldn't make sense to call this API method as html, but for debugging
    # just return json anyway
    respond_to do |format|
      format.html { render json: result}
      format.json { render json: result}
    end
  end
  
  # switch the sort order of each pair of id -> sort orders in the array
  def do_update_order_of_items (sort_orders)
    result = "success";
    
    sort_orders.each do |k,v|
      item=Item.find(k);
      item.sort_order=v;
      if !item.save then
        result = "failed"
      end 
    end
    
    result
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
    result = do_update_order_of_items_bulk(params[:id], params[:item_change][:moved_items], params[:item_change][:before_item]);
    
    # return a success message, wouldn't make sense to call this API method as html, but for debugging
    # just return json anyway
    respond_to do |format|
      format.html { render json: result}
      format.json { render json: result}
    end
  end
  
  # insert the moved items before the dropped on item, and then recalculate the sort order for the new list
  # only updating items that have a new sort order.  do not update all items if the sort order has not changed
  def do_update_order_of_items_bulk (catalog_id, moved_item_ids, before_item_id)
    all_items = Item.where("catalog_id = ?", catalog_id).order(:sort_order)
    
    # will hold item objects based on ids in moved_items
    new_items = Array.new
      
    # loop through all items related to this catalog and insert the moved items before the item
    all_items.each do |item|
      # insert the moved items before this item if its id matches the before_item_id
      if (item.id==before_item_id.to_i) then
        moved_item_ids.each do |moved_item_id|
          new_items.push Item.find(moved_item_id)
        end
      end
      
      # don't add the moved items back into the array at their regular position but add everything else
      if moved_item_ids.index(item.id.to_s).nil? then
        new_items.push item
      end
    end
    
    # a hash to hold the item id and item sort order of any items that were affected by the move
    changed_items = Hash.new
    
    # now loop through all items and reset the sort order.  save the item if changed and populate an array
    # which we will return 
    current_sort_order=1
    new_items.each do | item |
      if (item.sort_order != current_sort_order )
        item.sort_order=current_sort_order
        if item.save then
          changed_items[item.id]=item.sort_order
        end
      end  
      current_sort_order=current_sort_order+1
    end
    
    Rails.logger.debug("Changed sort orders: #{changed_items.inspect}")
    
    return changed_items
  end

end
