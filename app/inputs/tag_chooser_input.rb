class TagChooserInput < SimpleForm::Inputs::Base
  def input
    data = {
      class: reflection.class_name,
      id: object.id,
      input_class: attribute_name,
      tag_chooser: true,
      href: Rails.application.routes.url_helpers.etikett_tags_path,
      new_tags_allowed: reflection.class_name == 'Etikett::Tag'
    }
    input_html_options[:value] = object.public_send(reflection.name).map do |t|
      {id: t.id, text: t.name, locked: false}
    end.to_json
    input_html_options[:multiple] = true
    input_html_options[:data] = data
    input_html_options[:class] = ''
    options[:wrapper] = :select2
    @builder.text_field(attribute_name, input_html_options)
  end
end
