class Tag < ActiveRecord::Base
  has :problem, :through => :problems_to_tags
end
