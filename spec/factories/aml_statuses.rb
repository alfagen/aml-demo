FactoryBot.define do
  factory(:aml_status, class: AML::Status) do
    title { 'Title' }
    details { 'Details' }
    position { 'Position' }
    key { 'guest' }
  end
end
