module PivotalCardChecker
  # Calls the Pivotal API to retrieve all the card data we need.
  class DataRetriever
    def initialize(api_key, proj_id)
      @api_key = api_key
      @proj_id = proj_id
      @result = []
      client = TrackerApi::Client.new(token: @api_key)
      @project = client.project(@proj_id)
    end

    # Retrieves the current iteration and iterations in the backlog, processes
    # them (gets the story cards out)m then returns the story cards in a list.
    def retrieve_data
      iterations = @project.iterations(scope: :current_backlog,
                                       fields: "stories(:default,comments,owners)")

      process_iterations(iterations, iterations.first.number)
      @result
    end

    # Retrieves all of the epic labels in the project.
    def retrieve_epics
      labels = []
      @project.epics.each do |epic|
        labels << epic.label.name
      end
      labels
    end

    # Loops through each of the iterations, retrieving story card info and adding
    # them to the @result list.
    def process_iterations(iterations, current_iteration_number)
      iterations.each do |iteration|
        iteration.stories.each do |story|
          @result << StoryCard.new(story.id, story.name, story.description,
                                   story.labels, story.comments, story.owners,
                                   story.current_state, story.story_type,
                                   iteration.number == current_iteration_number)
        end
      end
    end
  end
end
