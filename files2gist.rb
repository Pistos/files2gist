#!/usr/bin/env ruby

require 'net/http'
require 'cgi'
require 'uri'

files = []
priv = false

ARGV.each do |arg|
  if File.file? arg
    files << arg
  elsif File.directory? arg
    files += Dir[ "#{arg}/**/*", "#{arg}/**/.*" ].find_all { |x| File.file? x }
  elsif arg == '-p' || arg == '--private'
    priv = true
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
puts res.body
