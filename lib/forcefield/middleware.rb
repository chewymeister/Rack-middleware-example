module Forcefield
  class Middleware
    def initialize app
      @app = app
    end

    def call env
      if env["HTTP_AUTHORIZATION"]
        @app.call env
      else
        [401, {}, ["Unauthorized! You are part of the Rebel Alliance and are a Traitor!"]]
      end
    end
  end
end

