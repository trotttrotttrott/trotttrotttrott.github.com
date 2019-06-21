module Helpers
  def markdown(path)

    md_str = File.read("./markdown/#{path}.md")

    date = path.split('/')[1..3]

    date_str =  " . "
    date_str << "<small>"
    date_str << [date[1], date[2], date[0]].join('/')
    date_str << "</small>"
    date_str << "\n\n"

    md_str.sub! "\n\n", date_str

    Redcarpet::Markdown.new(Pygments::HTMLwithPygments, :fenced_code_blocks => true)
      .render(md_str)
  end
end
