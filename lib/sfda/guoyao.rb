require File.expand_path("../spider",__FILE__)

module Sfda
  class Guoyao
    include Spider
    def table_id
      25
    end
    def parse_page page,&block
      return unless page.url.to_s.match(/content.jsp/)
      data = {:meta=>{}}
      ignores = %w(相关数据库查询 注)
      ignores << ""
      data[:changjia_guojia] = "中国"
      data[:source_id] = page.url.to_s.match(/Id=(\d+)/)[1].to_i
      keys = {
        "批准文号"=>:wenhao,
         "原批准文号"=>:yuanwenhao,
         "药品本位码"=>:benweima,
         "药品本位码备注"=>:benweima_beizhu,
         "产品名称"=>:name,
         "英文名称"=>:en,
         "商品名"=>:shangpin_name,
         "生产单位"=>:changjia_name,
         "生产地址"=>:changjia_dizhi,
         "规格"=>:guige,
         "剂型"=>:jixing,
         "产品类别"=>:leibie,
         "批准日期"=>:pizhunri
      }
      page.doc.css('table[align=center] tr').each do |tr|
        td2 = tr.css('td')[1]
        next if td2.nil?
        key = tr.css('td')[0].text
        next if ignores.include? key
        val = td2.text.strip
        next if val.nil? or val == ""
          
        if keys.has_key? key
          data[keys[key]] = val
        else
          data[:meta][key] = val
        end
      end
      yield data
    end
    def key_prefix
      "guoyao"
    end
  end
end

