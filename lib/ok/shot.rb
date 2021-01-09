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

    def take_screenshot(flag)
      bin_dir = File.expand_path(File.join(%w[.. .. .. bin]), __FILE__)
      shell_script_path = File.join(bin_dir, "take_screenshot.sh -#{flag}")
      `#{shell_script_path}`
    end

    def main
      OptionParser.new do |opts|
        opts.banner = 'Usage: okshot [options]'
        opts.on(
          '-s',
          '--simple',
          'Take a screenshot without annotation and upload'
        ) do |c|
          take_screenshot('s')
          exit
        end
        opts.on(
          '-c',
          '--copy-clipboard',
          'Copy PNG file from clipboard and upload'
        ) do |c|
          take_screenshot('c')
          exit
        end
        opts.on(
          '-i',
          '--inkscape',
          'Use inkscape to edit the screenshot and upload'
        ) do |c|
          take_screenshot('i')
          exit
        end
      end.parse!
    end
  end
end

OK::Tags.main if $0 == __FILE__
