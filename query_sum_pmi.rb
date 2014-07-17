#!/usr/bin/ruby
# -*- coding: utf-8 -*-

require "./rubyLib/scraiping"
require "./extractcontent/lib/extractcontent"
require "./rubyLib/mecab_tfidf.rb"
require "json"
require "nkf"
require "pp"

queries = File.open("./data/query.txt").read()
              .delete(" ")
              .split("\n")

# 文書ごとのTFIDF
tfidf_vectors = MeCabTFIDF::mecab_tfidf(queries).tf_idf
## 1番目の文書について
tfidf_vector = tfidf_vectors[0]

# sort to value
tfidf_vector_sort = tfidf_vector.sort {|(k1, v1), (k2, v2)| v2 <=> v1 }

# TFIDF TOP 8 WORDS
tfidf_top_words = tfidf_vector_sort[0..7].map{ |a, b| a }

# TFIDFの単語3の組み合わせ
combination_words = tfidf_top_words.combination(3).to_a

## 
# WEBから情報を取得
##
# 検索エンジンインスタンス初期化 
web_client = Scraiping::WebClient.new       # Webアクセスを担当するインスタンスを生成
yahoo_search = Scraiping::YahooSearch.new   # Yahoo検索エンジンのインスタンスを生成
yahoo_search.web_client = web_client        # 検索結果ページへのアクセスにweb_clientインスタンスを使用
# WEBから取得した情報を格納
# == FORMAT ==
# [{:query => ['面', '点'],
#   :url => "http://google.com",
#   :doc => ['私は...', '点と面を結んで...']},
# ...]
result_web_contents = []

# クエリ単語
combination_words.each do |query|

  p query
  
  # 検索エンジンを使用して検索
  # 1引数目 => ページの番号
  urlList = yahoo_search.retrieve(1, query)   # 検索クエリで，1~10番目の検索結果のURLを取得

  # 検索結果ページへのアクセス 
  bodies = []

  urlList.each do |url| 
    begin
      http = web_client.open(url)                         # 実際にページにアクセス

      # 検索結果ページが有効でない場合，そのURLへのアクセスをスキップ
      if http == nil
        next
      end

      # 検索結果から本文らしい部分を抽出して表示
      encoded_contents = NKF.nkf("-w", http.read)         # 文字コード変換
      body =  ExtractContent::analyse(encoded_contents)    # 本文らしい部分を尤度計算して，抽出
      result_web_contents << { query: query, url: url, doc: body}
      
    rescue => e
      p e
      next
    end
  end
end

File.open("./data/web_retrival_result.json", "w") do |f|
  f.write(result_web_contents.to_json)
end

pp result_web_contents.size
