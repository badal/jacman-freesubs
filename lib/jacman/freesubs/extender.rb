#!/usr/bin/env ruby
# encoding: utf-8

# File: extender.rb
# Created: 25/09/2014
#
# (c) Michel Demazure <michel@demazure.com>
module JacintheManagement
  module Freesubs
    # model methods for GUI
    class Extender
      attr_reader :extensible_abos, :names

      # @param [Integer|String] year year in 'yyyy' form
      # @param [Bool] mode whether extension has to be transmitted to DB
      def initialize(year, mode)
        @year = year
        @mode = mode
        cl = Freesubs.classifier(@year)
        @all_abos = cl.abos
        @names = cl.list_of_names
        update_extension_list
      end

      # update the list of extensible Abos
      # taking out those already extended
      def update_extension_list
        @extensible_abos = {}
        @all_abos.each_pair.map do |acronym, abos|
          @extensible_abos[acronym] = abos.reject(&:marked?)
        end
      end

      # @return [Array<Integer>] list of sizes of kinds, kind by kind
      def extensible_sizes
        @extensible_abos.values.map(&:size)
      end

      # @param [Array] selected_acronyms list of selected acronyms (default : all)
      # @return [Integer] total number of Abos
      def total_extensible_size(selected_acronyms = all_acronyms)
        list = @extensible_abos.each_pair.map do |key, value|
          selected_acronyms.include?(key) ? value.size : 0
        end
        list.reduce(:+)
      end

      # @return [Array<String>] all acronyms
      def all_acronyms
        @all_abos.keys
      end

      # key method : extend the selected kinds
      # @param [Object] selected_acronyms list of selected acronyms
      # @return [Integer] number of extended abos
      def extend_list(selected_acronyms)
        all = selected_acronyms.map { |acro| @extensible_abos[acro] }.flatten
        all.each do |abo|
          abo.extend_to_year!(@year + 1) if @mode
          abo.mark!
        end
        all.size
      end
    end
  end
end
