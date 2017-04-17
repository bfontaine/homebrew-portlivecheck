# -*- coding: UTF-8 -*-

require "net/http"
require "uri"

class Portfile
  attr_reader :path, :keys

  def initialize(path)
    @path = path
    @keys = {}
    parse!
  end

  def parse!
    # defaults
    # https://guide.macports.org/chunked/reference.phases.html
    @keys = {
      "extract.suffix" => ".tar.gz",
    }

    return unless File.file? @path
    File.readlines(@path).each do |line|
      line.chomp!
      # Empty lines
      next if line =~ /^\s*$/
      # Comments
      next if line =~ /^\s*#/

      # skip multiline stuff
      next if line =~ /\\$/

      # Note this doesn't handle well multi-lines values and conditionals
      ((key, value)) = line.scan(/^([\w\.]+)\s+(\S.*)$/)
      next if key.nil?
      @keys[key] = value

      # Special cases
      next unless value == "yes"
      extract_suffix = {
        "use_7z" => ".7z",
        "use_bzip2" => ".tar.bz2",
        "use_lzma" => ".lzma",
        "use_zip" => ".zip",
        "use_xz" => ".tar.xz",
      }[key]
      @keys["extract.suffix"] = extract_suffix unless extract_suffix.nil?
    end

    # Fill-in ${vars}
    @keys.each_pair do |k, v|
      v.gsub!(/\$\{([\w\.]+?)\}/) do |m|
        next m if k == "livecheck.regex" && $1 == "version"
        @keys[$1] || m
      end
    end
  end

  # strings
  %w[name version homepage revision description].each do |k|
    define_method(k.to_sym) { @keys[k] }
  end

  # strings lists
  %w[categories maintainers].each do |k|
    define_method(k.to_sym) { (@keys[k] || "").split }
  end

  def livecheck
    @livecheck ||= case @keys["livecheck.type"]
                   when "regex" then
                     {
                       :type => :regex,
                       :url => @keys["livecheck.url"] || @keys["homepage"],
                       :regex => livecheck_regex,
                     }
                   end
  end

  def run_livecheck
    return unless livecheck && livecheck[:url]
    begin
      content = Net::HTTP.get(URI.parse(livecheck[:url]))
      content.scan(livecheck[:regex]).map(&:first)
    rescue
      []
    end
  end

  def available_versions
    @available_versions ||= run_livecheck || []
  end

  def inspect
    %Q(<Portfile name="#{name}" version="#{version}">)
  end

  private

  def livecheck_regex
    subregexps = {
      "${version}" => ".+?",
      "${extract.suffix}" => "\.(?:7z|lzma|zip|tgz|tar\.(?:gz|xz|bz2))",
    }

    regexp = @keys["livecheck.regex"]
    return unless regexp

    regexp.gsub!(/^"|(?<!\\)"$/, "")

    regexp.gsub!("\\[", "[")
    regexp.gsub!("\\]", "]")
    regexp.gsub!(/\\\\/, "\\")

    subregexps.each_pair do |before, after|
      regexp.gsub! before, after
    end

    Regexp.new regexp
  end
end
