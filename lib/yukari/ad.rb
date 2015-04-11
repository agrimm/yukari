# This already has a class description elsewhere.
class Yukari
  # Representation of an ad.
  class Ad
    attr_reader :words
    def initialize(words)
      @words = words
      # STDERR.puts "Size is #{@words.size}"
    end
  end

  # An ad that's already been sold
  class NullAd
    def words
      []
    end
  end
end
