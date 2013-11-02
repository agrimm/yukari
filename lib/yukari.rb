$:.unshift File.join(__dir__, 'yukari')

require 'flatmate_search'

# Parser for Gumtree, to find a Japanese-speaking flatmate.
class Yukari
  AD_PAGE_GLOB = 'pages/ads/*'

  def self.find_flatmate
    filenames = Dir.glob(AD_PAGE_GLOB)
    flatmate_search = FlatmateSearch.new(filenames)
    puts flatmate_search.match_report_output
  end
end
