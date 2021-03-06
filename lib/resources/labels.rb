require_relative '../models/label'

get '/label' do
  search = params.fetch('name', '')
  labels = Label.where("lower(name) LIKE (?)", "%#{search.downcase}%")

  halt [404, 'No labels found'.to_json] if labels.empty?

  labels.to_json
end

get '/label/:id' do |id|
  label = Label.find_by_id(id)

  halt [404, 'Label not found.'.to_json] if label.nil?

  label.to_json
end

get '/label/:id/bands' do |id|
  label = Label.find_by_id(id)
  halt [404, 'Label not found.'.to_json] if label.nil?

  bands = label.bands.map { |band| band.get_band_info }
  halt [400, 'No bands found for that label.'.to_json] if bands.empty?

  bands.to_json
end

post '/label' do
  request.body.rewind
  request_payload = JSON.parse request.body.read

  label = Label.new(
    headquarters: request_payload['headquarters'],
    homepage: request_payload['homepage'],
    logo_path: request_payload['logo_path'],
    name: request_payload['name']
  )

  halt [400, 'Fields cannot be blank.'.to_json] unless label.valid?

  label.save
  [201, label.to_json]
end

put '/label/:id' do |id|
  request.body.rewind
  request_payload = JSON.parse request.body.read

  label = Label.find_by_id(id)
  halt [400, 'Label not found.'.to_json] if label.nil?

  request_payload.delete('splat')
  request_payload.delete('captures')

  updated = label.update(request_payload)
  halt [400, 'Fields cannot be blank.'.to_json] unless updated

  [200, label.to_json]
end

delete '/label/:id' do |id|
  label = Label.find_by_id(id)
  halt [400, 'No label with that id, unable to delete.'.to_json] if label.nil?

  label.destroy
  label.to_json
end
