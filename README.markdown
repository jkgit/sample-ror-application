# Sample Ruby on Rails application
This is a sample Ruby on Rails application intended to assist in the evaluation of my development skills.  The project includes the following features :

1. Open ID and Database User Authentication
1. Data Import via uploaded file, including data normalization
1. (not implemented yet) JQuery based batch loading of images, scrolling, and ordering
1. Unit Tests 

## Project Description
Imagine that company X has just acquired a new company Y.  Unfortunately, company Y has never stored their data in a database and instead uses a plain text file.  We need to create a way for the new subsidiary to import their data into a database.  The application should provide a web interface that accepts file uploads, normalizes the data, and then stores it in a relational database.

Some sample requirements:

1. The app must accept (via a form) a tab delimited file with the following columns: purchaser name, item description, item price, purchase count, merchant address, and merchant name.  You can assume the columns will always be in that order, that there will always be data in each column, and that there will always be a header line.  An example input file named example_input.tab is included in this repo.
1. Your app must parse the given file, normalize the data, and store the information in a relational database.
1. After upload, your application should display the total amount gross revenue represented by the uploaded file.
1. Allow the user to store a url to an image of an item
1. Allow the user to attach items to a catalog of items
1. Present a screen containing 3 items from a catalog, load batches of 3 until screen is full.
1. As user scrolls down, load additional 3 items at a time
1. Allow user to sort the items by drag-and-drop (allow multiple drag via click)
1. Allow user to save the new order of items so that when page is reloaded order is maintained
1. Implement methods to retrieve batches of images and store the order as API methods

The application should:

1. Handle authentication or authorization
1. Be easy to setup and run on Linux, Mac OS X, or Windows.
1. Not require any for-pay software.

The application does not need to:

1. be aesthetically pleasing


## Installation

To install the sample application execute the following commands :

    % cd /home/username/projects (or to where you would like to install the application)
    % git clone https://github.com/jkgit/sample-ror-application.git
    % cd sample-ror-application
    % rake db:migrate

## Testing the user interface in a browser

First start the rails server :

    % rails server

Then :

1. Open a browser and go to url http://localhost:3000/
1. On the sign up page you can register an acount one of two ways :
	Create a username and password by clicking on the "Register" link at the top of the page or the "Sign up" link at the bottom of the page.
	Sign in with an Open Id url, example https://www.google.com/accounts/o8/id.
1. Either registration method will return you to welcome page after a successful log in.
1. Click "Import my data"
1. Click "Choose File" and in popup browse to the location where you installed the data-engineering app, then browse to test/fixtures/files/ select "example_input.tab" and select "Open"
1. Click "Upload"
1. Result page should show a notice at the top that your purchases were imported and give you the total gross number.  it will also list the purchases in the system.

## Running Rails tests

Execute the following commands in your shell or command line (or IDE)

    % rake db:reset
    % rake db:test:load
    % rake test

## Third Party Gems

This sample application takes advantage of 3rd party gems (no point reinventing the wheel):

1. Devise - Authentication
1. Active Scaffold - CRUD screens
1. Roo - Spreadsheet support
