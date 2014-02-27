# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)

(1..5).each do |i|
  Catalog.create(name: "Test catalog #{i}")

  (1..40).each do|x|
    Item.create description: "Test item #{x}", price: 19.99, catalog_id: i, sort_order: x, url: "http://placehold.it/200/22#{x}#{x}#{x}#{x}/ff#{x%10}#{x%10}#{x%10}#{x%10}&text=thumbnail-#{x}"
  end
end
