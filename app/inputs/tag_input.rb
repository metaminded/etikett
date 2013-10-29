class TagInput < SimpleForm::Inputs::Base
  def input
    data = {
      class: object.class.name,
      id: object.id,
      tag_type: options[:tag_type],
      input_class: attribute_name,
      tag_chooser: true
    }
    input_html_options[:value] = object.public_send(reflection.name).map do |t|
      {id: t.id, text: t.name, locked: false}
    end.to_json
    input_html_options[:multiple] = reflection.try(:collection)
    input_html_options[:data] = data
    input_html_options[:class] = ''
    options[:wrapper] = :select2
    @builder.text_field(attribute_name, input_html_options)
  end
end
