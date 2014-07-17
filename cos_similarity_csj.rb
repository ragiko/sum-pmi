#!/usr/bin/ruby
# -*- coding: utf-8 -*-

require "./rubyLib/vital.rb"
require "json"
require "pp"

# クエリのsum pmiを取得
json = File.open("./result/sum_pmi_for_query.json").read()
queries = JSON.parse(json)

# 検索対象文書のsum pmiを取得
json = File.open("./result/sum_pmi_for_search_document.json").read()
search_docs = JSON.parse(json)

# calcCosineScale
# クエリと検索対象文書のcos類似度を検索
queries.each do |query|
  
  search_docs.each do |search_doc|
    pp "#{query['body']} #{query['sum_pmi_vector']}"
    pp "#{search_doc['body']} #{search_doc['sum_pmi_vector']}"
    pp calcCosineScale(query["sum_pmi_vector"], search_doc["sum_pmi_vector"])
    break
  end

  break
end


