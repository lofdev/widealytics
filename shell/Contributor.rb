require_relative './Model.rb'

class Contributor < Model

	def Contributor.newWithData(data = false)

    if data
      thisContributor = Contributor.new
      thisContributor.setFromHash(data)
      thisContributor.createIdentifyingDigest(" CONTRIBUTOR: #{thisContributor.get('last_name')} #{thisContributor.get('first_name')} #{thisContributor.get('middle_initial')} @ #{thisContributor.get('zip')} ".strip!)
      newNode = thisContributor.ensure_unique(CONTRIBUTORS)
    else
      false
    end
  end

  def set_index(node)
    if node
      super(node)
      NEO.add_node_to_index('contributors', 'name', " #{get('last_name')} #{get('first_name')} #{get('middle_initial')} ".strip!, node)
      NEO.add_node_to_index('contributors', 'zip', get('zip'), node)
    end
  end
end