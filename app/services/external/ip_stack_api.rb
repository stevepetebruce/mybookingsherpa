module External
  # Wrapper around "IP address -> country info" IpStack API
  # ref: https://ipstack.com/documentation
  class IpStackApi
    def initialize(ip_address)
      @ip_address = ip_address
    end

    def country_code
      hashed_response["country_code"].downcase
    end

    def self.country_code(ip_address)
      new(ip_address).country_code
    end

    def self.is_gb?(ip_address)
      "gb" == new(ip_address).country_code
    end

    private

    def base_url
      "http://api.ipstack.com/"
    end

    def escaped_address
      URI.escape(request_url)
    end

    def hashed_response
      JSON.parse(raw_response)
    end

    def raw_response
      Net::HTTP.get(request_uri)
    end

    def request_uri
      URI.parse(escaped_address)
    end

    def request_url
      "#{base_url}#{@ip_address}?access_key=#{ENV.fetch("IP_STACK_API_KEY")}"
    end
  end
end
