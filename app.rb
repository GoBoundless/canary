require 'sinatra'
require 'httparty'

raise "The API_KEY env var must be set. Try setting it in .envrc and using direnv." unless ENV["API_KEY"]

get '/status' do
  check_status()
end

def check_status
  status_ok = question_api_ok

  if status_ok
    "Success"
  else
    500     # return non-200 for pingdom
  end
end

def api_key
  @api_key ||= ENV["API_KEY"]
end

def question_api_ok
  response = HTTParty.get("https://www.boundless.com/api/private/questions/search?query=frogs&api_key=#{api_key}")
  
  return false unless (["total_count", "results"] - response.keys).length == 0
  results = response["results"]
  
  return false unless results.all? do |result|
    has_all_keys = (["id", "question", "choices", "correct_answers"] - result.keys).length == 0
    
    id = result["id"]
    valid_id = id.is_a?(Integer) && id > 0
    
    question = result["question"]
    valid_question = question.is_a?(String)
    
    choices = result["choices"]
    valid_choices = choices.is_a?(Array) && choices.all? { |choice| choice.is_a?(String) }
    
    correct_answers = result["correct_answers"]
    valid_correct_answers = correct_answers.is_a?(Array) && correct_answers.all? { |correct_answer| correct_answer.is_a?(String) }
    
    has_all_keys && valid_id && valid_question && valid_choices && valid_correct_answers
  end
  
  true
rescue StandardError
  false
end
