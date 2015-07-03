#!/usr/bin/env ruby
# encoding: utf-8

# File: file_utilities_spec.rb
# Created: 13/08/13
#
# (c) Michel Demazure <michel@demazure.com>

require_relative 'spec_helper.rb'
require_relative '../lib/jacman/freesubs/abo.rb'

include JacintheManagement::Freesubs

describe Abo do
  it 'builds empty abos' do
    abo = Abo.build
    empty = { abonnement_client_sage: 'NULL', abonnement_annee: 'NULL',
              abonnement_revue: 'NULL', abonnement_type: 'NULL',
              abonnement_remarque: 'NULL', abonnement_nbre: 'NULL',
              abonnement_reference_commande: 'NULL' }
    abo.must_equal empty
  end

  it 'builds empty gratuits' do
    abo = Abo.gratuit(2000)
    empty = { abonnement_client_sage: 'NULL', abonnement_annee: 2000,
              abonnement_revue: 'NULL', abonnement_type: 'NULL',
              abonnement_remarque: 'NULL', abonnement_nbre: 'NULL',
              abonnement_reference_commande: 'Abo00-GT' }
    abo.must_equal empty
  end

  it 'builds empty echanges' do
    abo = Abo.echange(2000)
    empty = { abonnement_client_sage: 'NULL', abonnement_annee: 2000,
              abonnement_revue: 'NULL', abonnement_type: 'NULL',
              abonnement_remarque: 'NULL', abonnement_nbre: 'NULL',
              abonnement_reference_commande: 'Abo00-Ech' }
    abo.must_equal empty
  end

  it 'builds full gratuits' do
    built = Abo.gratuit(2014,  abonnement_client_sage: '7291GRATUIT',
                               abonnement_revue: 14, abonnement_type: 1,
                               abonnement_remarque: 'NM', abonnement_nbre: 1)
    answer = { abonnement_client_sage: '7291GRATUIT', abonnement_annee: 2014,
               abonnement_revue: 14, abonnement_type: 1,
               abonnement_remarque: 'NM', abonnement_nbre: 1,
               abonnement_reference_commande: 'Abo14-GT' }
    built.must_equal answer
  end

  it 'extends gratuits' do
    old = Abo.gratuit(2014,  abonnement_client_sage: '7291GRATUIT',
                             abonnement_revue: 14, abonnement_type: 1,
                             abonnement_remarque: 'NM', abonnement_nbre: 1)
    new = Abo.gratuit(2015,  abonnement_client_sage: '7291GRATUIT',
                             abonnement_revue: 14, abonnement_type: 1,
                             abonnement_remarque: 'NM', abonnement_nbre: 1)
    old.extended_to(2015).must_equal new
  end

  it 'marks gratuits without remark' do
    old = Abo.gratuit(2014,  abonnement_client_sage: '7291GRATUIT',
                             abonnement_revue: 14, abonnement_type: 1,
                             abonnement_remarque: 'NULL', abonnement_nbre: 1)
    old.marked?.must_equal false
    old.mark!
    assert(old.marked?)
    marked = Abo.gratuit(2014,  abonnement_client_sage: '7291GRATUIT',
                                abonnement_revue: 14, abonnement_type: 1,
                                abonnement_remarque: 'NOEXT',
                                abonnement_nbre: 1)
    old.must_equal marked
  end

  it 'marks gratuits with remark' do
    old = Abo.gratuit(2014,  abonnement_client_sage: '7291GRATUIT',
                             abonnement_revue: 14, abonnement_type: 1,
                             abonnement_remarque: 'NM', abonnement_nbre: 1)
    old.marked?.must_equal false
    old.mark!
    assert(old.marked?)
    marked = Abo.gratuit(2014,  abonnement_client_sage: '7291GRATUIT',
                                abonnement_revue: 14, abonnement_type: 1,
                                abonnement_remarque: 'NM:NOEXT',
                                abonnement_nbre: 1)
    old.must_equal marked
  end

  it 'extends echanges' do
    old = Abo.echange(2014,  abonnement_client_sage: '7291ECHANGE',
                             abonnement_revue: 14, abonnement_type: 1,
                             abonnement_remarque: 'NM', abonnement_nbre: 1)
    new = Abo.echange(2015,  abonnement_client_sage: '7291ECHANGE',
                             abonnement_revue: 14, abonnement_type: 1,
                             abonnement_remarque: 'NM', abonnement_nbre: 1)
    old.extended_to(2015).must_equal new
  end

  it 'builds insertion queries' do
    abo = Abo.gratuit(2014,  abonnement_client_sage: '7291GRATUIT',
                             abonnement_revue: 14, abonnement_type: 1,
                             abonnement_remarque: 'NM', abonnement_nbre: 1)
    qry = "INSERT IGNORE INTO abonnement \
(abonnement_client_sage, abonnement_annee, abonnement_revue, abonnement_type, \
abonnement_remarque, abonnement_nbre, \
abonnement_reference_commande)\
 VALUES ('7291GRATUIT', 2014, 14, 1, 'NM', 1, 'Abo14-GT')"
    abo.insertion_query.must_equal qry
  end
end
