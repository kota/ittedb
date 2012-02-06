# -*- coding: utf-8 -*-
PROBLEM_DIR = File.join(Rails.root, "db", "problems")

namespace :problem do
  task :convert => :environment do
    File.open(File.join(PROBLEM_DIR,"problems.txt")) do |file|
      Problem.convert_text_file(file)
    end
  end
end
