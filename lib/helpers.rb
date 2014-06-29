module Helpers
  def markdown(file)
    Redcarpet::Markdown.new(Redcarpet::Render::HTML)
      .render(File.read("./markdown/#{file}.md"))
  end
end
