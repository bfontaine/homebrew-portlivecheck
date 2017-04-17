# Brew-portlivecheck

## Ruby

```ruby
require "./lib/ports"

p = Ports.new("ports")
p.fetch! # optional

ruby20 = p["ruby20"]
puts "#{ruby20.name} version #{ruby20.version}"

puts "Available versions:"
ruby20.available_versions.sort.each do |version|
  puts "- #{version}"
end
```
