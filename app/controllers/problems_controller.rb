# -*- coding: utf-8 -*-
class ProblemsController < ApplicationController
  def index
    @problems = Problem.all(:order => "id desc")
  end

  def new
    @problem = Problem.new
  end

  def create
    @problem = Problem.new
    @problem.update_by_h_params(params[:problem].dup)
    redirect_to @problem
  end

  def show
    @problem = Problem.find(params[:id])
  end

  def edit
    @problem = Problem.find(params[:id])
  end

  def update
    @problem = Problem.find(params[:id])
    @problem.update_by_h_params(params[:problem].dup)
    redirect_to @problem
  end

  def search
    unless params[:search_word].blank?
      chars = params[:search_word].split(//)
      raise "Invalid length" if chars.size != 3
      x = chars[0].to_i
      raise "Invalid x" if x > 4 || x < 1
      y = chars[1].to_i
      raise "Invalid y" if y > 4 || y < 1
      type = Problem::KOMAS[chars[2]]
      @problems = Problem.find(:all,
                               :conditions => ["pos_#{x}#{y} = ? or pos_#{x}#{y} = ? ",type,type+Problem::GOTE], :order => "id desc")
    else
      tags = Tag.find(params[:problem][:tag_ids])
      @problems = tags.map{|t| t.problems }.flatten.uniq
    end
    render :action => :index
  end
end
