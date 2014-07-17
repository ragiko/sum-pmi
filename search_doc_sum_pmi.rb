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

# 
####################
##
# queryの情報
#
# == FORMAT ==
#[{:body => "わがはいは猫である", 
# :sum_pmi_vector => {"モデル"=>1.3, "うち"=>"データ"}}]
## 
slide_sum_pmi = []

## 
# SUM PMI を計算 
##
slide_contents.each do |slide_content|

  doc =  slide_content[:body].delete("\n ")


  # 検索対象文書の単語を取得
  words = MeCabLib.new.analyze_sentence(doc)

  # 単語の順列
  # [["位置", "手法"], ["位置", 問題], ..]
  combination_words = words.permutation(2).to_a
  
  # 2重ハッシュ化
  # {"行程"=>{"テスト"=>0, "面"=>0}, ...}
  h = Hash.new { |h, k| h[k] = Hash.new(0) }
  combination_word_hash = h

  combination_words.map { |word1, word2|
    combination_word_hash[word1][word2] = 0
  }

  # sum pmi ベクトル
  # {"定式"=>3.37, "化"=>0.48, ...}
  sum_pmi_vector = {}

  words.each do |word1| 

    sum_pmi = 0.0
    combination_word_hash[word1].keys.each do |word2| 

      # a[w1]とa[w1][w2]の順でnilチェッしないとダメ
      if csj_pmi[word1].nil? == false and 
            csj_pmi[word1][word2].nil? == false

        sum_pmi += csj_pmi[word1][word2]     
      end
    end

    sum_pmi_vector[word1] = sum_pmi
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

File.open("./result/sum_pmi_for_search_document.json", "w") do |f|
  f.write(slide_contents.to_json)
end


