#! /usr/bin/ruby
#coding: utf-8


class TFIDF

	# data - 		文章の単語群
	def initialize(data)
		@data = data
	end

	def tf 
		# @tf = calc_tf if @tf.nil?　と一緒
		@tf ||= calc_tf
	end

	def idf 
		@idf ||= calc_idf 
	end

	# This is basically calculated by multiplying tf by idf
  def tf_idf(set_idf=nil)
    tf_idf = tf.map(&:clone)
    # idfを設定
    use_idf = set_idf.nil? ? idf : set_idf

    tf.each_with_index do |document, index|
      document.each_pair do |term, tf_score|
      	# 構造がハッシュの配列であるため
        tf_idf[index][term] = tf_score * use_idf[term] unless use_idf[term].nil?
      end
    end
    
    tf_idf
  end

  private 

	# Returns all terms, once
  def terms
    @data.map(&:uniq).flatten
  end

  def total_documents
    @data.size.to_f
  end

	# sentenceは文章内容
  def calc_tf
    results = []

    @data.each do |document|
    	document_result = Hash.new {|h, k| h[k] = 0 }
    	document_size = document.size.to_f

    	# 頻度カウント
    	document.each do |term|
        document_result[term] += 1
      end

       # 正規化
      document_result.each_key do |term|
        document_result[term] /= document_size
      end

      results << document_result
    end

    results
  end

  def calc_idf
  	results = Hash.new {|h, k| h[k] = 0 }

    # 文書数が位置の場合 idfの値は全て1
    if total_documents == 1
      terms.each do |term|
        results[term] = 1
      end
    else 
      terms.each do |term|
        results[term] += 1
      end

      log_total_count = Math.log10(total_documents)
      results.each_pair do |term, count|
        results[term] = log_total_count - Math.log10(count)
      end
    end

    results.default = nil
    results
  end
end
