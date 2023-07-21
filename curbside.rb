require 'active_support'
require 'active_support/core_ext'
require 'nokogiri'
require 'open-uri'

def get_flavors_for(document, type)
  header_node = document.search("h2:contains('#{type}')").first
  
  if type == 'Soft Serve'
    dairy = header_node.next_element.children.map(&:text)
    vegan = header_node.next_element.next_element.children.map(&:text)

    [*dairy, *vegan]
  else
    header_node.next_element.children.map(&:text)
  end
end

def print_error_and_exit(error_message)
  puts "Error: #{error_message}"
  puts
  puts "Usage: curbside [type] (query)"
  puts "Example: curbside scoops | curbside sandwiches vanilla"
  puts "As of June 2022, available types are: soft_serve, scoops, sandwiches, pie, toppings, cones"
  exit 1
end

menu_html = URI.open("https://www.curbsideoakland.com/menu").read

document = Nokogiri::HTML(menu_html)

case ARGV.length
when 0
  print_error_and_exit("no type specified")
when 1
  flavors = get_flavors_for(document, ARGV[0].titleize)
  flavors.each {|flavor| puts "- #{flavor}" }
when 2
  flavors = get_flavors_for(document, ARGV[0].titleize)
  matching_flavors = flavors.select {|flavor| flavor.downcase.include?(ARGV[1].downcase)}
  if matching_flavors.any?
    puts "Yay! The following flavors matched your query:"
    matching_flavors.each {|flavor| puts "- #{flavor}" }
  else
    puts "No #{ARGV[0]} matching #{ARGV[1]} found :("
  end
else
  print_error_and_exit("too many arguments")
end



