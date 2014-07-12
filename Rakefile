require "fileutils"
require "./app"

desc "Remove all generated html"
task :clean do
  FileUtils.rm("index.html")
  FileUtils.rm_r("post")
end

desc "Generates static html files"
task :generate do

  mock = Rack::MockRequest.new(Cuba)

  File.open("index.html", "w+") do |f|
    f.write(mock.get("/").body)
  end

  Posts.paths.each do |post|
    path = ".#{post}.html"
    dir = File.dirname(path)
    FileUtils.mkpath(dir) unless File.exists?(dir)
    File.open(path, "w+") do |f|
      f.write(mock.get(post).body)
    end
  end
end
