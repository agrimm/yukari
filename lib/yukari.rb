$:.unshift File.join(__dir__, 'yukari')

require 'flatmate_search'
require 'results'

# Parser for Gumtree, to find a Japanese-speaking flatmate.
class Yukari
  # AD_PAGE_GLOB = 'pages/ads/*'
  AD_PAGE_GLOB = 'pages/ads/sydney_flatshare_wanted_20131117/*'

  def self.find_flatmate
    filenames = Dir.glob(AD_PAGE_GLOB)
    flatmate_search = FlatmateSearch.new(filenames)
    puts flatmate_search.match_report_output
  end

  def self.download_new_ads!
    fail 'bin/ad_downloader results_page.html' if ARGV.empty?
    results_filename = ARGV.first
    result_parser = ResultParser.new
    result = result_parser.parse_result(results_filename)
    result.download_new_ads!
  end
end
