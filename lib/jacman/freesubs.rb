#!/usr/bin/env ruby
# encoding: utf-8
#
# File: freesubs.rb
# Created: 25 november 2014
#
# (c) Michel Demazure <michel@demazure.com>

require_relative 'config.rb'

require_relative 'freesubs/abo.rb'
require_relative 'freesubs/classifier.rb'
require_relative 'freesubs/extender.rb'
require_relative 'freesubs/finder.rb'
require_relative 'freesubs/query.rb'
require_relative 'freesubs/version.rb'

module JacintheManagement
  # tools for free subscriptions management
  module Freesubs
    HELP_FILE = File.join(File.dirname(__FILE__), '..', '..', 'help/help.pdf')
    CONFIG_FILE = File.join(File.dirname(__FILE__), 'config.rb')
  end
end
