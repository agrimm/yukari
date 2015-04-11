$:.unshift __dir__

require 'ad'
require 'nokogiri'

# This already has a class description elsewhere.
class Yukari
  # Parse HTML pages representing an ad.
  class AdParser
    def parse_ad(ad_filename)
      # return NullAd.new unless File.exist?(ad_filename)
      # STDERR.puts "Parsing #{ad_filename.inspect}"
      document = Nokogiri::HTML(File.read(ad_filename))
      ad_description_node = find_ad_description_node(document)
      reply_form_name_node = find_reply_form_name_node(document)
      sold_node = find_sold_node(document)
      fail 'sold but has a description' if sold_node && ad_description_node
      fail 'neither sold nor has description' if !sold_node && !ad_description_node
      return NullAd.new if sold_node
      content = ad_description_node.content + ' ' + reply_form_name_node.content
      create_ad(content)
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

    def create_ad(content)
      # FIXME: Use a proper gem for natural language processing.
      words = content.split(/\W+/)
      Ad.new(words)
    end
  end

  # A reply from name node couldn't be found
  class NullReplyFormNameNode
    def content
      ''
    end
  end
end