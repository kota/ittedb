class Tag < ActiveRecord::Base
  has_many :problem_to_tags
  has_many :problems, :through => :problem_to_tags
  validates_presence_of :name
end
