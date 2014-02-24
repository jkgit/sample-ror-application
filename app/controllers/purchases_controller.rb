class PurchasesController < ApplicationController
  active_scaffold :"purchase" do |conf|
    list.columns = [:purchaser_name, :item_description, :merchant_address, :merchant_name ]
    show.columns = [:purchaser_name, :item_description, :item_price, :purchase_count, :merchant_address, :merchant_name ]
    list.sorting = {:purchaser_name => 'ASC'}
  end
  
  def import
  end
  
  def do_import
    # import the normalized rows from the uploaded attachment
    normalized_rows = Purchase.import params[:attachment]
    
    # calculate total gross from the returned rows
    total_gross = Purchase.calculate_total_gross normalized_rows
    
    # return a message with the total rows.  send along a param with the total gross
    # and also include the total gross in our success message since we are redirecting
    # to the purchases list page.
    redirect_to purchases_url(:total_gross=>total_gross), notice: "Purchases imported. Total amount of gross revenue in this import #{total_gross}."
  end
end
