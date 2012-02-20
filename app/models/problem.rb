# -*- coding: utf-8 -*-
class Problem < ActiveRecord::Base
  has_many :problem_to_tags
  has_many :tags, :through => :problem_to_tags
  serialize :answer

  KOMAS = {"歩" => 0,
           "香" => 1,
           "桂" => 2,
           "銀" => 3,
           "金" => 4,
           "角" => 5,
           "飛" => 6,
           "玉" => 7,
           "王" => 7,
           "と" => 8,
           "杏" => 9,
           "圭" => 10,
           "全" => 11,
           "馬" => 12,
           "龍" => 13}

  KOMA_IMAGE_NAMES = ['fu','kyo','kei','gin','kin','kaku','hi','ou','to','nkyo','nkei','ngin','uma','ryu'];

  GOTE = 16

  def edited?
    !self.tags.find_by_id(50).blank?
  end

  def update_by_h_params(params)
    unless params[:answer].blank?
      params[:answer] = Problem.build_answer_hash(params[:answer])
    end
    params[:hand] = params[:hand].blank? ? nil : Problem.inverse_h_koma(params[:hand])
    1.upto(4).each do |x|
      1.upto(4).each do |y|
        unless params["pos_#{x}#{y}"].blank?
          params["pos_#{x}#{y}"] = Problem.build_koma(params["pos_#{x}#{y}"])
        end
      end
    end
    self.update_attributes(params)
  end

  def self.build_answer_hash(label)
    #ex. 12(00) 1  12香打 => {:x => 1,:y => 2,:from_x => 0,:from_y => 0,:koma => 1,:drop => true}
    #ex. 32(33) 3  32銀成 => {:x => 3,:y => 2,:from_x => 3,:from_y => 3,:koma => 3,:drop => false}
    return "" if label.blank?

    x = label[0].to_i
    y = label[1].to_i
    from_x = 0
    from_y = 0
    if /\(([0-9]{2})\)/ =~ label
      from_x = $1[0].to_i
      from_y = $1[1].to_i
    end
    drop = from_x == 0 && from_y == 0
    

    promote = !!(/n/ =~ label)
    /([0-9]*)/ =~ label.split(' ')[1]
    koma = Problem.inverse_h_koma($1.to_i)

    {:x => x,:y => y,:from_x => from_x,:from_y => from_y,
     :koma => koma,:drop => drop, :promote => promote}
  end

  def self.build_koma(label)
   /([0-9]+)/ =~ label
   koma = $1.to_i
   koma += GOTE if /v/ =~ label
   koma += 8 if /n/ =~ label
   Problem.inverse_h_koma(koma)
  end

  def koma_label_at(x,y)
    koma = self["pos_#{x}#{y}"]
    return '' unless koma
    options = ""
    if koma >= GOTE 
      koma -= GOTE
      options += "v"
    end
    if koma >= 8 #成り
      koma -= 8
      options += "n" 
    end
    "#{options}#{Problem.h_koma(koma)}"
  end

  #human readableな駒数字
  def self.h_koma(koma)
    return '' if koma.nil?
    (koma.to_i + 1).to_s
  end

  def self.inverse_h_koma(koma)
    (koma.to_i - 1).to_s
  end

  def answer_label
    return "" if self.answer.blank?
    from = self.answer[:drop] ? "(00)" : "(#{self.answer[:from_x]}#{self.answer[:from_y]})"
    promote = self.answer[:promote] ? 'n' : ''
    "#{self.answer[:x]}#{self.answer[:y]}#{from} #{Problem.h_koma(self.answer[:koma])}#{promote}"
  end

  def answer_h_label
    return '' if self.answer.blank?
    promote = self.answer[:promote] ? '成' : ''
    drop = self.answer[:drop] ? "打" : ''
    from = self.answer[:drop] ? '' : "(#{self.answer[:from_x]}#{self.answer[:from_y]})"
    koma = KOMAS.key(self.answer[:koma].to_i)
    "#{self.answer[:x]}#{self.answer[:y]}#{from} #{koma}#{promote}#{drop}"
  end

  def image_at(x,y)
    koma = self.send("pos_#{x}#{y}")
    return "/komaimages/empty.png" unless koma
    player = koma >= GOTE ? "G" : "S"
    type = KOMA_IMAGE_NAMES[koma & 15]
    "/komaimages/#{player}#{type}.png"
  end

  def answer_image
    return "/komaimages/nashi.png" if hand.nil?
    "/komaimages/S#{KOMA_IMAGE_NAMES[hand.to_i]}.png"
  end

  def self.convert_text_file(file)
    problem = nil
    row = 0
    file.each do |line|
      if /^-----/ =~ line
        problem.save if problem
        row = 0
        problem = Problem.new
        next
      end
      #1行 | ・ ・ ・ ・ ・ ・ ・v玉 ・|一
      if /\|/ =~ line
        chars = line.split(//)
        chars.shift #行頭の|を取り除く
        pieces = []
        9.times do |col|
          left = chars.shift #" " or "v"
          right = chars.shift # "・" or "玉"など
          unless /・/u =~ right #マスが空でなければ
            player = left == ' ' ? 0 : 1
            koma = KOMAS[right]
            pieces << {:x => col, :y => row, :player => player, :koma => koma} 
            koma += 16 if player == 1
            x = 9 - col
            y = row + 1
            problem.send("pos_#{x.to_s}#{y.to_s}=",koma.to_i)
          end
        end
        row += 1
      elsif /(先手の持駒|下手の持駒)：(.*)/ =~ line
        problem.hand = KOMAS[$2.split(//)[0]]
      elsif /答え：(.*)/ =~ line
        answer_elements = $1.split(//)
        problem.answer = {:x => answer_elements[0],
                          :y => answer_elements[1],
                          :koma => KOMAS[answer_elements[2]],
                          :drop => answer_elements.size > 2 && answer_elements[3] == '打'}
      end
    end
  end

#  katagami_fileの例
#  腹金  <= ファイルの一行目にタグ用文字列
# 
#  後手の持駒：飛二　角二　金三　銀四　桂四　香三　歩十六　
#    ９ ８ ７ ６ ５ ４ ３ ２ １
#  +---------------------------+
#  | ・ ・ ・ ・ ・ ・ ・ ・v香|一
#  | ・ ・ ・ ・ ・ ・ ・ ・v玉|二
#  | ・ ・ ・ ・ ・ ・ ・ 歩v歩|三
#  | ・ ・ ・ ・ ・ ・ ・ ・ ・|四
#  | ・ ・ ・ ・ ・ ・ ・ ・ ・|五
#  | ・ ・ ・ ・ ・ ・ ・ ・ ・|六
#  | ・ ・ ・ ・ ・ ・ ・ ・ ・|七
#  | ・ ・ ・ ・ ・ ・ ・ ・ ・|八
#  | ・ ・ ・ ・ ・ ・ ・ ・ ・|九
#  +---------------------------+
#  先手の持駒：金　
#  手数＝0    まで

  def self.convert_katagami_file(file)
    problem = nil
    row = 0

    tag_names = file.gets.strip.split(//)
    tag_names = tag_names.select{|t| t != " " && t != "　"}
    tags = []
    koma_tag = Tag.find(:first,:conditions => ['name = ? and category_id = ?',tag_names[0],4]) 
    tags << koma_tag unless koma_tag.blank?
    promote_tag = Tag.find(:first,:conditions => ['name = ? and category_id = ?',tag_names[1],6]) 
    tags << promote_tag unless promote_tag.blank?
    pos_tag = Tag.find(:first,:conditions => ['name = ? and category_id = ?',tag_names[2],5]) 
    tags << pos_tag unless pos_tag.blank?

    problem_found = false

    file.each do |line|
      if /^\s*$/ =~ line
        if problem && problem_found
          problem.save 
        end
        row = 0
        problem = Problem.new
        tags.each do |tag|
          problem.tags << tag unless tag.nil?
        end
        problem_found = false
        next
      end
      #1行 | ・ ・ ・ ・ ・ ・ ・v玉 ・|一
      if /\|/ =~ line
        problem_found = true
        chars = line.split(//)
        chars.shift #行頭の|を取り除く
        pieces = []
        9.times do |col|
          left = chars.shift #" " or "v"
          right = chars.shift # "・" or "玉"など
          unless /・/u =~ right #マスが空でなければ
            player = left == ' ' ? 0 : 1
            koma = KOMAS[right]
            pieces << {:x => col, :y => row, :player => player, :koma => koma} 
            koma += 16 if player == 1
            x = 9 - col
            y = row + 1
            if koma == 7 + GOTE
              tag = Tag.find(:first,:conditions => ['category_id = ? and name = ?',3,"#{x}#{y}"])
              problem.tags << tag
            end
            problem.send("pos_#{x.to_s}#{y.to_s}=",koma.to_i)
          end
        end
        row += 1
      elsif /(先手の持駒|下手の持駒)：(.*)/ =~ line
        problem.hand = KOMAS[$2.split(//)[0]]
      #答えは入力しない
      end
    end
  end

  def to_nyaw_json
    problem = {}
    problem['mochigoma'] = [hand.to_i]
    problem['answer'] = [self.answer]

    problem['ban'] = []
    1.upto(4).each do |x|
      1.upto(4).each do |y|
        unless (koma = self["pos_#{x}#{y}"]).blank?
          problem['ban'] << {'x' => x,
                             'y' => y,
                             'player' => koma >= GOTE ? 1 : 0,
                             'koma' => koma & 15}
        end
      end
    end
    problem
  end

  def self.generate_nyaw_problems
    (Problem.all.map(&:to_nyaw_json)).to_json
  end

  # 生データをTitaniumアプリ用に加工するときに使った処理
  # def self.convert_text(text)
  #   problems = []
  #   problem = {}
  #   row = 0
  #   text.each do |line|
  #     if /^-----/ =~ line
  #       problems << problem #problem.to_json
  #       row = 0
  #       problem = {:mochigoma => [], :ban => [], :answer => []}
  #       next
  #     end
  #     #1行 | ・ ・ ・ ・ ・ ・ ・v玉 ・|一
  #     if /\|/ =~ line
  #       chars = line.split(//)
  #       chars.shift #行頭の|を取り除く
  #       pieces = []
  #       9.times do |col|
  #         left = chars.shift #" " or "v"
  #         right = chars.shift # "・" or "玉"など
  #         unless /・/u =~ right #マスが空でなければ
  #           player = left == ' ' ? 0 : 1
  #           koma = KOMAS[right]
  #           pieces << {:x => col, :y => row, :player => player, :koma => koma} 
  #         end
  #       end
  #       problem[:ban] += pieces if pieces.size > 0
  #       row += 1
  #     elsif /(先手の持駒|下手の持駒)：(.*)/ =~ line
  #       problem[:mochigoma] << KOMAS[$2.split(//)[0]]
  #     elsif /答え：(.*)/ =~ line
  #       answer_elements = $1.split(//)
  #       problem[:answer] << {:x => answer_elements[0],
  #                            :y => answer_elements[1],
  #                            :koma => KOMAS[answer_elements[2]],
  #                            :drop => answer_elements.size > 2 && answer_elements[3] == '打'}
  #     end
  #   end
  #   problems.shift
  #   problems
  # end

end
