# Methods added to this helper will be available to all templates in the application.
module ApplicationHelper
  def title(str, container = nil)
    @page_title = str
    content_tag(container, str) if container
  end

  def flash_messages
    messages = []
    %w(notice warning error).each do |msg|
      messages << content_tag(:div, html_escape(flash[msg.to_sym]), :id => "flash-#{msg}") unless flash[msg.to_sym].blank?
    end
    messages
  end

  def locale_link(locale, locale_desc)
     locale_text = "#{locale_desc} (#{locale})"
     options =  { :locale => "#{locale}" }
     if I18n.locale == locale
       "#{locale_desc} (#{locale})"
     else
       link_to locale_text,
       url_for( {:controller => self.controller_name, :action => self.action_name}.merge(options) )
     end
  end

  def show_product_link(product, text = t('manage.products.common.show'), html_options = nil, default_value = "XXX")
    case product.class.name
    when "Item";
      link_to(text, manage_item_path(product), html_options)
    when "Package";
      link_to(text, manage_package_path(product), html_options)
    else
      default_value
    end
  end

  def edit_product_link(product, text = t('manage.products.common.edit'), html_options = nil, default_value = "XXX")
    case product.class.name
    when "Item";
      link_to(text, edit_manage_item_path(product), html_options)
    when "Package";
      link_to(text, edit_manage_package_path(product), html_options)
    else
      default_value
    end
  end

  def destroy_product_link(product, text = t('manage.products.common.destroy'), confirm_msg = "Are you sure?", default_value = "XXX")
    case product.class.name
    when "Item";
      link_to(text, manage_item_path(product), :confirm => confirm_msg, :method => :delete)
    when "Package";
      link_to(text, manage_package_path(product), :confirm => confirm_msg, :method => :delete)
    else
      default_value
    end
  end

  def search_product_link(text = t('manage.products.common.search'), html_options = nil)
    link_to(text, manage_products_path, html_options)
  end

end
