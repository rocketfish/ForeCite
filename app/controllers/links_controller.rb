class LinksController < ApplicationController
include LinksHelper
include Tasks::Yahoo        # This is where the problems lie

def index
  # @nokoTest = nokoTest
end

# This is called from Angular getReading function
def search
  @books = further_reading(params[:q])
  render json: @books
end

def products
  @book = Book.create
  @amazon_data = @book.batch_requests(params[:q].split("-"))
  render json: @amazon_data
end

def boss
  binding.pry
  @results = boss_call(params[:q])
  render json: @results
end

end
