#!/usr/bin/env ruby
require 'test/unit'
require 'structfu.rb'

# Whee unit testing.
class IntStringTest < Test::Unit::TestCase
	include StructFu

	def test_intstring_len
		s = IntString.new(Int32, "hello!")
		assert_equal(s.len, s.int.v)
		assert_not_equal(s.len, s.length)
		s.len=10
		assert_equal(s.len, s[:int][:value])
	end

	def test_intstring_to_s
		s = IntString.new(Int16, "hello!")
		assert_equal("\x00\x06hello!",s.to_s)
		s.len=10
		assert_equal("\x00\x0ahello!",s.to_s)
		s = IntString.new(Int16, "hello!", :parse)
		s.len=10
		assert_equal("\x00\x0ahello!\x00\x00\x00\x00",s.to_s)
		s = IntString.new(Int16, "hello!", :fix)
		s.len=10
		assert_equal("\x00\x06hello!",s.to_s)
	end

	def test_intstring_new
		assert_equal("\x06Hello!",IntString.new(Int8,"Hello!").to_s)
		assert_equal("\x00\x06Hello!",IntString.new(Int16,"Hello!").to_s)
		assert_equal("\x06\x00\x00\x00Hello!",IntString.new(Int32le,"Hello!").to_s)
	end

	def test_intstring_error
		assert_raise(StandardError) { IntString.new("Hello!") }
		assert_raise(StandardError) { IntString.new(String,"Hello!") }
	end

	def test_intstring_read
		s = IntString.new
		s.read("\x06Hello!")
		assert_equal("Hello!", s.string)
		assert_equal("Hello!", s[:string])
		assert_equal(6, s.int.value)
		assert_equal(6, s.len)
	end

	def test_intstring_parse
		s = IntString.new
		s[:mode] = :parse
		s.parse("\x02Hello!")
		assert_equal("He", s.string)
		assert_equal(2, s.int.v)
		s.parse("\x0aHello!")
		assert_equal("Hello!\x00\x00\x00\x00", s.string)
		s[:mode] = :fix
		s.parse("\x0aHello!")
		assert_equal("Hello!", s.string)
	end

	def test_intstring_nocalc
		s = IntString.new
		s[:string] = "Hello"
		assert_equal(0,s.int.value)
	end

end

class IntTest < Test::Unit::TestCase
	include StructFu

	def test_int_to_s
		assert_equal("\x02",Int8.new(2).to_s) 
		assert_equal("\x00\x07",Int16.new(7).to_s) 
		assert_equal("\x00\x00\x00\x0a",Int32.new(10).to_s) 
	end

	def test_int_big
		assert_equal("\x00\x07",Int16be.new(7).to_s) 
		assert_equal("\x00\x00\x00\x0a",Int32be.new(10).to_s) 
	end

	def test_int_little
		assert_equal("\x07\x00",Int16le.new(7).to_s) 
		assert_equal("\x01\x04\x00\x00",Int32le.new(1025).to_s) 
	end

	def test_read
		assert_equal(Int16.new.read("\x00\x07"),7) 
		assert_equal(Int32.new.read("\x00\x00\x00\x0a"),10) 
		i = Int32.new
		i.read("\x00\x00\x00\xff")
		assert_equal(i.v, 255)
		assert_equal(Int16le.new.read("\x07\x00"),7) 
		assert_equal(Int32le.new.read("\x01\x04\x00\x00"),1025) 
		i = Int32le.new
		i.read("\xff\x00\x00\x00")
		assert_equal(i.v, 255)
	end

	def test_int_compare
		little = Int32le.new
		big = Int32be.new
		little.v = 128
		big.v = 0x80
		assert_not_equal(little.to_s, big.to_s)
		assert_equal(little.v, big.v)
		assert_equal(little[:value], big[:value])
		assert_equal(little.value, big.value)
	end

end

