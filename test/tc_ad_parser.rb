$: << File.join(__dir__, '..', 'lib', 'yukari')

require 'test/unit'
require 'ad_parser'

# Test for ad parser.
class TestAdParser < Test::Unit::TestCase
  def test_split_into_words
    ad_filename = 'test/data/exclude/ads/page_1_20131111.html'
    skip 'File not found' unless File.exist?(ad_filename)
    ad_parser = Yukari::AdParser.new
    ad = ad_parser.parse_ad(ad_filename)
    assert_nothing_raised do
      ad.words
    end
  end

  def test_words_followed_by_exclamation_mark_split
    ad_filename = 'test/data/exclude/ads/page_1_20150322.html'
    skip 'File not found' unless File.exist?(ad_filename)
    expected_word = 'Japanese'
    failure_message = "A word at the end of the sentence isn't parsed"

    ad_parser = Yukari::AdParser.new
    ad = ad_parser.parse_ad(ad_filename)

    assert_include ad.words, expected_word, failure_message
  end

  def test_handle_already_sold
    ad_filename = 'test/data/exclude/ads/already_sold_20131111.html'
    skip 'File not found' unless File.exist?(ad_filename)
    ad_parser = Yukari::AdParser.new
    ad = ad_parser.parse_ad(ad_filename)
    assert_instance_of Yukari::NullAd, ad, "Can't handle already sold"
  end
end
