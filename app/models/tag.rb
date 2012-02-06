class Tag < ActiveRecord::Base
  has_many :problem, :through => :problems_to_tags
end
