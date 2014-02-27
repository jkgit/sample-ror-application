class Catalog < ActiveRecord::Base
  attr_accessible :name
  has_many :items
  
  # return an array of item objects corresponding to a batch of items related to this catalog
  def get_batch_of_items (page = nil, size=nil)
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
  
  # switch the sort order of each pair of id -> sort orders in the array
  def self.do_update_order_of_items (sort_orders)
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
  
  # insert the moved items before the dropped on item, and then recalculate the sort order for the new list
  # only updating items that have a new sort order.  do not update all items if the sort order has not changed
  def do_update_order_of_items_bulk (moved_item_ids, before_item_id)
    all_items = Item.where("catalog_id = ?", id).order(:sort_order)
    
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
