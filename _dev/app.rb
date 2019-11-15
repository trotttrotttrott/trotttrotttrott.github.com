require "./shotgun"
require "./lib/helpers"
require "./lib/pygments"
require "./lib/posts"

Cuba.use Sass::Plugin::Rack

Sass::Plugin.options[:css_location] = "stylesheets"

Cuba.plugin Mote::Render
Cuba.plugin Helpers

Cuba.use Rack::Static,
  urls: %w(/stylesheets /fonts /images),
  root: "."

Cuba.define do

  on get do

    on root do
      render "root", :posts => Posts.details,
                     :title => "trotttrotttrott",
                     :filters => Posts.filters
    end

    on "filter/:filter" do |filter|
      render "root", :posts => Posts.details(filter),
                     :title => "trotttrotttrott - ##{filter}",
                     :filters => Posts.filters
    end

    on "post/:y/:m/:d/:slug" do |y, m, d, slug|
      render "post", :post => markdown("posts/#{y}/#{m}/#{d}/#{slug}"),
                     :title => slug
    end
  end
end
