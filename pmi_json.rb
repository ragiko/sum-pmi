require "./rubyLib/pmi.rb"
require "pp"
require "json"

path = File.expand_path("./data/csjPMI.txt")
pmi = makePMIHash(path)

File.open("./data/pmi.json", "w") do |f|
  f.write(pmi.to_json)
end

