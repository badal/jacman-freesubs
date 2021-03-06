#!/usr/bin/env ruby
# encoding: utf-8

# File: builder.rb
# Created: 25/09/2014
#
# (c) Michel Demazure <michel@demazure.com>
module JacintheManagement
  module Extender
    # model methods for GUI
    class Builder
      def self.subtitle(state)
        case state
        when 0, 1
          'Aucune sélection'
        when 2
          'Extension des abonnements gratuits, mode simulé'
        when 3
          'Extension des abonnements gratuits, mode réel'
        when 4
          'Extension des abonnements d\'échange, mode simulé'
        when 5
          'Extension des abonnements d\'échange, mode réel'
        when 6
          'Extension des abonnements gratuits et d\'échange, mode simulé'
        when 7
          'Extension des abonnements gratuits et d\'échange, mode réel'
        end
      end

      def self.all(year, mode)
        new('GRATUIT|ECHANGE', year, mode)
      end

      def self.free(year, mode)
        new('GRATUIT', year, mode)
      end

      def self.exchange(year, mode)
        new('ECHANGE', year, mode)
      end

      def self.from_state(year, state)
        mode = state.odd?
        case state
        when 0, 1
          nil
        when 2, 3
          free(year, mode)
        when 4, 5
          exchange(year, mode)
        when 6, 7
          all(year, mode)
        end
      end

      attr_reader :extensible_abos, :names

      # @param [String] regexp client selection regexpp
      # @param [Integer] year year in 'yyyy' form
      # @param [Bool] mode whether extension has to be transmitted to DB
      def initialize(regexp, year, mode)
        @year = year
        @mode = mode
        cl = Extender.classifier(regexp, @year)
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
        list.reduce(0, :+)
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
