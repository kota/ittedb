class ProblemsToTags < ActiveRecord::Base
  belongs_to :problem
  belongs_to :tag
end
