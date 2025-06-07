require 'json'

def parse_KV_file(file, separator = '=')
  file_abs_path = File.expand_path(file)
  return [] unless File.exist?(file_abs_path)

  pods_ary = []
  skip_line_start_symbols = ['#', '/']
  File.foreach(file_abs_path) do |line|
    next if skip_line_start_symbols.any? { |symbol| line =~ /^\s*#{symbol}/ }
    plugin = line.split(separator)
    if plugin.length == 2
      podname = plugin[0].strip
      path = plugin[1].strip
      podpath = File.expand_path(path, file_abs_path)
      pods_ary.push({ :name => podname, :path => podpath })
    else
      puts "Invalid plugin specification: #{line}"
    end
  end
  pods_ary
end

def flutter_root
  generated_xcode_build_settings_path = File.expand_path(File.join(__dir__, 'Generated.xcconfig'))
  unless File.exist?(generated_xcode_build_settings_path)
    raise "#{generated_xcode_build_settings_path} must exist. If you're running pod install manually, make sure flutter pub get is executed first"
  end

  File.foreach(generated_xcode_build_settings_path) do |line|
    matches = line.match(/FLUTTER_ROOT\=(.*)/)
    return matches[1].strip if matches
  end
  raise "FLUTTER_ROOT not found in #{generated_xcode_build_settings_path}. Try deleting it, then run flutter pub get"
end

def plugin_pods
  plugin_file = File.expand_path(File.join('..', '.flutter-plugins-dependencies'), __dir__)
  return [] unless File.exist?(plugin_file)

  plugin_hash = JSON.parse(File.read(plugin_file))
  plugin_hash["plugins"]["ios"]
end

def install_plugins
  plugin_pods.each do |plugin|
    if plugin["path"]
      pod plugin["name"], :path => File.expand_path(plugin["path"], flutter_root)
    else
      pod plugin["name"], :git => plugin["git"]
    end
  end
end

def flutter_install_all_ios_pods(flutter_application_path)
  root = flutter_root
  if root.nil? || root.empty?
    raise "FLUTTER_ROOT could not be determined from Generated.xcconfig"
  end

  plugins_file = File.join(flutter_application_path, '.flutter-plugins-dependencies')
  return unless File.exist?(plugins_file)

  plugins = JSON.parse(File.read(plugins_file))["plugins"]["ios"]
  plugins.each do |plugin|
    if plugin["path"]
      pod plugin["name"], :path => File.expand_path(plugin["path"], flutter_application_path)
    else
      pod plugin["name"], :git => plugin["git"]
    end
  end
end
