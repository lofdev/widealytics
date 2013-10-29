require 'digest/md5'

class Model
	@@attributes = {}

#  Getter/Setter Methods

  def setFromHash(data)
    @@attributes = {}
    data.each do |k,v|
      set(k,v.to_s)
    end
  end

	def get(attr)
		@@attributes[attr]
	end
	
	def set(attr,val)
		@@attributes[attr] = val
	end
	
	
	def createIdentifyingDigest(val)
		@@attributes['digest'] = Digest::MD5.hexdigest(val)
	end

  def serialize()
    @@attributes
  end


  def ensure_unique(memoized_elements)
    puts get('digest')
    if memoized_elements.has_key?(get('digest'))
      memoized_elements[get('digest')]
    else
      newNode = NEO.create_node(serialize())
      memoized_elements[get('digest')] = newNode
      set_index(newNode)
    end
    memoized_elements[get('digest')]
  end


  def set_index(nodes)
    true
    puts 'calling set_index parent'
    puts self.class.name
  end

#  Private Functions

	protected
	

end