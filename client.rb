require 'httparty'

module Github
  class Client
    # This class is responsible for making requests to the Github API
    # It accepts a personal access token and stores it as an instance variable.
    # It has a method called `get` that accepts a URL and returns the response
    # from the Github API.

    def initialize(token, repo_url)
      @token = token
      @repo_url = repo_url
    end

    def get(url)
      # This method generates the required headers and makes a GET request
      # to the Github API using the provided URL.
      HTTParty.get("#{@repo_url}#{url}", headers: headers)
    end

    def fetch_paginated(url)
      # This method fetches paginated data from the Github API
      # by following 'Link' headers for pagination.
      results = []
      full_url = "#{@repo_url}#{url}"
      
      loop do
        response = HTTParty.get(full_url, headers: headers)
        raise "Error: #{response.code} - #{response.message}" unless response.success?

        results.concat(JSON.parse(response.body)) # Append the current page's results

        # Parse 'Link' header to determine if there is a next page
        links = parse_link_header(response.headers['link'])
        if links['next']
          full_url = links['next']
        else
          break
        end
      end

      results
    end

    private

    def headers
      {
        'Authorization' => "Bearer #{@token}",
        'User-Agent' => 'Github Client'
      }
    end

    def parse_link_header(header)
      # Parses the 'Link' header and returns a hash with rel values (e.g., 'next' => url)
      links = {}
      return links if header.nil?

      header.split(', ').each do |link|
        url, rel = link.match(/<(.*?)>; rel="(.*?)"/).captures
        links[rel] = url
      end

      links
    end
  end
end
