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
      #File.open(File.join(PROBLEM_DIR,"katagami.txt")) do |file|
      #  Problem.convert_katagami_file(file)
      #end
      dir_path = File.join(PROBLEM_DIR,"katagami")
      Dir::foreach(File.join(PROBLEM_DIR,"katagami")) do |f|
        if /u_[0-9]/ =~ f
          File.open(File.join(dir_path,f)) do |file|
            puts "converting #{File.join(dir_path,f)}"
            Problem.convert_katagami_file(file)
          end
        end
      end
    end

    task :japanese => :environment do
      dir_path = File.join(PROBLEM_DIR,"katagami")
      Dir::foreach(dir_path) do |f|
        if /txt/ =~ f
          system("nkf -w #{File.join(dir_path,f)} > #{File.join(dir_path,'u_'+f)}")
        end
      end
    end
  end
  
end
