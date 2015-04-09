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
      #storage = Sfda::Redis.new(
        #key_prefix: (opts[:key_prefix] || key_prefix),
        #resume: (opts[:resume] || false),
        #clear: opts[:resume] ? false : true ,
      #)
      defaults = {
        #pages_queue_limit: 10000,
        #links_limit: 10,
        skip_query_strings: true,
        #discard_page_bodies: true,
        user_agent: "Mozilla/5.0 (compatible; Baiduspider/2.0; +http://www.baidu.com/search/spider.html",
        #storage: storage
        #verbose: true
      }
      opts = defaults.merge opts
      max_pages = opts.delete(:max_pages) || 9999999
      num_pages = 0
      #urls = storage.urls.empty? ? root :  storage.urls
      Anemone.crawl(root,opts) do |anemone|
        anemone.on_every_page do |page|
          num_pages += 1
          page.data[:word] = word(page)
          p page.data[:word] if opts[:verbose]
          anemone.stop_crawl if num_pages > max_pages
        end
        anemone.focus_crawl do |page|
          filter_links page
        end
      end
    end
    def filter_links links
      links
    end
    def word page
      raise Sfda::MethodRequired, "word method required"
    end
    def root
      raise Sfda::MethodRequired, "root method required"
    end
    def key_prefix
      raise Sfda::MethodRequired, "key_prefix method required"
    end
  end
end
