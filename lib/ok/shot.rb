#!/usr/bin/env ruby
# coding: utf-8

require 'optparse'
require 'set'
require 'readline'
require 'fileutils'

module OK
  module Shot
    class Error < StandardError; end
    extend self

    def main
      puts "Yes, it works!"
    end
  end
end

OK::Tags.main if $0 == __FILE__
