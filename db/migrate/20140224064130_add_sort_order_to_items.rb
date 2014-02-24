class AddSortOrderToItems < ActiveRecord::Migration
  def change
    add_column :items, :sort_order, :integer
  end
end
