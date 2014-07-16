#! /usr/bin/ruby
#coding: utf-8

module FileUtil
	module_function
	
  ## 
  # ファイル内部の文章群を取得(出力:配列)
  # [{:filename1 => body1, :filename2 => body2}]
  ##
  def get_file_contents(path)

    file_path = path + "/*"
    file_contents = []
    filename = ""
    body = ""

    Dir.glob(file_path) do |file|
      # ulimit -n 1024 で一度に開けるファイルを変える
      filename = File.expand_path(file)

      if File.directory?(file) == false
        body = File.open(file, "r").read()
      end

      file_contents << { filename: filename, body: body }
    end

    file_contents
  end
end
