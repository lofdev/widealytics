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

  def set_index (node = false)
    # Create node index
    if node
      NEO.add_node_to_index('digest', 'md5', get('digest'), node)
    end
  end
	
end