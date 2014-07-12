module Helpers
  def markdown(file)
    Redcarpet::Markdown.new(Pygments::HTMLwithPygments, :fenced_code_blocks => true)
      .render(File.read("./markdown/#{file}.md"))
  end

  def posts
    Dir.glob("markdown/posts/**/*/*.md").map do |post|
      post.slice! "markdown"
      post.slice! ".md"
      post.sub! "posts", "post"
      split = post.split("/")
      {
        :path => post,
        :title => split.last,
        :date => "#{split[3]}/#{split[4]}/#{split[2]}"
      }
    end
  end
end
