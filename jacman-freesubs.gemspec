#!/usr/bin/env ruby
# encoding: utf-8

dir = File.dirname(__FILE__)
$LOAD_PATH.unshift(dir) unless $LOAD_PATH.include?(dir)

require 'lib/jacman/freesubs/version.rb'

Gem::Specification.new do |s|
  s.name = 'jacman-freesubs'
  s.version = JacintheManagement:: Freesubs::VERSION
  s.has_rdoc = true
  s.extra_rdoc_files = ['README.md', 'LICENSE']
  s.summary = 'To be replaced'
  s.description = 'To be replaced'
  s.author = 'Michel Demazure'
  s.email = 'michel@demazure.com'
  # s.executables = ['your_executable_here']
  s.files = %w(LICENSE README.md HISTORY.md MANIFEST Rakefile) + Dir.glob('{bin,lib,spec}/**/*')
  s.require_path = 'lib'
  s.bindir = 'bin'
end
