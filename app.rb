require "./shotgun"
require "./lib/helpers"
require "./lib/pygments"
require "./lib/posts"

Cuba.use Sass::Plugin::Rack

Cuba.plugin Mote::Render
Cuba.plugin Helpers

Cuba.use Rack::Static,
  urls: %w(/stylesheets /fonts /images),
  root: "./public"

Cuba.define do

  on get do

    on root do
      render "root", :posts => Posts.details
    end

    on "post/:y/:m/:d/:slug" do |y, m, d, slug|
      render "post", :post => markdown("posts/#{y}/#{m}/#{d}/#{slug}")
    end
  end
end
