json.array! @etiketts do |etikett|
  json.text etikett.name
  json.id etikett.id
  json.locked etikett.generated?
end
