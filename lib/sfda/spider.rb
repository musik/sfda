require 'anemone'
require 'typhoeus'
module Sfda
  module Extend
    def run opts = {}
      new.run opts
    end
  end
  module Spider
    def self.included(base)
      base.extend Extend
    end
    def run opts = {}
      defaults = {
        #pages_queue_limit: 10000,
        #links_limit: 10,
        #skip_query_strings: true,
        #discard_page_bodies: true,
        user_agent: "Mozilla/5.0 (compatible; Baiduspider/2.0; +http://www.baidu.com/search/spider.html",
        #storage: storage
        #verbose: true
      }
      opts = defaults.merge opts
      max_pages = opts.delete(:max_pages) || 9999999
      key = opts.delete(:key) 
      num_pages = 0
      Anemone.crawl(root,opts) do |anemone|
        anemone.on_every_page do |page|
          num_pages += 1
          parse_page page do |data|
            post_to_yaozui data,key
          end
          anemone.stop_crawl if num_pages > max_pages
        end
        anemone.focus_crawl do |page|
          filter_links page
        end
      end
    end
    def table_id
      raise Sfda::MethodRequired, "table id method required"
    end
    def filter_links page
      @links = []
      if page.url.to_s.match(/search.jsp/)
        page.doc.search("//a[@href]").each do |a|
          u = a['href']
          u = u.match(/'(content.jsp\?tableId=.+)'/)
          next if u.nil?
          abs = page.to_absolute(u[1]) rescue next
          @links << abs if page.in_domain?(abs)
        end
        i = next_page(page)
        @links << page.to_absolute(root + "&curstart=#{i}") unless i.nil?
      end
      @links
    end
    def post_to_yaozui data,key
      pp Typhoeus.post("http://www.vcap.me:4006/pihao/ping",body: {data: data,key: key})
      pp data
      exit

    end
    def next_page page
      page.doc.at_css("img[src='images/dataanniu_07.gif']").attr("onclick").match(/Page\((\d+)\)/)[1].to_i rescue nil
    end
    def total_pages(page)
      page.body.scan(/devPage\((\d+)\)/).flatten.last.to_i rescue 0
    end
    def parse_page page
      raise Sfda::MethodRequired, "parse_page method required"
    end
    def root
      'http://app1.sfda.gov.cn/datasearch/face3/search.jsp?tableId=' + table_id.to_s
    end
    def key_prefix
      raise Sfda::MethodRequired, "key_prefix method required"
    end
  end
end
