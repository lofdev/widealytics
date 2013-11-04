require_relative './Model.rb'

class Committee < Model

	def Committee.newWithData(data = false)

    if data
      thisCommittee = Committee.new
      thisCommittee.setFromHash(data)
      thisCommittee.createIdentifyingDigest(" COMMITTEE: #{thisCommittee.get('name')} ".strip!)
      newNode = thisCommittee.ensure_unique(COMMITTEES)
    else
      false
    end
  end


	def set_index(node)
    if node
      super(node)
      NEO.add_node_to_index('committees', 'all', 'committee', node)  #  Clever hack so I can find all committees quickly
      NEO.add_node_to_index('committees', 'name', get('name'), node)
      NEO.add_node_to_index('candidates', 'name', get('candidate'), node)
    end
  end

end