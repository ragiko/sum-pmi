#! /usr/bin/ruby
# coding: utf-8

require_relative "./mecab_lib.rb"
require_relative "./tfidf.rb"

module MeCabTFIDF
	module_function
	# Public			形態素解析してtfidfオブジェクトを計算
	# courpus			["文章1", "文章2"...]
	def mecab_tfidf(corpus)
		mecab = MeCabLib.new
		opt = {
			is_filter: 	true,
			pos_list: 	["名詞"],
		}
		words_docs = mecab.analyze_sentences(corpus, opt)
		tfidf = TFIDF.new(words_docs)
		tfidf
	end
end
