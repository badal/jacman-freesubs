#!/usr/bin/env ruby
# encoding: utf-8

# File: abo.rb
# Created: 16/09/2014
#
# (c) Michel Demazure <michel@demazure.com>

# reopening base class
class Fixnum
  # @return [String] the last two digits
  def two_digits
    format('%02d', self % 100)
  end
end

module JacintheManagement
  module Extender
    # an Abo is a sub_hash of an 'abonnement' record of Jacinthe
    class Abo < ::Hash
      # keys to build the new Abo
      KEYS_TO_BUILD = [:abonnement_client_sage, :abonnement_annee,
                       :abonnement_revue, :abonnement_type,
                       :abonnement_remarque, :abonnement_nbre,
                       :abonnement_reference_commande]

      # same, preceded by the id field
      KEYS = [:abonnement_id] + KEYS_TO_BUILD

      # types of the preceding keys
      TYPES_OF_KEYS = [:int, :varchar, :int, :int, :int, :varchar, :int, :varchar]

      # those keys whose values are to be copied to the extended Abo
      KEYS_TO_COPY = [:abonnement_client_sage, :abonnement_revue,
                      :abonnement_type, :abonnement_remarque, :abonnement_nbre]

      # the ref key whose value characterize free subscriptions
      REF = :abonnement_reference_commande

      # the year key
      ANNEE = :abonnement_annee

      # @param [Symbol] key field key
      # @param [String] value field value
      # @return [Integer|String] typed value
      def self.normalize(key, value)
        idx = KEYS.index(key)
        (idx && TYPES_OF_KEYS[idx] == :int) ? value.to_i : value
      end

      # build a new Abo, using params for KEY_TO_BUILD values
      #
      # @param [Hash] params parameters
      # @return [Abo] new Abo
      def self.build(params = {})
        abo = new
        KEYS_TO_BUILD.each do |key|
          abo[key] = params.key?(key) ? params[key] : 'NULL'
        end
        abo
      end

      # build a new Abo, using params for KEY_TO_BUILD values,
      # for the specified year and with the specified REF field
      #
      # @param [Hash] params parameters
      # @param [String] reference value of REF field
      # @param [String] year value of ANNEE field
      # @return [Abo] new Abo
      def self.build_special(reference, params, year)
        abo = build(params)
        abo[ANNEE] = year
        abo[REF] = reference
        abo
      end

      # build a new 'gratuit' Abo, using params for KEY_TO_BUILD values,
      # for the specified year
      #
      # @param [String] year value of ANNEE field
      # @param [Hash] params parameters
      # @return [Abo] new Abo
      def self.gratuit(year, params = {})
        build_special("Abo#{year.two_digits}-GT", params, year)
      end

      # build a new 'echange' Abo, using params for KEY_TO_BUILD values,
      # for the specified year
      #
      # @param [String] year value of ANNEE field
      # @param [Hash] params parameters
      # @return [Abo] new Abo
      def self.echange(year, params = {})
        build_special("Abo#{year.two_digits}-Ech", params, year)
      end

      # build a full Abo from keys and values :
      # used by Finder to extract Abos from the database
      #
      # @param [Array<Symbol>] keys list of keys
      # @param [Array<String>] values lits of values
      # @return [Abo] new abo
      def self.build_from(keys, values)
        params = {}
        keys.zip(values).each do |key, value|
          params[key] = normalize(key, value)
        end
        abo = build(params)
        abo[:abonnement_id] = params[:abonnement_id]
        abo
      end

      # @return [Symbol] type of Abo
      def type
        case self[:abonnement_client_sage]
        when /GRATUIT/
          :gratuit
        when /ECHANGE/
          :echange
        else
          :build
        end
      end

      # @param [String] new_year year to extend the given Abo
      # @return [Abo] extended Abo
      def extended_to(new_year)
        Abo.send(type, new_year, self)
      end

      # @return [Array<Integer|String>] array of typed values
      def values_to_insert
        values.map do |value|
          value.is_a?(Fixnum) ? value : "'#{value}'"
        end
      end

      # @return [String] MySql insertion query for this Abo
      def insertion_query
        "INSERT IGNORE INTO abonnement (#{KEYS_TO_BUILD.join(', ')})\
 VALUES (#{values_to_insert.join(', ')})"
      end

      # specific marker for extended 'abonnement' to prevent new extension
      NO_EXT = 'NOEXT'

      # @return [String] MySql query to mark the inserted 'abonnement' as already extended
      def mark_query
        id = self[:abonnement_id]
        "UPDATE abonnement SET abonnement_remarque = '#{modified_remark}'\
 where abonnement_id = #{id}"
      end

      # @return [String] cached 'abonnement_remarque' value modified by marking
      def modified_remark
        @modified_remark || build_modified_remark
      end

      # @return [String] 'abonnement_remarque' value modified by marking
      def build_modified_remark
        old_remark = self[:abonnement_remarque]
        @modified_remark = if old_remark && old_remark != 'NULL'
                             "#{old_remark}:#{NO_EXT}"
                           else
                             NO_EXT
                           end
      end

      # mark this Abo
      def mark!
        self[:abonnement_remarque] = modified_remark
      end

      # @return [Bool] whether this Abo is marked
      def marked?
        self[:abonnement_remarque].include?(NO_EXT)
      end

      # do insert the extended 'abonnement', marking the Abo and the initial 'abonnement'
      # @param [String] new_year year to extend the abo to
      def extend_to_year!(new_year)
        Query.new(extended_to(new_year).insertion_query).send
        Query.new(mark_query).send
      end
    end
  end
end
