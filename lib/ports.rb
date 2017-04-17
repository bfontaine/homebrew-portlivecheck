# -*- coding: UTF-8 -*-

require_relative "./portfile"

class Ports
  def initialize(directory)
    @dir = directory
    @remote = "https://github.com/macports/macports-ports.git"
    create unless exists?
  end

  def exists?
    File.directory? "#{@dir}/.git"
  end

  def fetch!
    system "git", "-C", @dir, "pull"
    @all_paths = nil
  end

  def [](name)
    path = Dir["#{@dir}/*/#{name}/Portfile"].first
    Portfile.new(path) if path && File.file?(path)
  end

  def all_paths
    @all_paths ||= Dir["#{@dir}/*/*/Portfile"]
  end

  def all_names
    all_paths.map { |path| path.split("/")[-2] }
  end

  def all
    all_paths.map { |path| Portfile.new(path) }
  end

  private

  def create
    system "git", "clone", "--depth=1", @remote, @dir
  end
end
