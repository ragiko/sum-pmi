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


## 
# SUM PMIの負の値を除く 
## 
queries.each do |h|
  h["sum_pmi_vector"] = h["sum_pmi_vector"].delete_if {|key, val| val < 0 }
end

search_docs.each do |h|
  h["sum_pmi_vector"] = h["sum_pmi_vector"].delete_if {|key, val| val < 0 }
end

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
    
    #query["sum_pmi_vector"].each_pair do |k, v|
    #  query["sum_pmi_vector"][k] = v * idf[k]
    #end

    #search_doc["sum_pmi_vector"].each_pair do |k, v|
    #  search_doc["sum_pmi_vector"][k] = v * idf[k]
    #end

    #abort "############################################################"

    cos_similarity = calcCosineScale(query["sum_pmi_vector"], search_doc["sum_pmi_vector"])

    query_doc_cos_similarity << {
      query: query["body"],
      search_doc_name: search_doc["filename"],
      search_doc_contents: search_doc["body"],
      cos_similarity: cos_similarity,
      query_sum_pmi: query["sum_pmi_vector"],
      search_doc_sum_pmi: search_doc["sum_pmi_vector"]
    }
  end

  query_doc_cos_similarities << query_doc_cos_similarity

end

# queries.each_with_index do |query, i|
#   puts "########################################################"
#   puts "# QUERY #{i+1}"
#   puts "########################################################"
#   pp query["body"]
#   pp query["sum_pmi_vector"].sort{ |a, b| b[1] <=> a[1]  }
#   puts ""
#   puts ""
# end

MAX_SORT_DOCS = 5

puts "########################################################"
puts "# QUERY 1"
puts "########################################################"
sort =  query_doc_cos_similarities[0].sort!{ |a, b| b[:cos_similarity] <=> a[:cos_similarity]  }
pp sort[0..MAX_SORT_DOCS]
puts ""
puts ""

abort




puts "########################################################"
puts "# QUERY 2"
puts "########################################################"
sort =  query_doc_cos_similarities[1].sort!{ |a, b| b[:cos_similarity] <=> a[:cos_similarity]  }
pp sort[0..MAX_SORT_DOCS]
puts ""
puts ""

puts "########################################################"
puts "# QUERY 3"
puts "########################################################"
sort =  query_doc_cos_similarities[2].sort!{ |a, b| b[:cos_similarity] <=> a[:cos_similarity]  }
pp sort[0..10]
puts ""
puts ""

puts "########################################################"
puts "# QUERY 4"
puts "########################################################"
sort =  query_doc_cos_similarities[3].sort!{ |a, b| b[:cos_similarity] <=> a[:cos_similarity]  }
pp sort[0..10]
puts ""
puts ""


puts "########################################################"
puts "# QUERY 5"
puts "########################################################"
sort =  query_doc_cos_similarities[4].sort!{ |a, b| b[:cos_similarity] <=> a[:cos_similarity]  }
pp sort[0..10]
puts ""
puts ""


