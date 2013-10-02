module Pipely

  # Represents a dependency from one Component on another
  # http://amzn.to/16lbBKx
  #
  class Dependency < Struct.new(:label, :target_id, :color)

    def color
      super || 'black'
    end

  end

end
