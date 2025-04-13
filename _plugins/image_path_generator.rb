Jekyll::Hooks.register :posts, :pre_render do |post, payload|
  # 获取不包含 .md 的完整文件名
  filename = File.basename(post.path, '.md')
  image_dir = File.join('assets', 'img', 'posts', filename)
  FileUtils.mkdir_p(image_dir) unless Dir.exist?(image_dir)
end