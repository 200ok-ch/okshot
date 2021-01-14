#!/usr/bin/env ruby
# coding: utf-8

require 'optparse'
require 'ostruct'
require 'set'
require 'readline'
require 'fileutils'

module OK
  module Shot
    class Error < StandardError; end
    extend self

    def take_screenshot(options)
      bin_dir = File.expand_path(File.join(%w[.. .. .. bin]), __FILE__)
      shell_script_path = File.join(bin_dir, "take_screenshot.sh -#{options.flag}")
      shell_script_path += " -C" if options.copy_to_clipboard
      `#{shell_script_path}`
    end

    def main
      options = OpenStruct.new
      OptionParser.new do |opts|
        opts.banner = 'Usage: okshot [options]'
        opts.on(
          '-C',
          '--copy-to-clipboard',
          'Copy PNG file from clipboard and upload'
        ) do |c|
          options.copy_to_clipboard = true
        end
        opts.on(
          '-s',
          '--simple',
          'Take a screenshot without annotation and upload. This is the default.'
        ) do |c|
          options.flag = 's'
        end
        opts.on(
          '-c',
          '--copy-from-clipboard',
          'Copy PNG file from clipboard and upload'
        ) do |c|
          options.flag = 'c'
        end
        opts.on(
          '-i',
          '--inkscape',
          'Use inkscape to edit the screenshot and upload'
        ) do |c|
          options.flag = 'i'
        end
      end.parse!

      options.flag = 's' unless options.flag
      take_screenshot(options)
    end
  end
end

OK::Tags.main if $0 == __FILE__
