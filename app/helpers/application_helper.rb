# -*- coding: utf-8 -*-
module ApplicationHelper

  def h_answer(problem)
    if problem.hand
      image_tag(problem.answer_image)
    else
      "(なし)"
    end
  end

end
