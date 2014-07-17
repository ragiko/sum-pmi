#!/usr/bin/ruby
# -*- coding: utf-8 -*-

require "./rubyLib/file_util.rb"
require "./rubyLib/mecab_lib.rb"
require "json"
require "pp"

# csjのpmiを取得
json = File.open("./data/pmi.json").read()
csj_pmi = JSON.parse(json)

# スライドの文書群を取得
slide_path = "./data/slide_recognition_txt"
slide_contents = FileUtil::get_file_contents(slide_path)

# corpus = csj
# slide
slide_contents.each do |slide_content|

  body = slide_content[:body].delete("\n ")

  # 検索対象文書の単語を取得
  slide_words = MeCabLib.new.analyze_sentence(body)

  # 1文書のsum pmi ベクトル
  # {"発表" => 0.011, ...}
  sum_pmi_vector = {}

  slide_words.each do |word| 
    if csj_pmi[word].nil? == false
      # word の sum pmiを計算
      sum_pmi = csj_pmi[word].reduce(0.0) { |sum, (key, value)| sum += value unless key == word }
      sum_pmi_vector[word] = sum_pmi
    end
  end

  slide_content[:sum_pmi_vector] = sum_pmi_vector
end

##
# slideの情報を返す
#
# == FORMAT ==
#[{:filename => "filename1",
# :body => "わがはいは猫である", 
# :sum_pmi_vector => {"モデル"=>1.3, "うち"=>"データ"}}]
## 
pp slide_contents[0]

File.open("./result/sum_pmi_for_search_document.json", "w") do |f|
  f.write(slide_contents.to_json)
end


