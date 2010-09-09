OAUTH_CREDENTIALS={
  :padma => {
    :key => PADMA_KEY,
    :secret => PADMA_SECRET,
    :options => { :site => PADMA_API_URI }
  }
} unless defined? OAUTH_CREDENTIALS

load 'oauth/models/consumers/service_loader.rb'
