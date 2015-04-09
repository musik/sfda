require File.expand_path("../spider",__FILE__)

module Sfda
  class Guoyao
    include Spider
    #def root
    #end
    def word page
      page.doc.title.match(/^(.+?)_/)[1] rescue nil
    end
    def key_prefix
      "guoyao"
    end
    def filter_links page
      page.links.select{|l|
        m = l.to_s.match(/\/s-([\w\d]+)\.html\Z/)
        !m.nil? and m[1].length <= 20
      }
    end
  end
end

