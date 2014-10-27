require 'sinatra'

get '/status' do
  if status_ok
    "Success"
  else
    500
  end
end

def status_ok
  true
end
