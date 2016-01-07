#!/usr/bin/env ruby
# encoding: utf-8

# File: query.rb
# Created: 3/11/2014
#
# (c) Michel Demazure <michel@demazure.com>

# reopening base class
class String
  # fields in mysql answers are separated by tabs
  TAB = "\t"
  # @return [Array] sting split on tabs
  def split_on_tab
    chop.split(TAB)
  end
end

module JacintheManagement
  module Extender
    # MySQL queries
    class Query
      # @param [String] qry text of the query
      def initialize(qry)
        @query = qry
      end

      # @return [Array<string>] full answer to query
      def full_answer
        Sql.answer_to_query(JacintheManagement::JACINTHE_MODE, @query)
      end

      # send the query without caring for answer
      def send
        Sql.query(JacintheManagement::JACINTHE_MODE, @query)
      end

      # @return [Hash] full answer to query as a Hash of Hashes
      def full_table
        table = {}
        array = full_answer[1..-1]
        array.map(&:split_on_tab).each do |key, *value|
          table[key.to_i] = value
        end
        table
      end
    end
  end
end
