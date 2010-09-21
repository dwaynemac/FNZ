# Methods added to this helper will be available to all templates in the application.
module ApplicationHelper

  def select_currency(form)
    form.input :currency, :as => :select, :collection => %W( ars brl usd eur )
  end
end
