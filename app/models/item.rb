class Item < ActiveRecord::Base
  attr_accessible :description, :price
  has_many :purchases
  
  def to_label
    return description
  end
end
