#! /usr/bin/env ruby
# -*- coding: UTF-8 -*-

$:.unshift "#{__dir__}/lib"

require "ports"

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
