#!/usr/bin/env ruby
# encoding: utf-8

# File: finder.rb
# Created: 16/09/2014
#
# (c) Michel Demazure <michel@demazure.com>
module JacintheManagement
  # tools for free subscriptions management
  module Extender
    # @param [String] regexp client selection regexpp
    # @param [Integer] year year in 'yyyy' form
    # @return [Array<Abo>] list of all Abos found for this year
    def self.find_all(regexp, year)
      Finder.new(regexp, year).all
    end

    # @param [String] regexp client selection regexpp
    # @param [Integer] year year in 'yyyy' form
    # @return [Integer] number of Abos found for this year
    def self.count(regexp, year)
      Finder.new(regexp, year).count
    end

    # to extract all free 'abonnements' from the database
    class Finder
      attr_reader :year

      # @param [String] regexp client selection regexpp
      # @param [Integer|String] year year in 'yyyy' form
      def initialize(regexp, year)
        @year = year
        @regexp = regexp
      end

      # @return [String] mysql selection query
      def selection
        "abonnement where abonnement_client_sage REGEXP '#{@regexp}' \
 and abonnement_annee=#{@year} and abonnement_ignorer=0"
      end

      # @return [Integer] number of Abos found
      def count
        qry = "select count(*) from #{selection}"
        Query.new(qry).full_answer.last.chop.to_i
      end

      # @return [Array<String>] raw answer to selection query
      def raw
        qry = "select * from #{selection}"
        Query.new(qry).full_answer
      end

      # @return [Array<Abo>] list of all Abos found for this year
      def all
        list = raw.map(&:split_on_tab)
        return list if list.empty?
        keys = list.shift.map(&:to_sym)
        list.map { |line| Abo.build_from(keys, line) }
      end
    end
  end
end
