#!/usr/local/bin/genv ruby
require 'bio'
require 'optparse'


options = {}

OptionParser.new do |opts|
  opts.banner = "Usage: build_fasta.rb [options]"

  opts.on("-s", "--search-string STRING", "Search String") do |o|
    options[:search] = o
  end

  opts.on("-f", "--output-file FILE", "Output file") do |o|
    options[:file] = o
  end

  opts.on("-m", "--max-records MAX", Integer, "Max output records") do |o|
    options[:max] = o.to_i
  end

end.parse!

Bio::NCBI.default_email = "aaron.psamuel@gmail.com"
ncbi = Bio::NCBI::REST.new

seqs = ncbi.esearch("#{options[:search]}", { "db"=>"gene", "rettype"=>"gb", "retmax"=> options[:max]})

puts "Found #{seqs.length} Gene Records"

#build file
while (seqs.length > 1)
    seqslices = seqs.slice!(1..100)
    data = ncbi.efetch(seqslices, {"db"=>"gene", "rettype"=>"fasta", "retmax"=> options[:max]})
    data.gsub!("\n\n","\n")
    File.open(options[:file], 'a') {|f| f.write(data + "\n") }
end
