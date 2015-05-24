module ApplicationHelper
  def link_to_in_li_local(body, badge_num, hash, html_options = {})
    url = "/#{I18n.locale.to_s}/films?#{hash.keys[0].to_s}=#{hash.values[0].to_s}"
    active = "active" if current_page?(url)
    content_tag :li, class: active do
      link_to content_tag(:span, "#{badge_num.to_s}", class: 'badge pull-right') + body, url, html_options
    end
  end
end
