# -*- coding: utf-8 -*-
class Problem < ActiveRecord::Base
  has_many :tags, :through => :problems_to_tags
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

 def image_at(x,y)
   koma = self.send("pos_#{x}#{y}")
   return "/komaimages/empty.png" unless koma
   player = koma >= GOTE ? "G" : "S"
   type = KOMA_IMAGE_NAMES[koma & 15]
   "/komaimages/#{player}#{type}.png"
 end

 def answer_image
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
