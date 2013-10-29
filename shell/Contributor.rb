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

end