require "./shotgun"
require "./lib/helpers"

Cuba.use Sass::Plugin::Rack

Cuba.plugin Mote::Render
Cuba.plugin Helpers

Cuba.use Rack::Static,
  urls: %w(/stylesheets /fonts /images),
  root: "./public"

Cuba.define do

  on get do

    on root do
      render "root"
    end

    on "post/:y/:m/:d/:slug" do |y, m, d, slug|
      render "post", :post => markdown("posts/#{y}/#{m}/#{d}/#{slug}")
    end

    on "posts" do
      render "posts"
    end
  end
end
