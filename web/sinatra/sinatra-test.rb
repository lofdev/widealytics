# testing for sinatra

require 'sinatra'
require 'date'
require 'json'
require 'pry'


#  Instance of Neography for connecting to Neo4J
NEO = nil

get '/' do
  'Hello Sinatra'
end

get '/node/:node_id/:array_position' do
  if NEO.class.name != 'Neography::Rest'
    require 'neography'
    NEO = Neography::Rest.new
    puts '{ "neo" : "init" }'
  end
  nodes = [] # name, group (1 = committee, 2 person, 3= employer)
  donors = []
  relationships = []
  if params[:node_id]
    root_node = NEO.get_node(params[:node_id])
    nodes.push({
                   'id' => params[:node_id],
                   'name' => root_node['data']['name'],
                   'group' => 1
               })

    #  Get all the relationships
    if (root_node['data']['candidate'])  #  will only return donors

      donations = NEO.get_node_relationships(root_node,'all','donated_to')
      donations.each do |d|
        if get_id_from_node_url(d['start']) != params[:node_id]
          caseNode = NEO.get_node(d['start'])
        else
          caseNode = NEO.get_node(d['end'])
        end
        nodes.push({
                       'id' => get_id_from_node_url(caseNode['self']),
                       'name' => " #{caseNode['data']['first_name']} #{caseNode['data']['last_name']} ".strip!,
                       'group' => 5
                   })
        relationships.push({
                               'source' => get_id_from_node_url(d['start']),
                               'target' => get_id_from_node_url(d['end']),
                               'value' => d['data']['amount']
                           })
      end
    else
      if (root_node['data']['occupation'])    #  Will only return people
        donations = NEO.get_node_relationships(root_node) #,'all','donated_to')
        donations.each do |d|
          if get_id_from_node_url(d['start']) != params[:node_id]
            caseNode = NEO.get_node(d['start'])
          else
            caseNode = NEO.get_node(d['end'])
          end

          group = 5
          nodes.push({
                         'id' => get_id_from_node_url(caseNode['self']),
                         'name' => " #{caseNode['data']['first_name']} #{caseNode['data']['last_name']} ".strip!,
                         'group' => group
                     })
          relationships.push({
                                 'source' => get_id_from_node_url(d['start']),
                                 'target' => get_id_from_node_url(d['end']),
                                 'value' => d['data']['amount']
                             })

        end
      else    #  Will return both campaigns and employers
        donations = NEO.get_node_relationships(root_node) #,'all','donated_to')
        donations.each do |d|
          if get_id_from_node_url(d['start']) != params[:node_id]
            caseNode = NEO.get_node(d['start'])
          else
            caseNode = NEO.get_node(d['end'])
          end

          if (caseNode['data']['occupation'])
            group = 4
          else
            group = 1
          end
          nodes.push({
                         'id' => get_id_from_node_url(caseNode['self']),
                         'name' => " #{caseNode['data']['first_name']} #{caseNode['data']['last_name']} ".strip!,
                         'group' => group
                     })
          relationships.push({
                                 #   'source' => relationships.length + 1 + params[:array_position].to_i,
                                 'source' => get_id_from_node_url(d['start']),
                                 'target' => get_id_from_node_url(d['end']),
                                 'value' => d['data']['amount']
                             })

        end
      end
    end


    theJson = {
        'nodes' => nodes,
        'links' => relationships
    }
    puts theJson.to_json
    theJson.to_json
  end

end


def get_id_from_node_url(node_url = nil)
  if node_url
    arr = node_url.split('/')
    arr[-1]
  else
    false
  end
end




