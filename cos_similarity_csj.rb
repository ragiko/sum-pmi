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

# == format == 
# [
#  [{:query=>"q1", :search_doc=> "doc1", :cos_similarity=>0.2},
#   {:query=>"q1", :search_doc=> "doc2", :cos_similarity=>0.5},
#   {..}..
#  ],
#  [{:query=>"q2", :search_doc=> "doc1", :cos_similarity=>0.2},
#  ...
#  ], 
#  ...
# ]
query_doc_cos_similarities = []

queries.each do |query|

  query_doc_cos_similarity = []

  search_docs.each do |search_doc|
    # pp "#{query['body']} #{query['sum_pmi_vector']}"
    # pp "#{search_doc['body']} #{search_doc['sum_pmi_vector']}"
    cos_similarity = calcCosineScale(query["sum_pmi_vector"], search_doc["sum_pmi_vector"])

    query_doc_cos_similarity << {
      query: query["body"],
      search_doc_name: search_doc["filename"],
      search_doc_contents: search_doc["body"],
      cos_similarity: cos_similarity
    }
  end

  query_doc_cos_similarities << query_doc_cos_similarity

end

pp query_doc_cos_similarities[0].sort!{ |a, b| a[:cos_similarity] <=> b[:cos_similarity] }


