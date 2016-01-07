#!/usr/bin/env ruby
# encoding: utf-8

# File: classify.rb
# Created: 18/09/2014
#
# (c) Michel Demazure <michel@demazure.com>

module JacintheManagement
  # tools for free subscriptions management
  module Extender
    # @param [String] regexp client selection regexpp
    # @param [Integer|String] year year in 'yyyy' form
    # @return [Classifier] filled Classifier for this year
    def self.classifier(regexp, year)
      array = Extender.find_all(regexp, year)
      Classifier.new.classify(array)
    end

    # A Classifier produces Abos and subscription names ordered in Hashes
    # Keys of Hashes are acronyms for the 'abonnement' kinds : 'revue' + 'type'
    # Acronyms and names for 'revues' and 'types' are extracted from the base
    #
    class Classifier
      attr_reader :names, :abos

      def initialize
        @revues = Query.new('select * from revue;').full_table
        @types = Query.new('select * from type_abonnement;').full_table
        @names = {}
        @abos = {}
      end

      # WARNING: build names and acronyms only for found abos
      # and not for all couples revue/type !
      # @return [String] acronym for this kind of 'abonnement'
      def acronym_for(revue, type)
        r_acro, r_name, = *revue
        t_acro, t_name = *type
        acro = [r_acro, t_acro].join('/')
        name = [r_name, t_name].join(' ')
        @names[acro] ||= name
        acro
      end

      # @param [Abo] abo selected Abo
      # @return [String] acronym for the type of this Abo
      def acronym(abo)
        revue = @revues[abo[:abonnement_revue]]
        type = @types[abo[:abonnement_type]]
        acronym_for(revue, type)
      end

      # @param [Array<Hashes>] array list of Abos produced by the Finder
      # @return [Classifier] self with all Abos inside, classified by kind
      def classify(array)
        @abos.clear
        array.each do |abo|
          (@abos[acronym(abo)] ||= []) << abo
        end
        self
      end

      # @return [Integer] tital number of Abos
      def total_size
        @abos.values.map(&:size).reduce(:+)
      end

      # @return [Array<String>] list of kind names for GUI
      def list_of_names
        @abos.keys.map { |sigle| names[sigle] }
      end

      # format
      FMT = '| %4s |%4d |%-50s|'
      # format
      LINE = '- ' * 65

      # @return [Array<String>] classifying table for console output
      def table_to_print
        table = @abos.each_pair.map do |sigle, abos|
          [sigle, abos.size, names[sigle]]
        end
        interior = table.map { |line| format(FMT, *line) }
        total = format(FMT, nil, total_size, 'Total', nil)
        [LINE] + interior + [LINE] + [total] + [LINE]
      end
    end
  end
end
