#!/usr/bin/env ruby

require 'rubygems'
require 'bundler/setup'
require 'nokogiri'
require 'json'

def get_section_header_text(section_header)
  sh = section_header.dup
  sn = sh.css('.header-section-number')[0]
  sn.remove if sn
  sh.text.strip
end

def cleanup_section_id(section_id)
  section_id.to_s.gsub('sec:', '')
end

def get_toc_section_number_or_id(link)
  toc_sn = link.css('.toc-section-number')
  if toc_sn[0]
    return toc_sn[0].text
  else
    return cleanup_section_id(link.attribute('href').to_s.gsub('#', ''))
  end
end

def get_section_number_or_id(section)
  section_number_el = section.css('.header-section-number')[0]
  if section_number_el
    return section_number_el.text
  else
    return cleanup_section_id(section.attribute('id'))
  end
end

raise Exception.new("#{ARGV[1]} is not a directory") unless File.directory?(ARGV[1])
doc = File.open(ARGV[0]) { |f| Nokogiri::HTML(f) }

toc = doc.css("#TOC")
toc_links = toc.css('a')

toc_lookup = {}
toc.css('.toc-section-number').each_with_index do |sn, i|
  toc_lookup[sn.text] = i + 1
end

url_to_section_number = {}
section_data = {}

# Deal with References first to make it its own page.
references = doc.css("#refs")[0]
File.write(File.join(ARGV[1], "references.en.html.erb"), references.to_s)
section_data["references"] = {
  path: "references",
  header: "References",
  next_page: nil,
  prev_page: nil,
  hierarchy: [],
}
url_to_section_number["references"] = "references"
references.remove

# Extract sections from HTML document. Extract deepest nested sections first.
levels = [4, 3, 2, 1]
levels.each do |level|
  doc.css(".section.level#{level}").each do |section|
    section_id = cleanup_section_id(section.attribute('id'))
    section_header = section.css('h1, h2, h3, h4, h5, h6')[0]
    section_header_text = get_section_header_text(section_header)
    section_number = get_section_number_or_id(section)
    section_ancestors = section.ancestors('.section')
    hierarchy = section_ancestors.map {|s| cleanup_section_id(s.attribute('id').to_s) }.reverse
    hierarchy_section_numbers = section_ancestors.map {|s| get_section_number_or_id(s) }.reverse


    path = File.join(ARGV[1], hierarchy)
    FileUtils.mkdir_p(path)
    File.write(File.join(path, "#{section_id}.en.html.erb"), section.to_s)

    next_page = prev_page = nil
    toc_links.each_with_index do |link, i|
      if get_toc_section_number_or_id(link) == section_number
        prev_page = get_toc_section_number_or_id(toc_links[i-1]) if i > 0
        if i + 1 < toc_links.length
          next_page = get_toc_section_number_or_id(toc_links[i+1])
        else
          next_page = 'references'
          section_data["references"][:prev_page] = get_toc_section_number_or_id(link)
        end
      end
    end

    url_path = File.join(hierarchy + [section_id])
    url_to_section_number[url_path] = section_number

    section_data[section_number] = {
      path: url_path,
      header: section_header_text,
      next_page: next_page,
      prev_page: prev_page,
      hierarchy: hierarchy_section_numbers,
    }

    # Remove section so that it won't be included with its parent sections.
    section.remove
  end
end
data = {
  url_to_section_number: url_to_section_number,
  section_data: section_data,
}
print data.to_json
