class Posts

  class << self

    def paths
      Dir.glob("markdown/posts/**/*/*.md").reverse.map do |post|
        post.slice! "markdown"
        post.slice! ".md"
        post.sub! "posts", "post"
      end
    end

    def details(filter = nil)
      all = paths.map do |post|
        split = post.split("/")
        {
          :path => post,
          :title => split.last,
          :date => "#{split[3]}/#{split[4]}/#{split[2]}"
        }
      end
      return all if filter.nil?
      all.find_all { |it| it[:title].split("-").first == filter }
    end

    def filters
      paths.map do |post|
        split = post.split("/")
        split.last.split("-").first
      end.sort
    end
  end
end
