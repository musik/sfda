require 'anemone'
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
    def words opts={}
      stats = opts[:word_stats] || false
      storage = Sfda::Redis.new(key_prefix: (opts[:key_prefix] || key_prefix))
      if stats
        count = 0
        storage.each do |url,page|
          count+=1  unless page.data.nil? or page.data[:word].nil?
        end
        puts "total #{count}"
      else
        storage.each do |url,page|
          puts page.data[:word]  unless page.data.nil? or page.data[:word].nil?
        end
      end
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
      num_pages = 0
      Anemone.crawl(root,opts) do |anemone|
        anemone.on_every_page do |page|
          num_pages += 1
          parse_page page
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
        pages = total_pages(page)
        if pages > 1
          1.upto(pages) do |p|
            #pp root + "&curstart=#{p}"
          end
        end
      end
      @links
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
