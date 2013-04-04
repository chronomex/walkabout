#!/usr/bin/ruby

require 'nokogiri'

def fetch_nodes(osm)
  # all nodes that have as children a tag starting with addr:
  osm.xpath("//node/tag[starts-with(@k,'addr:')]/.. | //way/tag[starts-with(@k,'addr:')]/..").each { |node|
    name = node.xpath("./tag[@k='name']/@v").inner_text
    house = node.xpath("./tag[@k='addr:housenumber']/@v").inner_text
    street = node.xpath("./tag[@k='addr:street']/@v").inner_text
    nodenr = node['id']
    yield [house, street, name, nodenr]
  }
end

doc = Nokogiri::XML(open('caphill_20130331.osm'))

places = {}

fetch_nodes(doc) { |house, street, name, nodenr|
#  print "#{house} - #{street}: #{name} = #{nodenr}\n"
  if places[street] == nil then
    places[street] = {}
  end

  if places[street][house] == nil then
    places[street][house] = []
  end

  places[street][house].push({:name => name, :nodenr => nodenr})
}

places.keys.sort.each {|street|
  print "\\street{#{street}}\n"
  places[street].keys.sort_by{|k| k.to_i}.each {|house|
    places[street][house].each {|node|
      print "\\house{#{house}}{#{node[:name]}}{#{node[:nodenr]}}\n".sub('&', '\\\\&')
    }
  }
}
