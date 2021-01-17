def get_command_line_argument
  # ARGV is an array that Ruby defines for us,
  # which contains all the arguments we passed to it
  # when invoking the script from the command line.
  # https://docs.ruby-lang.org/en/2.4.0/ARGF.html
  if ARGV.empty?
    puts "Usage: ruby lookup.rb <domain>"
    exit
  end
  ARGV.first
end

# `domain` contains the domain name we have to look up.
domain = get_command_line_argument

# File.readlines reads a file and returns an
# array of string, where each element is a line
# https://www.rubydoc.info/stdlib/core/IO:readlines
dns_raw = File.readlines("zone")

def parse_dns(dns_raw)
  dns_raw = dns_raw.reject { |line| line.strip.empty? or line.strip.start_with?("#") } #Removing lines starting with '#' and also empty lines

  dns_records = {}

  dns_raw.each do |line|
    record = line.split(",")

    key1 = record.shift.strip.to_sym   #key1 is the record type, either :A or :CNAME
    dns_records[key1] ||= {}
    key2 = record.shift.strip.to_sym  #key2 is the source domain
    dns_records[key1][key2] = record.first.strip
  end
  return dns_records
end

def resolve(dns_records, lookup_chain, domain)
  domain = domain.to_sym

  if dns_records[:A][domain] != nil # If domain is present in A record type
    lookup_chain.append(dns_records[:A][domain])
  elsif dns_records[:CNAME][domain] != nil # If domain is in CNAME record type
    lookup_chain.append(dns_records[:CNAME][domain])
    resolve(dns_records, lookup_chain, dns_records[:CNAME][domain])
  else
    lookup_chain.replace(["Error: record not found for #{lookup_chain.first}"])   # If domain is not present in both A and CNAME record type
  end
  return lookup_chain
end

# To complete the assignment, implement `parse_dns` and `resolve`.
# Remember to implement them above this line since in Ruby
# you can invoke a function only after it is defined.
dns_records = parse_dns(dns_raw)
lookup_chain = [domain]
lookup_chain = resolve(dns_records, lookup_chain, domain)
puts lookup_chain.join(" => ")
