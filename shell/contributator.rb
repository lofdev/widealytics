#!/usr/bin/env ruby

# contribulator.rb
# Dave Loftis 
# Twitter/ADN: @lofdev 
# Web: http://www.lofdev.com
# Use and modify freely, attribution appreciated
#
# Shell script to analyze Colorado political donation records for inclusion in a Neo4J DB.
#

# Include the gems needed
require 'rubygems'
require 'date'
require 'json'
require 'pry'
require 'csv'
require 'digest/md5'
require 'neography'

# Requirements for this software
require_relative './Model.rb'
require_relative './Employer.rb'
require_relative './Contributor.rb'
require_relative './Committee.rb'
require_relative './Contribution.rb'


input_filename = ARGV[0]
current_path = ENV['PWD']

#  Instance of Neography for connecting to Neo4J
NEO = Neography::Rest.new


#
#  Let's Memoize some shit, yo!
#
COMMITTEES = {}
EMPLOYERS = {}
CONTRIBUTORS = {}
CONTRIBUTIONS = []

#
#	Handler Functionality
#
def debugging?
	if ARGV[1] == 'debug' 
		true
	else
		false
	end
end

def parseLine(line)
	begin
		puts line if debugging?
		l = line.gsub('","', "~,~")
		l[0] = "~"
		l[-1] = "~"
		l = l.gsub('"',"*$*")
		l = l.gsub("~",'"')
		l = l.gsub('*$*',"'")
		l.parse_csv
	rescue ArgumentError
		false
	rescue CSV::MalformedCSVError
		false
	end
end

def contributorFromCsv(data)
	c = {
		"last_name" => data[3].to_s,
		"first_name" => data[4].to_s,
		"middle_initial" => data[5].to_s,
		"suffix" => data[6].to_s,
		"address_1" => data[7].to_s,
		"address_2" => data[8].to_s,
		"city" => data[9].to_s,
		"state" => data[10].to_s,
		"zip" => data[11].to_s,
		"type" => data[17].to_s
	}
	Contributor.newWithData(c)
end

def employerFromCsv(data) 
	c = {
		"name" => data[22].to_s,
		"occupation" => data[23].to_s
	}
  Employer.newWithData(c)
end

def contributionFromCsv(data)
	c = {
		'co_id' => data[0].to_s,
		'record_id' => data[13].to_s,
		'amount' => data[1].to_s,
		'date' => data[2].to_s,
		'type' => data[15].to_s,
		'electioneering' => data[18].to_s,
		'receipt_type' => data[16].to_s
	}
	Contribution.newWithData(c).serialize

end

def committeeFromCsv(data)
	c = {
		'type' => data[19].to_s,
		'name' => data[20].to_s,
		'candidate' => data[21].to_s
	}
  Committee.newWithData(c)

end

def parseAndStore(line) 
	
	parsed_line = parseLine(line)
	if parsed_line && parsed_line[0].to_s != 'CO_ID'
		contribution = contributionFromCsv(parsed_line)
		committee = committeeFromCsv(parsed_line)
		contributor = contributorFromCsv(parsed_line)
		employer = employerFromCsv(parsed_line)

		if debugging?
			puts "===========RECORD==========="
			puts contribution
			puts "TO:"
			puts committee
			puts "FROM:"
			puts contributor
			puts employer
    end

    NEO.create_relationship('employed_by', contributor, employer)
    donation_relationship = NEO.create_relationship('donated_to', contributor, committee)
    NEO.set_relationship_properties(donation_relationship, contribution)

	end

end

def parseFile(path) 
	x = 0
	flines = IO.readlines(path)
	len = flines.length
	flines.each do |line| 
		parseAndStore(line.to_s)
		x += 1
		puts "Processing line #{x}/#{len}" unless debugging?
	end

	# Final report on the progress of the script
	puts "Contributions: #{CONTRIBUTIONS.length}"
	puts "Committees: #{COMMITTEES.length}"
	puts "Contributors: #{CONTRIBUTORS.length}"
	puts "Employers: #{EMPLOYERS.length}"
	
end


def checkNeoIndexes

  ni = NEO.list_node_indexes
  NEO.create_node_index('digest') unless ni.has_key?('digest')
  NEO.create_node_index('contributors') unless ni.has_key?('contributors')
  NEO.create_node_index('committees') unless ni.has_key?('committees')
  NEO.create_node_index('candidates') unless ni.has_key?('candidates')



  #ri = NEO.list_relationship_indexes
  #NEO.create_relationship_index('donation') unless ri.has_key?('donation')

  true

end

def get_id_from_node_url(node_url = nil)
  if node_url
    arr = node_url.split('/')
    arr[-1]
  else
    false
  end
end

# traversal
def traverse_from(root_id = nil, array_position = 0)

  #  Let's find all the committees
  puts 'COMMITTEES'
  puts '=========='
  all_committees = NEO.get_node_index('committees','all','committee')
  all_committees.each do |c|
    thing = {
      'id' => get_id_from_node_url(c['indexed']),
      'data' => c['data']
    }
    puts thing
  end

  nodes = [] # name, group (1 = committee, 2 person, 3= employer)
  relationships = []
  if root_id
    root_node = NEO.get_node(root_id)
    puts 'ROOT NODE'
    puts '========='
    puts root_node['data']
    nodes.push({
      'id' => root_id,
      'name' => root_node['data']['name'],
      'group' => 1
    })
    donations = NEO.get_node_relationships(root_node) #,'all','donated_to')

    donors = []
    puts 'DONATIONS'
    puts '========='
    donations.each do |d|
      caseNode = NEO.get_node(d['start'])
      donors.push(caseNode)
      nodes.push({
        'id' => get_id_from_node_url(caseNode['self']),
        'name' => " #{caseNode['data']['first_name']} #{caseNode['data']['last_name']} ".strip!,
        'group' => 2
      })
      relationships.push({
        'source' => relationships.length + 1 + array_position,
        'target' => 0 + array_position,
        'value' => d['data']['amount']
      })
      puts d['data']
    end

    puts 'DONORS'
    puts '========='
    donors.each do |d|
      puts d['data']
    end

    puts 'JSON'
    puts '========='
    theJson = {
      'nodes' => nodes,
      'links' => relationships
    }
    puts theJson.to_json
#    nodes.each do |d|
#      puts d.to_json
#    end

#    relationships.each do |d|
#      puts d.to_json
#    end
  end

end




#
#  Run it thing
#
NEO_INDEXES = checkNeoIndexes

if ARGV[1] == 'console'
  binding.pry
else
  if ARGV[1] == 'traverse'
    traverse_from(ARGV[2], ARGV[3].to_i)
  else
    parseFile("#{current_path}/#{input_filename}")
  end
end


