class TagSingleChooserInput < SimpleForm::Inputs::Base
  def input
    data = {
      class: options[:class_name],
      id: object.id,
      input_class: attribute_name,
      multiple: false,
      tag_chooser: true,
      href: Rails.application.routes.url_helpers.etikett_tags_path,
      new_tags_allowed: options[:new_tags_allowed] || false
    }
    input_html_options[:value] = object.public_send(attribute_name).try do |t|
      [{id: t.id, text: t.name, locked: false}]
    end.to_json
    # input_html_options[:multiple] = false
    input_html_options[:data] = data
    input_html_options[:class] = ''
    options[:wrapper] = :select2
    @builder.text_field(attribute_name, input_html_options)
  end
end
