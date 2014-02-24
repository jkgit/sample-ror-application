class RemoveColumnsFromPurchase < ActiveRecord::Migration
  def up
    remove_column :purchases, :item_description 
    remove_column :purchases, :item_price
    remove_column :purchases, :merchant_address
    remove_column :purchases, :merchant_name
    remove_column :purchases, :purchaser_name
  end

  def down
    add_column :purchases, item_description:string
    add_column :purchases, item_price:integer
    add_column :purchases, merchant_address:string
    add_column :purchases, merchant_name:string
    add_column :purchases, purchaser_name:string
  end
end
