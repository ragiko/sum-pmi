#! /usr/bin/ruby
#coding: utf-8

require "MeCab"

class MeCabLib
	# Public: 		文章群の形態素解析
	# sentences - 文章群 ["文章1", "文章2", ...]
	# Returns 		[["word1_doc1", "word2_doc1"], ["word1_doc2", "word2_doc2"],...]	
	def analyze_sentences(sentences, opts={})
		words_of_docs = []
		sentences.each do |sentence|
			words_of_docs << analyze_sentence(sentence, opts)
		end
		words_of_docs
	end

	# Public: 		文章の形態素解析
	# sentence - 	文章(string)
	# opts - 			pos_list(形容詞のリスト)
	# 						stopword_list(ストップワードのリスト)
  #             is_filter(ノイズのフィルタリング)
	# Returns 		["我が輩", "猫", ...]	
  def analyze_sentence(sentence, opts={}) 
  	# 疑似キーワード引数
  	# http://tech.aktsk.jp/%E6%8A%80%E8%A1%93/20111025/28
  	# http://blog.aotak.me/post/39424868330/keyword-argument-for-ruby#sec2
		pos_list, stopword_list, is_filter = {
		  pos_list: ["名詞"],
		  stopword_list: [],
      is_filter: false,
		}.merge(opts).values

    mecb_obj = MeCab::Tagger.new("--node-format=%m,%f[0],%f[1]\\n --eos-format="" ")
    tokens_lines = mecb_obj.parse(sentence).split("\n")

    # Mecab Format
    # 表層形\t品詞,品詞細分類1,品詞細分類2,品詞細分類3,活用形,活用型,原形,読み,発音
    tokens = [] 
    tokens_lines.each do |line|
    	tokens_hs = Hash.new
    	tokens_arr = line.split(",")
    	tokens_hs[:word] 	= tokens_arr[0] unless tokens_arr[0].nil? #単語
    	tokens_hs[:pos]		= tokens_arr[1] unless tokens_arr[1].nil? #品詞
    	tokens_hs[:pos_detail1]	= tokens_arr[2] unless tokens_arr[2].nil? #品詞詳細1

    	# 品詞が一致していたら抽出
    	# pos_listが設定していなければ全て抽出
    	if pos_list.size == 0
    		tokens << tokens_hs
    	else
    		# include?
    		# http://ref.xaio.jp/ruby/classes/array/include
		  	tokens << tokens_hs if pos_list.include?(tokens_hs[:pos])
		  end
    end

    # 単語のみ抽出
    words = extract_words(tokens)

    # ストップワードで単語を削除
    words = delete_stopword(words, stopword_list)

    # ノイズを削除
    words = words_filter(words) if is_filter

    words
  end

	private
  # Public: 			ストップワードを削除
	# words - 			["我が輩", "猫", ...]	
	# stopword_list-["猫"]
	# Returns 			["我が輩", ...]	
  def delete_stopword(words, stopword_list)
  	# 別のインスタンス作成
  	# http://gam0022.net/blog/2013/02/09/ruby-variable/
  	result_words = words.dup
  	stopword_list.each do |stopword|
  		result_words.delete(stopword)
  	end
  	result_words
  end

  # Public		単語だけ抽出
  # tokens 		[{:word 猫, :pos　名詞, :pos_detail1 名詞}, {}..]
  # Returns 	["猫",""...]	
  def extract_words(tokens) 
  	words = []
  	tokens.each do |token|
  		words << token[:word]
		end
		words
  end 

  # Public    ノイズを削除
  # words     ["♪", "猫", ...] 
  # Returns   ["猫",""...] 
  def words_filter(words)
    result = []
    words.each do |word|
      # ひらがなカタカナ１文字, 記号のだけのものを削除
      if /^[ぁ-んァ-ン]$/ =~ word ||
        /^[a-zA-Z0-9]$/ =~ word ||
        /^[¥!-\/:-@\[-`{-~ﾉ『』♪♡ﾟ｡／‐，「」．～・ー一█”]*$/ =~ word ||
        /^[0-9０-９一二三四五六七八九]*$/ =~ word
      else
        result << word
      end
    end
    result
  end
end
