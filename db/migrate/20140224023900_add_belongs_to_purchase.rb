class AddBelongsToPurchase < ActiveRecord::Migration
  def change
    add_column :purchases, :item_id, :integer
    add_column :purchases, :purchaser_id, :integer
    add_column :purchases, :merchant_id, :integer
  end
end
