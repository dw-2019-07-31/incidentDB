json.extract! incident, :id, :type, :reception_date, :group, :username, :hostname, :os, :product, :subject, :solution, :story, :status, :close_date, :remarks, :operator, :created_at, :updated_at
json.url incident_url(incident, format: :json)
