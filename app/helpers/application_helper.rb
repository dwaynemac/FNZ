# Methods added to this helper will be available to all templates in the application.
module ApplicationHelper

  def select_all_checkbox(options={})
    select_class = options.delete(:select_class) || 'selector_class'
    output = check_box_tag('toggle_all',options)
    output << javascript_tag do %(
        $(document).ready(function(){
            $('#toggle_all').change(function(){
                $('.#{select_class}').attr('checked',$(this).attr('checked'));
            })
        });
    ) end
    output
  end

  def select_currency(form)
    form.input :currency, :as => :select, :collection => %W( ars brl usd eur )
  end
end
