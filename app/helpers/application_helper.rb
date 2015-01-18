# -*- coding: utf-8 -*-
module ApplicationHelper

  def h_hand(problem)
    image_tag(problem.answer_image, size: "43x48")
  end

end
