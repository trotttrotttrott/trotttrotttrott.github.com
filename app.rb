require "./shotgun"
require "./lib/helpers"

Cuba.use Sass::Plugin::Rack

Cuba.plugin Mote::Render
Cuba.plugin Helpers

Cuba.use Rack::Static,
  urls: %w(/stylesheets /fonts),
  root: "./public"

Cuba.define do
  on get do
    on root do
      render "root", :md => markdown("root")
    end
  end
end
