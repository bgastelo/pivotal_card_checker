module PivotalCardChecker
  # Calls the Pivotal API to retrieve all the card data we need.
  class DataRetriever
    def initialize(api_key, proj_id)
      @api_key = api_key
      @proj_id = proj_id
      @result = []
      client = TrackerApi::Client.new(token: @api_key)
      @hedgeye_project = client.project(@proj_id)
    end

    def retrieve_data
      # Gets the current iteration and all backlog iterations.
      iterations = @hedgeye_project.iterations(scope: :current_backlog)

      process_iterations(iterations, iterations.first.number)

      @result
    end

    def retrieve_epics
      labels = []
      @hedgeye_project.epics.each do |epic|
        labels << epic.label.name
      end
      labels
    end

    def process_iterations(iterations, current_iteration_number)
      iterations.each do |iteration|
        iteration.stories.each do |story|
          @result << StoryCard.new(story.id, story.name, story.description,
                                   story.labels, story.comments, story.owners,
                                   story.current_state,
                                   iteration.number == current_iteration_number)
        end
      end
    end
  end
end
