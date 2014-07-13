class Posts

  class << self

    def paths
      Dir.glob("markdown/posts/**/*/*.md").reverse.map do |post|
        post.slice! "markdown"
        post.slice! ".md"
        post.sub! "posts", "post"
      end
    end

    def details
      paths.map do |post|
        split = post.split("/")
        {
          :path => post,
          :title => split.last,
          :date => "#{split[3]}/#{split[4]}/#{split[2]}"
        }
      end
    end
  end
end
