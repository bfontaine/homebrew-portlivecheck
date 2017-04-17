#! /usr/bin/env ruby
# -*- coding: UTF-8 -*-

$:.unshift "#{__dir__}/lib"

require "set"
require "ports"

module PortLiveCheck
  class << self
    def ports
      @ports ||= Ports.new("ports")
    end

    def run
      port_names = Set.new ports.all_names
      ohai "Found #{port_names.count} ports"

      formula_names = Set.new Formula.names

      ohai "Found #{formula_names.count} formulae"

      # Simple match
      ports_formulae = port_names & formula_names
      ohai "Found ~#{ports_formulae.count} ports that are also formulae"
      ports_formulae.each do |name|
        port = @ports[name]
        formula = Formula[name]

        next unless formula.version.detected_from_url?

        new_versions = port.available_versions.uniq.select do |s|
          Version.new(s) > formula.version
        end

        unless new_versions.empty?
          ohai "#{name} (formula version #{formula.version})"
          puts "New versions: #{new_versions * ", "}."
        end
      end
    end
  end
end

PortLiveCheck.run
