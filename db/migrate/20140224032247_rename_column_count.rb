class RenameColumnCount < ActiveRecord::Migration
  def up
    rename_column :purchases, :purchase_count, :count
  end

  def down
    rename_column :purchases, :count, :purchase_count
  end
end
