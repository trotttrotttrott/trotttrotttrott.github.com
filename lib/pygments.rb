class HTMLwithPygments < Redcarpet::Render::HTML
  def block_code(code, language)
    str = Pygments.highlight(code, :lexer => language, :formatter => "html", :options => {:encoding => "utf-8"})
      .match(/<pre>(.+)<\/pre>/m)[1].to_s.gsub(/ *$/, '')
    table = "<div class=\"highlight\"><table><tr><td class=\"gutter\"><pre class=\"line-numbers\">"
    code = ""
    str.lines.each_with_index do |line,index|
      table << "<span class=\"line-number\">#{index + 1}</span>\n"
      code << "<span class=\"line\">#{line}</span>"
    end
    table << "</pre></td><td class=\"code\"><pre><code class=\"#{language}\">#{code}</code></pre></td></tr></table></div>"
  end
end
