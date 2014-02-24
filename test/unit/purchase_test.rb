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
  
  # test that the correct number of records are created from the example input
  test "rows imported" do
    # save the current number of purchases to compare later
    current_purchases = Purchase.count
    
    #load purchases from the example input
    File.open("test/fixtures/files/example_input.tab", "r") do |aFile|
      Purchase.import aFile
    end
    
    # now find the new number of purchases after importing
    new_purchases_count = Purchase.count

    # check to be sure they are exactly 4 different (the known number of rows)
    calculated_new_purchases = new_purchases_count - current_purchases
    assert calculated_new_purchases == 4, "Expected 4 new purchase records but found #{calculated_new_purchases}"
  end
  
  # test that the normalize function works
  test "values normalized" do
    # start clean so we will know for sure there is no existing data that is not normalized
    Purchase.delete_all
    
    # first load all the rows from the denormalized test spreadsheet
    File.open("test/fixtures/files/example_denormalized_input.tab", "r") do |aFile|
      Purchase.import aFile
    end
    
    # now load the inserted purchases from the db
    purchases = Purchase.all
    
    # loop through each purchase and test if the purchaser name is normalized
    purchases.each do |purchase| 
      calculated_normalized_name=Purchase.normalize(purchase.purchaser_name)
      found_normalized_name=purchase.purchaser_name
      
      # compare the calculated name and the found name, if they are different it means that
      # the name was not normalized when inserted into the db
      assert found_normalized_name == found_normalized_name, "Expected #{calculated_normalized_name} but found #{found_normalized_name}"
    end
  end
end
