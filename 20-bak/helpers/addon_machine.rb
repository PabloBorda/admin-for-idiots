
addons = []
Dir.entries('addons').each do
  |dir|
  if (dir.include? ".rb")
    file_source_code = File.open("addons/" + dir, "rb")
    addon_source_code_as_string = file_source_code.read
    addons.push(eval(addon_source_code_as_string))
  end
end

addons.each do |a|
  puts a.to_s

end

