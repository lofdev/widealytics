require_relative './Model.rb'

class Employer < Model

	def Employer.newWithData(data = false)
	
		if data
      thisEmployer = Employer.new
      thisEmployer.setFromHash(data)
			thisEmployer.createIdentifyingDigest(" EMPLOYER: #{thisEmployer.get('name')} ".strip!)
      newNode = thisEmployer.ensure_unique(EMPLOYERS)
		else
			false
		end
  end

end