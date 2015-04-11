require File.expand_path("../spider",__FILE__)

module Sfda
  class Guoyao
    include Spider
    def table_id
      25
    end
    def parse_page page
    end
    def key_prefix
      "guoyao"
    end
  end
end

