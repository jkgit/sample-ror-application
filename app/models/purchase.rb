class Purchase < ActiveRecord::Base
  attr_accessible :item_description, :item_price, :merchant_address, :merchant_name, :purchase_count, :purchaser_name
  
  # import, process, and insert records from the given file.
  # returns an array of hashes of the normalized rows
  def self.import(file)
    # create an array of each row in the file
    spreadsheet = open_spreadsheet(file)
    
    # first row is always the header
    header = spreadsheet.row(1)
    
    # store the normalized rows of data for use in calculating total gross
    normalized_rows = []
    
    # our table column names use underscores where the example input uses spaces
    header.map!{|a| a.gsub(" ", "_")}
    
    # now loop through and insert each row while calculating the total gross
    (2..spreadsheet.last_row).each do |i|
      # normalize each value in the row array
      normalized_row = spreadsheet.row(i).map{|a| normalize(a)}
      
      # combine the header array and normalized row array into an array to create a 
      # 2-dimensional array, then transpose that into a hash of header => value
      row = Hash[[header, normalized_row].transpose]
      
      # insert into array of normalized rows for processing
      normalized_rows.push row
          
      # create the new instance of the purchase
      purchase = new
      
      # only set the attributes that are known to be accessible and declared above
      purchase.attributes = row.to_hash.slice(*accessible_attributes)
      
      # now finally save the imported purchase and replace the purchase object with the new
      # saved one
      purchase.save!
    end
    
    # return the imported normalized rows
    return normalized_rows
  end
  
  # method to calculate the total gross from an array of normalized row hashes.
  # could be used to calculate straight from the database as well
  def self.calculate_total_gross (normalized_rows)
    # variable to represent the total gross amount of the purchases in this order only
    total_gross = 0
    
    # loop through each normalized row and add the purchase count * item price to the
    # total gross
    normalized_rows.each do |row|
      # calculate the total gross as we prepare to put the purchases in the database.
      # could get the rows that were just created and calculate from that, but
      # might as well calculate here for efficiency.  this way we don't need to 
      # loop twice or do an extra query
      total_gross=total_gross+(row["purchase_count"].to_i*row["item_price"].to_f)
    end
    
    total_gross
  end
  
  # normalize the given data.  no instructions as to how to normalize so uppercase and trim leading or trailing
  # spaces
  # no need to normalize the $ fields or decimals as they will be handled automatically when inserted
  # into the integer column and decimal column of the db
  def self.normalize (a)
    return a.upcase.strip
  end
  
  # return the parsed rows from the file using Roo.  this might be overkill since we could
  # easily just loop through the spreadsheet and split on tabs to do this ourselves.  but
  # in the long run Roo is better because it can also process other spreadsheet types, like
  # excel, google, etc
  def self.open_spreadsheet(file)
    Roo::CSV.new(file.path, csv_options: {col_sep: "\t"})
  end
end
