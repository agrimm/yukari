$:.unshift __dir__

require 'ad'
require 'nokogiri'

# This already has a class description elsewhere.
class Yukari
  # Parse HTML pages representing an ad.
  class AdParser
    def parse_ad(ad_filename)
      document = Nokogiri::HTML(File.read(ad_filename))
      ad_description_node = find_ad_description_node(document)
      reply_form_name_node = find_reply_form_name_node(document)
      sold_node = find_sold_node(document)
      price_node = find_price_node(document)
      location_node = find_location_node(document)
      validate(sold_node, ad_description_node)
      return NullAd.new if sold_node
      content = ad_description_node.content + ' ' + reply_form_name_node.content
      price_string = price_node.content.strip
      location = location_node.content
      create_ad(content, price_string, location)
    end

    def find_ad_description_node(document)
      ad_description_xpath = './/div[contains(@id, "ad-description")]'
      ad_description_nodes = document.xpath(ad_description_xpath)
      ad_description_nodes.first
    end

    def find_reply_form_name_node(document)
      reply_form_name_xpath = './/div[contains(@class, "reply-form-name")]'
      reply_form_name_nodes = document.xpath(reply_form_name_xpath)
      return NullReplyFormNameNode.new if reply_form_name_nodes.empty?
      reply_form_name_nodes.first
    end

    def find_sold_node(document)
      sold_xpath = './/div[contains(@class, "c-ribbon-wrapper c-rounded-corners3 c-margin-vertical1")]'
      sold_nodes = document.xpath(sold_xpath)
      return sold_nodes.first unless sold_nodes.empty?

      ad_expired_xpath = './/div[contains(@id, "ad-expired")]'
      ad_expired_nodes = document.xpath(ad_expired_xpath)
      ad_expired_nodes.first
    end

    def find_price_node(document)
      price_node_xpath = '//div[contains(@itemprop, "price")]'
      price_nodes = document.xpath(price_node_xpath)
      price_nodes.first
    end

    def find_location_node(document)
      c_inline_ul_node_xpath = '//ul[contains(@class, "c-inline")]'
      c_inline_ul_node = document.at_xpath(c_inline_ul_node_xpath)
      c_inline_ul_node_children = c_inline_ul_node.children
      real_estate_index = c_inline_ul_node_children.find_index do |c_inline_ul_node_child|
        a_node = c_inline_ul_node_child.children.first
        next if a_node.nil?
        content = a_node.content
        content.strip == 'Real Estate'
      end
      smallest_location_c_inline_ul_node_child = c_inline_ul_node_children[real_estate_index - 2]
      smallest_location_c_inline_ul_node_child.children.first
    end

    def validate(sold_node, ad_description_node)
      fail 'sold but has a description' if sold_node && ad_description_node
      fail 'neither sold nor has description' if !sold_node && !ad_description_node
    end

    def create_ad(content, price_string, location)
      # FIXME: Use a proper gem for natural language processing.
      words = content.split(/\W+/)
      price = parse_price_string(price_string)
      Ad.new(words, price_string, price, location)
    end

    def parse_price_string(price_string)
      return 0.0 if price_string == 'Negotiable'
      return 0.0 if price_string == 'Swap/Trade'
      return 0.0 if price_string == 'Free'
      return 0.0 if price_string.include?(',')
      return 0.0 if price_string.empty?
      negotiable_removed = price_string.gsub("\xC2\xA0Negotiable", '')
      Float(negotiable_removed[1..-1])
    end
  end

  # A reply from name node couldn't be found
  class NullReplyFormNameNode
    def content
      ''
    end
  end
end
