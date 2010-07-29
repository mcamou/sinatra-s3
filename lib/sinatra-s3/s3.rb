require 'rubygems'
require 'activerecord'

require 'sinatra/base'
require 'openssl'
require 'digest/sha1'
require 'md5'
require 'haml'

begin
  require "git"
  puts "-- Git support found, versioning support enabled." if $VERBOSE
rescue LoadError
  puts "-- Git support not found, versioning support disabled."
end

begin
  require 'exifr'
  puts "-- EXIFR found, JPEG metadata enabled." if $VERBOSE
rescue LoadError
  puts "-- EXIFR not found, JPEG metadata disabled."
end

begin
  require 'rubytorrent'
  puts "-- RubyTorrent support found, bittorrent support enabled." if $VERBOSE
rescue LoadError
  puts "-- RubyTorrent support not found, bittorrent support disabled."
end

module S3
  VERSION = "0.98"
  DEFAULT_PASSWORD = 'pass@word1'

  BUFSIZE = (4 * 1024)
  ROOT_DIR = File.expand_path(File.join(File.dirname(__FILE__), '..', '..'))
  PUBLIC_PATH = File.join(ROOT_DIR, 'public')
  STORAGE_PATH = File.expand_path('storage') unless defined?(STORAGE_PATH)
  RESOURCE_TYPES = %w[acl versioning torrent]
  CANNED_ACLS = {
    'private' => 0600,
    'public-read' => 0644,
    'public-read-write' => 0666,
    'authenticated-read' => 0640,
    'authenticated-read-write' => 0660
  }
  READABLE = 0004
  WRITABLE = 0002
  READABLE_BY_AUTH = 0040
  WRITABLE_BY_AUTH = 0020

  POST = %{if(!this.title||confirm(this.title+'?')){var f = document.createElement('form'); this.parentNode.appendChild(f); f.method = 'POST'; f.action = this.href; f.submit();}return false;}
  POPUP = %{window.open(this.href,'changelog','height=600,width=500,scrollbars=1');return false;}
end

%w(bit bucket git_bucket slot user file_info torrent torrent_peer).each {|r| require "#{File.dirname(__FILE__)}/models/#{r}" }
%w(ext helpers errors admin base tracker).each {|r| require "#{File.dirname(__FILE__)}/#{r}"}