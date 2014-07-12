module Helpers
  def markdown(file)
    Redcarpet::Markdown.new(Redcarpet::Render::HTML, :fenced_code_blocks => true)
      .render(File.read("./markdown/#{file}.md"))
  end
end
