require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe Sfda::Guoyao do
  it "should run" do
    Sfda::Guoyao.run verbose: true,max_pages: 30,key: "ABC"#,resume: true,key_prefix: "test_guoyao"
  end
end
