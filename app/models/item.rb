class Item < ActiveRecord::Base
  attr_accessible :description, :price, :sort_order, :catalog_id, :url
  has_many :purchases
  belongs_to :catalog
  
  def to_label
    return description
  end
end
