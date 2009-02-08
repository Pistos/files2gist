#!/usr/bin/env ruby

require 'net/http'
require 'uri'

def print_help_and_exit
  $stderr.puts "#{$0} [-p|--private] [--many] [--huge] <dir or file> [dir or file...]"
  exit 1
end

if ARGV.size < 1
  print_help_and_exit
end

files = []
priv = false
many = false
huge = false

ARGV.each do |arg|
  case arg
  when '-p', '--private'
    priv = true
  when '--many'
    many = true
  when '--huge'
    huge = true
  when '--help'
    print_help_and_exit
  else
    if File.file? arg
      files << arg
    elsif File.directory? arg
      files += Dir[ "#{arg}/**/*", "#{arg}/**/.*" ].find_all { |x| File.file? x }
    end
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

total_bytes = 0
files.each_with_index do |file,index|
  i = index + 1
  contents = File.read( file )
  total_bytes += contents.length
  data[ "files[#{file}]" ] = contents
end

if total_bytes > 32768 && ! huge
  $stderr.puts "#{total_bytes} bytes would be made into a gist!  Confirm with --huge."
  exit 3
end

res = Net::HTTP.post_form(
  URI.parse( 'http://gist.github.com/api/v1/xml/new' ),
  data
)
gist_id = res.body[ /<repo>(.+?)</m, 1 ]

puts res.body
puts
puts "http://gist.github.com/#{gist_id}"

