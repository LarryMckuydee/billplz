module Billplz
  class Collection < Model
   def fragment
     '/collections'
   end


    def create
      requires!(@payload, :title)
      request(:post, @payload)
    end
  end
end
