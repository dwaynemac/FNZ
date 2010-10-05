module Slider

  def self.included(base)
    base.send(:include, Slider::ViewHelpers)
  end

  # Gets params_hash[:since] and params_hash[:until]
  # and returns [since,until] both dates.
  # Parameters:
  #  <tt>:default_since</tt> default to 1 month ago
  #  <tt>:default_until</tt> defaults to 1 month from now
  #  <tt>:params_hash</tt> defaults to params[:search]
  def get_range(options)

    default_since = options.delete(:default_since)
    default_since = 1.month.ago.to_date if default_since.nil?
    default_until = options.delete(:default_until)
    default_until = 1.month.from_now.to_date if default_until.nil?

    # get range from params
    pm = options.delete(:params_hash)
    pm = params[:search] if pm.nil?
    pm = pm || {}
    period_ini = pm.delete(:since).try(:to_date)
    period_end = pm.delete(:until).try(:to_date)

    # if no range set in params, check session
    period_ini = session[:period_ini].try(:to_date) if period_ini.nil?
    period_end = session[:period_end].try(:to_date) if period_end.nil?

    # initialize with defaults if no data was recieved through params and no data was stored in session.
    period_ini = default_since.to_date if period_ini.nil?
    period_end = default_until.to_date if period_end.nil?

    # store new period on session
    session[:period_ini] = period_ini
    session[:period_end] = period_end

    return period_ini, period_end
  end

  # returns an array of days for the JQueryUISlider
  def days_for_select(from,to,options={})
    from = from.to_date
    to = to.to_date

    format = options.delete(:format)
    format = :month if format.nil?
    (from...to).map{|d| [l(d,:format => format),l(d)]}
  end

  # returns an array of months for the JQueryUISlider
  def months_for_select(from,to,options={})
    from = from.beginning_of_month.to_date
    to = to.end_of_month.to_date
    dates = []
    until from > to do
      dates << from.beginning_of_month
      from = from+1.month
    end
    format = options.delete(:format)
    format = :month if format.nil?
    return dates.map{|d| [l(d,:format => format),l(d)]}
  end

  module ViewHelpers
    def self.included(base)
      base.send(:helper_method, :slider_script, :slider_formtastic_inputs)
    end

    def slider_script
      return <<-STRING
<script>
  $(function(){
    $('.slider_select').selectToUISlider({labels: 12, labelSrc: "text"}).hide();
    });
</script>
      STRING
    end

    def slider_formtastic_inputs(formtastic,options_for_select,from,to)
      str = ""
      str << formtastic.input(:since, :as => :select, :collection => options_for_select, :label => false, :selected => l(from), :input_html => { :class => 'slider_select'} )
      str << formtastic.input(:until, :as => :select, :collection => options_for_select, :label => false, :selected => l(to), :input_html => { :class => 'slider_select'} )
      return str
    end
  end

end