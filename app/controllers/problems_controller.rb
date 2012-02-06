# -*- coding: utf-8 -*-
class ProblemsController < ApplicationController
  def index
    @problems = Problem.all
  end

  def show
    @problem = Problem.find(params[:id])
  end

  def search
    chars = params[:search_word].split(//)
    puts chars.inspect
    puts chars.size
    raise "Invalid length" if chars.size != 3
    x = chars[0].to_i
    raise "Invalid x" if x > 4 || x < 1
    y = chars[1].to_i
    raise "Invalid y" if y > 4 || y < 1
    type = Problem::KOMAS[chars[2]]
    @problems = Problem.find(:all,
                             :conditions => ["pos_#{x}#{y} = ? or pos_#{x}#{y} = ? ",type,type+Problem::GOTE])
    render :action => :index
  end
end
