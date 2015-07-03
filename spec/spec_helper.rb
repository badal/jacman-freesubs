#!/usr/bin/env ruby
# encoding: utf-8
#
# File: spec_helper.rb
# Created: 16 September 2014
#
# (c) Michel Demazure <michel@demazure.com>

require 'minitest/spec'
require 'minitest/autorun'

if __FILE__ == $PROGRAM_NAME

  Dir.glob('**/*_spec.rb') { |f| require_relative f }

end
