# -*- coding: utf-8 -*-
module ApplicationHelper

  def h_hand(problem)
    image_tag(problem.answer_image)
  end

end
