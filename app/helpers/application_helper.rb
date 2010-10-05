# Methods added to this helper will be available to all templates in the application.
module ApplicationHelper

  # Render jeditable in place edit field.
  # TODO: h for safety
  # FIXME: type: 'select' not working.
  #
  # Valid Options:
  # - object: defaults to @object_name
  # - type: default to text. If 'select' then select_collection is required.
  # - select_collection: json array of options for select dropdown.
  # - rows: defaults to 1
  # - print: this will be called on object and printed. defaults to field_name. Example: category.name will call object.category.name
  #
  # Will submit to url_for(object)
  # While data transfer is in progress CSS class 'editing' is assigned.
  #
  # In controller response should be
  #   <tt>format.json { render :json => {:result => @transaction.send(params[:wants])}}</tt> for success
  #   <tt>format.json { render :json => {:result => @transaction.send(params[:wants]+'_was')}}</tt> for failure
  #
  # helper by Luis Perichon, extracted from Sadhana.
  def jeditable_field(object_name, field_name, options = {})
    options.reverse_merge!({:type => 'text', :rows => '1'})
    object = options[:object] || self.instance_variable_get("@#{object_name}")
    if options[:print].nil?
      field = object.send(field_name)
    else
      tokens = options[:print].split('.')
      field = object
      tokens.each do |t|
        field = field.send(t) unless field.nil?
      end
    end
    output = content_tag(:span, field, {:id => "jeditable_#{dom_id object}_#{field_name}", :class => 'jeditable'})
    output << javascript_tag do %(
      $(document).ready(function() {
        $('#jeditable_#{dom_id object}_#{field_name}').editable(
          function(value, settings) {
            var result;
            $.ajax({
              type: 'PUT',
              url: '#{url_for(object)}' ,
              async: false,
              data: {
                authenticity_token: #{form_authenticity_token.to_json },
                wants: '#{field_name}',
                '#{object_name}[#{field_name}]' : value
              },
              dataType: 'json',
              success: function(data) {
                result = data.result;
              }
            });
            return(result);
          }, {
          #{"data: '#{options[:select_collection]}',"  if options[:type]=='select'}
          type    : '#{options[:type]}',
          #{"rows   : '#{options[:rows]}'," if options[:type] == 'text'}
          width : 'none',
          tooltip   : ' #{t('jeditable.tooltip')}',
          placeholder: '#{t('jeditable.tooltip')}',
          style     : 'display: inline;',
          onedit    : function() {
            $(this).addClass('editing');
          },
          onblur   : function() {
            this.reset();
            $(this).removeClass('editing');
          }
        });
      });
      )
    end
    output
  end

  def select_currency(form)
    form.input :currency, :as => :select, :collection => %W( ars brl usd eur )
  end
end
