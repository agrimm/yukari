# This already has a class description elsewhere.
class Yukari
  # Representation of an ad.
  class Ad
    attr_reader :words, :price_string, :price, :location
    def initialize(words, price_string, price, location)
      @words = words
      # STDERR.puts "Size is #{@words.size}"
      @price_string = price_string
      @price = price
      @location = location
    end
  end

  # An ad that's already been sold
  class NullAd
    def words
      []
    end
  end
end
