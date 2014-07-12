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
      {
        :path => post,
        :title => post.split("/").last
      }
    end
  end
end
