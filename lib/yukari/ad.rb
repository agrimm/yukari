require 'nokogiri'

# Parser for Gumtree, to find a Japanese-speaking flatmate.
class Yukari
  # Parse HTML pages representing an ad.
  class AdParser
    def parse_ad(ad_filename)
      document = Nokogiri::HTML(File.read(ad_filename))
      nodes = document.xpath('.//p')
      node = nodes.first
      content = node.content
      words = content.split(/[ \r]/)
      Ad.new(words)
    end
  end

  # Representation of an ad.
  class Ad
    attr_reader :words
    def initialize(words)
      @words = words
    end
  end
end
