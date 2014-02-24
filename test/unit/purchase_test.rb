require 'test_helper'

class PurchaseTest < ActiveSupport::TestCase
  # test that the example input can be loaded, processed, and that it returns the correct
  # total gross value
  test "total gross" do
    total_gross = nil
    
    # import the example input and save the total gross returned from just this import method
    # not including any other data in db
    File.open("test/fixtures/files/example_input.tab", "r") do |aFile|
      normalized_rows = Purchase.import aFile
      total_gross = Purchase.calculate_total_gross normalized_rows
    end

    # check to be sure the calculated total gross is equal to known value of 95
    assert total_gross==95
  end
  
  # test that the correct number of records are created from the example input.  make
  # sure to also test for normalized data
  test "rows imported" do
    # start clean so we will know for sure there is no existing data that is not normalized
    Purchase.delete_all
    Merchant.delete_all
    Item.delete_all
    Purchaser.delete_all
    
    #load purchases from the example input
    File.open("test/fixtures/files/example_input.tab", "r") do |aFile|
      Purchase.import aFile
    end
    
    # now find the new number of purchases after importing
    new_purchases_count = Purchase.count
    # number of merchants
    new_merchants_count = Merchant.count
    # number of items
    new_items_count = Item.count
    # number of purchasers
    new_purchasers_count = Purchaser.count

    assert new_purchases_count == 4, "Expected 4 new purchase records but found #{new_purchases_count}"
    assert new_merchants_count == 3, "Expected 3 new merchant records but found #{new_merchants_count}"
    assert new_items_count == 3, "Expected 3 new item records but found #{new_items_count}"
    assert new_purchasers_count == 3, "Expected 3 new purchaser records but found #{new_purchasers_count}"
  end
  
  # test that the standardized function works
  test "values standardized" do
    # start clean so we will know for sure there is no existing data that is not normalized
    Purchase.delete_all
    
    # first load all the rows from the notstandardized test spreadsheet
    File.open("test/fixtures/files/example_notstandardized_input.tab", "r") do |aFile|
      Purchase.import aFile
    end
    
    # now load the inserted purchases from the db
    purchases = Purchase.all
    
    # loop through each purchase and test if the purchaser name is normalized
    purchases.each do |purchase| 
      calculated_standardized_name=Purchase.standardize(purchase.purchaser.name)
      found_standardized_name=purchase.purchaser.name
      
      # compare the calculated name and the found name, if they are different it means that
      # the name was not s when inserted into the db
      assert found_standardized_name == calculated_standardized_name, "Expected #{calculated_standardized_name} but found #{found_standardized_name}"
    end
  end
end
