module PivotalCardChecker
  # Holds the relevant story information.
  class StoryCard
    attr_reader :id, :name, :description, :labels, :comments, :owners, :current_state, :in_current_iteration

    def initialize(id, name, description, labels, comments, owners, current_state, in_current_iteration)
      @id = id
      @name = name
      @description = description
      @labels = labels
      @comments = comments
      @owners = owners
      @current_state = current_state
      @in_current_iteration = in_current_iteration
    end
  end
end
