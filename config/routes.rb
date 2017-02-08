Rails.application.routes.draw do
  root 'personnel#show'
  get  'personnel#test'
  post 'twilio/callback' => 'twilio#callback'
  post 'twilio/voice' => 'twilio#voice'
  post 'twilio/text' => 'message#receive' 
end