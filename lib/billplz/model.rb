module Billplz
  class Model
    attr_writer :endpoint
    attr_accessor :payload
    attr_accessor :response

    def initialize(payload={})
      @api_url  = Billplz.configuration.api_url
      @payload  = payload
    end

    def request(method, body, params = '')
      headers = {
        "Authorization" => "Basic " + Base64.encode64(Billplz.configuration.api_key + ":").strip,
        "Content-Type"  => "application/json",
        "Accept"        => "application/json"
      }

      url = endpoint.request_uri
      url = "#{url}/#{params}"

      @response = case method
      when :get
        raise ArgumentError, "GET requests do not support a request body" if body
        http.get(url, headers)
      when :post
        http.post(url, body.to_json, headers)
      when :put
        http.put(url, body.to_json, headers)
      when :patch
        http.patch(url, body, headers)
      when :delete
        raise ArgumentError, "DELETE requests do not support a request body" if body
        http.delete(url, headers)
      else
        raise ArgumentError, "Unsupported request method #{method.to_s.upcase}"
      end

      @response
    end

    class << self
      attr_accessor :api_url
    end

    def api_url
      self.class.api_url
    end

    def endpoint
      URI.parse("#{@api_url}#{fragment}")
    end

    def success?
      @response.is_a?(Net::HTTPOK)
    end

    def parsed_json
      JSON.parse(@response.body)
    end

    def fragment
      raise NotImplementedError
    end

    private

    def http
      http = Net::HTTP.new(endpoint.host, endpoint.port)
      http.use_ssl = true
      http.open_timeout = Billplz.configuration.http_timeout
      http.read_timeout = Billplz.configuration.http_timeout
      # http.set_debug_output($stdout)
      http
    end

    def requires!(hash, *params)
      params.each do |param|
        if param.is_a?(Array)
          raise ArgumentError.new("Missing required parameter: #{param.first}") unless hash.has_key?(param.first)

          valid_options = param[1..-1]
          raise ArgumentError.new("Parameter: #{param.first} must be one of #{valid_options.to_sentence(:words_connector => 'or')}") unless valid_options.include?(hash[param.first])
        else
          raise ArgumentError.new("Missing required parameter: #{param}") unless hash.has_key?(param)
        end
      end
    end
  end
end
