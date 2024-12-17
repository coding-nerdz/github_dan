require_relative './client.rb'
require 'json'

module Github
  class Processor
    # This class is responsible for processing the response from the Github API.
    def initialize(client)
      @client = client
    end

    def issues(open: true)
      # Fetch paginated issues from the Github API
      state = open ? 'open' : 'closed'
      url = "/issues?state=#{state}&per_page=50" # Include per_page parameter for clarity
      
      # Fetch all issues using pagination
      issues = @client.fetch_paginated(url)
      
      # Sort issues by created_at (if open) or closed_at (if closed)
      sorted_issues = issues.sort_by do |issue|
        state == 'closed' ? issue['closed_at'] : issue['created_at']
      end.reverse

      # Display issues
      sorted_issues.each do |issue|
        if issue['state'] == 'closed'
          puts "#{issue['title']} - #{issue['state']} - Closed at: #{issue['closed_at']}"
        else
          puts "#{issue['title']} - #{issue['state']} - Created at: #{issue['created_at']}"
        end
      end
    end
  end
end

# Run the script
Github::Processor.new(Github::Client.new(ENV['TOKEN'], ARGV[0])).issues(open: false)
