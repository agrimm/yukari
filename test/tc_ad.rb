$: << File.join(__dir__, '..', 'lib', 'yukari')

require 'test/unit'
require 'ad'

# Test for ad parser.
class TestAdParser < Test::Unit::TestCase
  def test_split_into_words
    ad_filename = 'test/data/exclude/ads/page_1_20131111.html'
    ad_parser = Yukari::AdParser.new
    ad = ad_parser.parse_ad(ad_filename)
    assert_nothing_raised do
      ad.words
    end
  end

  def test_handle_already_sold
    ad_filename = 'test/data/exclude/ads/already_sold_20131111.html'
    ad_parser = Yukari::AdParser.new
    ad = ad_parser.parse_ad(ad_filename)
    assert_instance_of Yukari::NullAd, ad, "Can't handle already sold"
  end
end
