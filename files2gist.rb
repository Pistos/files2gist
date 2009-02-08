#!/usr/bin/env ruby

require 'net/http'
require 'uri'

def print_help_and_exit
  puts "#{$0} <dir or file> [dir or file...]"
  exit 1
end

if ARGV.size < 1
  print_help_and_exit
end

files = []
priv = false

ARGV.each do |arg|
  if File.file? arg
    files << arg
  elsif File.directory? arg
    files += Dir[ "#{arg}/**/*", "#{arg}/**/.*" ].find_all { |x| File.file? x }
  elsif arg == '-p' || arg == '--private'
    priv = true
  elsif arg == '--help'
    print_help_and_exit
  end
end

data = Hash.new
files.each_with_index do |file,index|
  i = index + 1
  data[ "files[#{file}]" ] = File.read( file )
end
res = Net::HTTP.post_form(
  URI.parse( 'http://gist.github.com/api/v1/xml/new'),
  data
)
gist_id = res.body[ /<repo>(\d+)</m, 1 ]
puts "http://gist.github.com/#{gist_id}"

