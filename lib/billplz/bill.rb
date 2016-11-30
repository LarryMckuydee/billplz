module Billplz
  class Bill < Model
     def fragment
       'bills'
     end

    def create
      requires!(@payload, :collection_id, :email, :name, :amount, :callback_url)
      request(:post, @payload)
    end

    def get
      requires!(@payload, :bill_id)
      request(:get, nil, "#{@payload[:bill_id]}")
      JSON.parse(@response.body) if success?
    end

    def delete
      requires!(@payload, :bill_id)
      request(:delete, nil, "#{@payload[:bill_id]}")
    end
  end
end
