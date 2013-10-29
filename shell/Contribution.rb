require_relative './Model.rb'

class Contribution < Model

	def Contribution.newWithData(data = false)

    if data
      o = {
          'co_id' => data['co_id'],
          'amount' => data['amount'],
          'date' => data['date']
      }
      thisContribution = Contribution.new
      thisContribution.setFromHash(o)





      thisContribution
    else
      false
    end
  end

  def serialize
    o = {
      'co_id' => @@attributes['co_id'],
      'amount' => @@attributes['amount'],
      'date' => @@attributes['date']
    }
  end

  def set_index (node = false)
    true
  end

end