# -*- coding: utf-8 -*-
class ProblemsController < ApplicationController
  def index
    @problems = Problem.all
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

  ##def create
  ##  @neko = Neko.new(params[:neko])

  ##  respond_to do |format|
  ##    if @neko.save
  ##      format.html { redirect_to @neko, notice: 'Neko was successfully created.' }
  ##      format.json { render json: @neko, status: :created, location: @neko }
  ##    else
  ##      format.html { render action: "new" }
  ##      format.json { render json: @neko.errors, status: :unprocessable_entity }
  ##    end
  ##  end
  ##end

  ### PUT /nekos/1
  ### PUT /nekos/1.json
  ##def update
  ##  @neko = Neko.find(params[:id])

  ##  respond_to do |format|
  ##    if @neko.update_attributes(params[:neko])
  ##      format.html { redirect_to @neko, notice: 'Neko was successfully updated.' }
  ##      format.json { head :ok }
  ##    else
  ##      format.html { render action: "edit" }
  ##      format.json { render json: @neko.errors, status: :unprocessable_entity }
  ##    end
  ##  end
  ##end

  ### DELETE /nekos/1
  ### DELETE /nekos/1.json
  ##def destroy
  ##  @neko = Neko.find(params[:id])
  ##  @neko.destroy

  ##  respond_to do |format|
  ##    format.html { redirect_to nekos_url }
  ##    format.json { head :ok }
  ##  end
  ##end



  def search
    chars = params[:search_word].split(//)
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
