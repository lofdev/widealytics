#!/usr/bin/env ruby

# contribulizer.rb
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




input_filename = ARGV[0]
current_path = ENV['PWD']


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
		#l.gsub!('"',"*$*").gsub!("~",'"').gsub!('*$*',"'")
		#l[0] = '"'
		#l[-1] = '"'
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
	c['digest_name'] = "#{c['last_name']} #{c['first_name']} #{c['middle_initial']}".strip!
	c['digest_name'] ||= 'no name recorded'
	nameDigest = Digest::MD5.hexdigest(c['digest_name'])
	if CONTRIBUTORS.has_key?(nameDigest) 
		c['id'] = CONTRIBUTORS[nameDigest]
	else
		c['id'] = CONTRIBUTORS.length
		CONTRIBUTORS[nameDigest] = c['id']
	end
	c
end

def employerFromCsv(data) 
	c = {
		"name" => data[22].to_s,
		"occupation" => data[23].to_s
	}
	nameDigest = Digest::MD5.hexdigest(c['name'])
	if EMPLOYERS.has_key?(nameDigest) 
		c['id'] = EMPLOYERS[nameDigest]
	else
		c['id'] = EMPLOYERS.length
		EMPLOYERS[nameDigest] = c['id']
	end
	c	
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
	CONTRIBUTIONS.push(c)
	c
end

def committeeFromCsv(data)
	c = {
		'type' => data[19].to_s,
		'name' => data[20].to_s,
		'candidate' => data[21].to_s
	}
	nameDigest = Digest::MD5.hexdigest(c['name'])
	if COMMITTEES.has_key?(nameDigest) 
		c['id'] = COMMITTEES[nameDigest]
	else
		c['id'] = COMMITTEES.length
		COMMITTEES[nameDigest] = c['id']
	end
	c	
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
	end
	
	# Storing data is TBD
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



#
#  Run it thing
#
parseFile("#{current_path}/#{input_filename}")


