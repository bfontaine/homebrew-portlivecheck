#! /usr/bin/env ruby
# -*- coding: UTF-8 -*-

$:.unshift "#{__dir__}/../lib"

require "ports"

ports = Ports.new("#{__dir__}/../ports")

ARGV.named.each do |name|
  port = ports[name]
  next onoe "No available port with the name \"#{name}\"" if port.nil?

  puts <<-EOS.undent
    #{port.name}: stable #{port.version}
    #{port.description}
    #{port.homepage}

  EOS
end
