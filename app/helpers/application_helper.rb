module ApplicationHelper
  def link_to_in_li(body, badge_num, url, html_options = {})
    active = "active" if current_page?(url)
    content_tag :li, class: active do
      link_to content_tag(:span, "#{badge_num.to_s}", class: 'badge pull-right' ) + body, url, html_options
    end
  end
end
