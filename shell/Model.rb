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

    if memoized_elements.has_key?(get('digest'))
      memoized_elements[get('digest')]
    else
      if ind = NEO.get_node_index('digest','md5',get('digest'))
        memoized_elements[get('digest')] = ind[0]
      else
        newNode = NEO.create_node(serialize())
        memoized_elements[get('digest')] = newNode
        set_index(newNode)
      end
    end
    memoized_elements[get('digest')]
  end


  def set_index (node = false)
    # Create node index
    if node
      NEO.add_node_to_index('digest', 'md5', get('digest'), node)
    end
  end

	

end