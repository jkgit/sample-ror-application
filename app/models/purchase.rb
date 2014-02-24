class Purchase < ActiveRecord::Base
  attr_accessible :count
  belongs_to :purchaser
  belongs_to :merchant
  belongs_to :item
  
  # import, process, and insert records from the given file.
  # returns an array of hashes of the normalized rows
  def self.import(file)
    # create an array of each row in the file
    spreadsheet = open_spreadsheet(file)
    
    # first row is always the header
    header = spreadsheet.row(1)
    
    # our table column names use underscores where the example input uses spaces
    header.map!{|a| a.gsub(" ", "_")}
    
    # store the normalized rows of data for use in calculating total gross
    purchases = []
    
    # now loop through and insert each row while calculating the total gross
    (2..spreadsheet.last_row).each do |i|
      
      # standardize data
      standardized_row = spreadsheet.row(i).map{|a| standardize(a)}
      
      # combine the header array and normalized row array into an array to create a 
      # 2-dimensional array, then transpose that into a hash of header => value.  this makes
      # it easy to retrieve data below
      row = Hash[[header, standardized_row].transpose]
      
      # look for a matching item, if none found create a new one.  this assumes the item
      # always has the same price
      item=Item.find_by_description(row['item_description'])
      if (item==nil) then
        item=Item.create
        item.description=row['item_description']
        item.price=row['item_price'].to_f
        item.save
      end
      
      # look for a matching merchant, if none found create a new one.  this assumes the merchant
      # always has the same address
      merchant=Merchant.find_by_name(row['merchant_name'])
      if (merchant==nil) then
        merchant=Merchant.create
        merchant.name=row['merchant_name']
        merchant.address=row['merchant_address']
        merchant.save
      end
      
      # look for a matching purchaser, if none found create a new one. 
      purchaser=Purchaser.find_by_name(row['purchaser_name'])
      if (purchaser==nil) then
        purchaser=Purchaser.create
        purchaser.name=row['purchaser_name']
        purchaser.save
      end
          
      # create the new instance of the purchase
      purchase = new
      
      # set the attributes of the purchase and connect to item, merchant, and purchaser
      # created or retrieved above
      purchase.count = row['purchase_count'].to_i
      purchase.item = item
      purchase.merchant = merchant
      purchase.purchaser = purchaser
      
      # now finally save the imported purchase and replace the purchase object with the new
      # saved one
      purchase.save!
      
      # insert into array of purchases for later processing
      purchases.push purchase
    end
    
    # return the imported normalized rows
    return purchases
  end
  
  # method to calculate the total gross from an array of normalized row hashes.
  # could be used to calculate straight from the database as well
  def self.calculate_total_gross (purchases)
    # variable to represent the total gross amount of the purchases in this order only
    total_gross = 0
    
    # loop through each purchase and add the purchase count * item price to the
    # total gross
    purchases.each do |purchase|
      # calculate the total gross of the given purchases
      total_gross=total_gross+(purchase.count*purchase.item.price)
    end
    
    total_gross
  end
  
  # standardize the given data.  no instructions as to how to standardize so uppercase and trim 
  # leading or trailing spaces. no need to normalize the $ fields or decimals as they will be 
  # handled automatically when inserted into the integer column and decimal column of the db
  def self.standardize (a)
    return a.upcase.strip
  end
  
  # return the parsed rows from the file using Roo.  this might be overkill since we could
  # easily just loop through the spreadsheet and split on tabs to do this ourselves.  but
  # in the long run Roo is better because it can also process other spreadsheet types, like
  # excel, google, etc
  def self.open_spreadsheet(file)
    Roo::CSV.new(file.path, csv_options: {col_sep: "\t"})
  end
  
  def to_label
    return id
  end
end
