#!/usr/bin/env ruby

require 'test/unit'
require 'lib/lazyhash'

class TestLazyHash < Test::Unit::TestCase
  
  def test_symbol
    name = 'Igor'
    age = 41
    
    hash = Choice::LazyHash.new
    hash['name'] = name
    hash[:age] = age
   
    assert_equal name, hash[:name]
    assert_equal age, hash[:age]
  end
  
  def test_string
    name = "Frank Stein"
    age = 30
    
    hash = Choice::LazyHash.new
    hash[:name] = name
    hash['age'] = age
    
    assert_equal name, hash['name']
    assert_equal age, hash['age']
  end
  
  def test_store_and_fetch
    name = 'Topher James'
    job = 'Interior Decorator'
    
    hash = Choice::LazyHash.new
    hash.store('name', name)
    hash.store(:job, job)
    
    assert_equal name, hash.fetch(:name)
    assert_equal job, hash.fetch('job')
  end
  
end