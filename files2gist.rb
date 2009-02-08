#!/usr/bin/env ruby

require 'net/http'
require 'uri'

def print_help_and_exit
  $stderr.puts "#{$0} [-p|--private] [--many] <dir or file> [dir or file...]"
  exit 1
end

if ARGV.size < 1
  print_help_and_exit
end

files = []
priv = false
many = false

ARGV.each do |arg|
  if File.file? arg
    files << arg
  elsif File.directory? arg
    files += Dir[ "#{arg}/**/*", "#{arg}/**/.*" ].find_all { |x| File.file? x }
  elsif arg == '-p' || arg == '--private'
    priv = true
  elsif arg == '--many'
    many = true
  elsif arg == '--help'
    print_help_and_exit
  end
end

if files.size > 6 && ! many
  $stderr.puts "#{files.size} files would be made into a gist!  Confirm with --many."
  exit 2
end

data = {
  'login'   => `git config --global github.user`.strip,
  'token'   => `git config --global github.token`.strip,
}
if priv
  data[ 'private' ] = 'on'
end

files.each_with_index do |file,index|
  i = index + 1
  data[ "files[#{file}]" ] = File.read( file )
end
res = Net::HTTP.post_form(
  URI.parse( 'http://gist.github.com/api/v1/xml/new' ),
  data
)
gist_id = res.body[ /<repo>(.+?)</m, 1 ]

puts res.body
puts
puts "http://gist.github.com/#{gist_id}"

