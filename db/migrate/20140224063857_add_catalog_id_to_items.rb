class AddCatalogIdToItems < ActiveRecord::Migration
  def change
    add_column :items, :catalog_id, :integer, null:true
  end
end
