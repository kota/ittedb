# -*- coding: utf-8 -*-
PROBLEM_DIR = File.join(Rails.root, "db", "problems")

namespace :problem do
  namespace :convert do
    task :all => [:kitao, :katagami]
    task :kitao => :environment do
      File.open(File.join(PROBLEM_DIR,"problems.txt")) do |file|
        Problem.convert_text_file(file)
      end
    end

    task :katagami => :environment do
      File.open(File.join(PROBLEM_DIR,"katagami.txt")) do |file|
        Problem.convert_katagami_file(file)
      end
    end
  end
  
end
