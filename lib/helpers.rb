module Helpers
  def markdown(file)
    Redcarpet::Markdown.new(HTMLwithPygments, :fenced_code_blocks => true)
      .render(File.read("./markdown/#{file}.md"))
  end
end
