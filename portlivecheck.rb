#! /usr/bin/env ruby
# -*- coding: UTF-8 -*-

class Portfile
  def initialize(path)
    @path = path
    @keys = {}
    parse!
  end

  def parse!
    return unless File.file? @path
    File.readlines(@path).each do |line|
      line.chomp!
      # Empty lines
      next if line =~ /^\s*$/
      # Comments
      next if line =~ /^\s*#/

      ((key, value)) = line.scan(/^(\w+)\s+(\S.*)$/)
      @keys[key] = value unless key.nil?
    end

    @keys.each_value do |v|
      v.gsub!(/\$\{(\w+?)\}/) { |m| @keys[$1] || m }
    end
  end

  %w[name version revision description].each do |k|
    define_method(k.to_sym) { @keys[k] }
  end

  def categories
    @categories ||= (@keys["categories"] || "").split
  end

  def inspect
    %Q(<Portfile name="#{name}" version="#{version}">)
  end
end

class Ports
  def initialize(directory)
    @dir = directory
    @remote = "https://github.com/macports/macports-ports.git"
    fetch
  end

  def exists?
    File.directory? "#{@dir}/.git"
  end

  def fetch
    create unless exists?
    system "git", "-C", @dir, "pull"
  end

  def portfiles
    Dir["#{@dir}/*/*/Portfile"].map { |name| Portfile.new(name) }
  end

  private

  def create
    system "git", "clone", "--depth=1", @remote, @dir
  end
end

module PortLiveCheck
  class << self
    def ports
      @ports ||= Ports.new("ports")
    end

    def run
      ports
    end
  end
end

PortLiveCheck.run
