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
	
end