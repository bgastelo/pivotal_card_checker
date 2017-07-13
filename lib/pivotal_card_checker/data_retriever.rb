# Calls the Pivotal API to retrieve all the card data we need.
class DataRetriever
  attr_reader :api_key, :proj_id, :all_stories,
              :all_labels, :all_comments, :all_owners
  def initialize(api_key, proj_id)
    @api_key = api_key
    @proj_id = proj_id
    @all_stories = Hash.new {}
    @all_labels = Hash.new {}
    @all_comments = Hash.new {}
    @all_owners = Hash.new {}
  end

  def retrieve_data
    client = TrackerApi::Client.new(token: @api_key)
    hedgeye_project = client.project(@proj_id)

    # Gets the current iteration and all backlog iterations.
    iterations = hedgeye_project.iterations(scope: :current_backlog)

    process_iterations(iterations)

    return @all_stories, @all_labels, @all_comments, @all_owners
  end

  def process_iterations(iterations)
    iterations.each do |iteration|
      iteration.stories.each do |story|
        curr_id = story.id
        @all_stories[curr_id] = story
        @all_labels[curr_id] = story.labels
        @all_comments[curr_id] = story.comments
        @all_owners[curr_id] = story.owners
      end
    end
  end
end
