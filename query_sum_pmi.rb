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
query_path = "./data/query.txt"
queries = File.open(query_path).read()
                .delete(" ")
                .split("\n")

##
# queryの情報
#
# == FORMAT ==
#[{:body => "わがはいは猫である", 
# :sum_pmi_vector => {"モデル"=>1.3, "うち"=>"データ"}}]
## 
query_sum_pmi = []

## 
# SUM PMI を計算 
##
queries.each do |query|

  # 検索対象文書の単語を取得
  query_words = MeCabLib.new.analyze_sentence(query)

  # 単語の組み合わせ
  # [["位置", "手法"], ["位置", 問題], ..]
  combination_words = query_words.combination(2).to_a
  
  # 2重ハッシュ化
  # {"行程"=>{"テスト"=>0, "面"=>0}, ...}
  h = Hash.new { |h, k| h[k] = Hash.new(0) }
  combination_word_hash = h

  combination_words.map { |word1, word2|
    combination_word_hash[word1][word2] = 1
  }
  
  # sum pmi ベクトル
  # {"定式"=>3.37, "化"=>0.48, ...}
  sum_pmi_vector = {}

  query_words.each do |word1| 
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

  query_sum_pmi << { body: query  ,sum_pmi_vector: sum_pmi_vector }
end

File.open("./result/sum_pmi_for_query.json", "w") do |f|
  f.write(query_sum_pmi.to_json)
end


